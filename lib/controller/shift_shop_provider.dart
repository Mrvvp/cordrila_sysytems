
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'dart:convert'; // For JSON encoding/decoding

class ShopProvider with ChangeNotifier {
  String _selectedShift = '';
  String _tempSelectedShift = ''; // Temporary variable for selected shift
  bool _isFetchingTime = true;
  Map<String, bool> _shiftEnabled = {};
  Map<String, bool> _hiddenShifts = {}; // New map to track hidden shifts
  String _shiftDate = ''; // Variable to store the date when the shift was selected

  String get selectedShift => _selectedShift;
  String get tempSelectedShift => _tempSelectedShift; // Getter for tempSelectedShift
  bool get isFetchingTime => _isFetchingTime;
  Map<String, bool> get shiftEnabled => _shiftEnabled;

  ShopProvider(List<String> shifts) {
    for (var shift in shifts) {
      _shiftEnabled[shift] = true;
      _hiddenShifts[shift] = false; // Initialize with false (not hidden)
    }
    initialize();
  }

  void initialize() async {
    await _checkDateAndReset();
    await _loadShiftState();
    _isFetchingTime = false;
    notifyListeners();
  }

  Future<void> _loadShiftState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedShift = prefs.getString('selected_shift') ?? '';
    _shiftDate = prefs.getString('shift_date') ?? ''; // Load the shift date

    // Load disabled and hidden shifts
    await _loadDisabledShifts();
    await _loadHiddenShifts();

    // Update selected shift to disabled state if the date matches
    if (_selectedShift.isNotEmpty && _shiftDate == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      _shiftEnabled[_selectedShift] = false;
    }

    notifyListeners();
  }

  Future<void> _saveShiftState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_shift', _selectedShift);
    prefs.setString('shift_date', _shiftDate); // Save the date when the shift was selected

    // Save disabled and hidden shifts
    await _saveDisabledShifts();
    await _saveHiddenShifts();
  }

  Future<void> _saveDisabledShifts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Encode shift states as a JSON string
    Map<String, bool> disabledShiftsMap = _shiftEnabled.map((shift, isEnabled) {
      return MapEntry(shift, !isEnabled); // Store disabled state
    });
    prefs.setString('disabled_shifts', jsonEncode(disabledShiftsMap));
  }

  Future<void> _loadDisabledShifts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? disabledShiftsJson = prefs.getString('disabled_shifts');
    if (disabledShiftsJson != null) {
      // Decode JSON string to map
      Map<String, dynamic> disabledShiftsMap = jsonDecode(disabledShiftsJson);
      // Apply disabled state to the shiftEnabled map
      _shiftEnabled.forEach((shift, _) {
        _shiftEnabled[shift] = !(disabledShiftsMap[shift] ?? false);
      });
    } else {
      // Initialize with default state if no disabled shifts are found
      for (var shift in _shiftEnabled.keys) {
        _shiftEnabled[shift] = true;
      }
    }

    notifyListeners();
  }

  Future<void> _saveHiddenShifts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Encode hidden shift states as a JSON string
    prefs.setString('hidden_shifts', jsonEncode(_hiddenShifts));
  }

  Future<void> _loadHiddenShifts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hiddenShiftsJson = prefs.getString('hidden_shifts');
    if (hiddenShiftsJson != null) {
      // Decode JSON string to map
      Map<String, dynamic> hiddenShiftsMap = jsonDecode(hiddenShiftsJson);
      // Apply hidden state to the hiddenShifts map
      _hiddenShifts.forEach((shift, _) {
        _hiddenShifts[shift] = hiddenShiftsMap[shift] ?? false;
      });
    } else {
      // Initialize with default state if no hidden shifts are found
      for (var shift in _hiddenShifts.keys) {
        _hiddenShifts[shift] = false;
      }
    }

    notifyListeners();
  }

 Future<void> _checkDateAndReset() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedDate = prefs.getString('shift_date');
  DateTime currentDate = await NTP.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

  if (savedDate != formattedDate) {
    // Reset selected shift and related data for the new day
    _selectedShift = '';
    for (var shift in _shiftEnabled.keys) {
      _hiddenShifts[shift] = false; // Reset hidden shifts
    }
    prefs.remove('selected_shift');
    prefs.remove('hidden_shifts'); 
    prefs.remove('disabled_shifts');
    // Clear selected shift for the new day

    // Optionally, keep disabled shifts but update state if needed
    // If you want to keep previously disabled shifts, don't remove 'disabled_shifts'
    // Instead, just update it as needed, or reset it if required
    // prefs.remove('disabled_shifts'); // Clear saved disabled shifts for the new day (if necessary)

    prefs.setString('shift_date', formattedDate);
  }
}


  void setSelectedShift(String shift) {
    _tempSelectedShift = shift; // Use temporary shift variable
    notifyListeners();
  }

  void markAttendance() {
    if (_tempSelectedShift.isNotEmpty) {
      _selectedShift = _tempSelectedShift;
      _shiftEnabled[_selectedShift] = false; // Disable the selected shift
      _hiddenShifts[_selectedShift] = true; // Hide the selected shift
      _shiftDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Set the date when the shift is selected
      _saveShiftState();
      _tempSelectedShift = ''; // Clear the temporary selected shift
      notifyListeners();
    }
  }

  bool isShiftEnabled(String shift) {
    return _shiftEnabled[shift] ?? true;
  }

  bool isShiftHidden(String shift) {
    return _hiddenShifts[shift] ?? false;
  }

  bool isNewShiftSelected() {
    return _tempSelectedShift.isNotEmpty && (_shiftEnabled[_tempSelectedShift] ?? false);
  }

  bool hasAvailableShifts() {
    return _shiftEnabled.values.any((isEnabled) => isEnabled);
  }
}
