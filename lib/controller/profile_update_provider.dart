import 'dart:io';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileUpdateProvider with ChangeNotifier {
  static const String profileCompletionKey = 'profileCompletion';
  File? _profileImage;
  String? _empCode;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // TextEditingController for blood group and emergency contact
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();
  final TextEditingController emergencyPersonController =
      TextEditingController();

  File? get profileImage => _profileImage;

  void setEmpCode(String empCode) {
    _empCode = empCode;
    notifyListeners();
  }

  Future<void> setProfileImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      _profileImage = File(pickedImage.path);
      notifyListeners(); // Notify listeners to update the UI instantly
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image != null) {
      final resizedImage =
          img.copyResize(image, width: 800); // Adjust width as needed
      int quality = 100;
      List<int>? compressedImage;
      int fileSizeInKB;

      do {
        compressedImage = img.encodeJpg(resizedImage,
            quality: quality); // Ensure JPG encoding
        fileSizeInKB = compressedImage.length ~/ 1024; // Convert to KB
        quality -= 10; // Decrease quality in steps
      } while (fileSizeInKB > 200 &&
          quality > 0); // Stop when within desired range or quality too low

      final compressedFile =
          File('${imageFile.path}_compressed.jpg') // Save as JPG
            ..writeAsBytesSync(compressedImage);

      return compressedFile;
    }

    return imageFile;
  }

  Future<String?> _uploadProfileImage(BuildContext context) async {
    if (_profileImage != null && _empCode != null) {
      try {
        // Compress the image
        File compressedImage = await _compressImage(_profileImage!);

        // Convert the image to JPG format
        final jpgImagePath = compressedImage.path.replaceAll('.png', '.jpg');
        final jpgImageFile = File(jpgImagePath);
        await jpgImageFile.writeAsBytes(await compressedImage.readAsBytes());

        // Upload the JPG image
        final ref =
            _storage.ref().child('profile_images').child('$_empCode.jpg');
        await ref.putFile(jpgImageFile);
        return await ref.getDownloadURL();
      } catch (e) {
        print('Error uploading profile image: $e');
        _showErrorDialog(context, 'Failed to upload image');
      }
    }
    return null;
  }

  Future<String?> getProfileImageUrl(String empCode) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$empCode.jpg');
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    try {
      final userData =
          Provider.of<SigninpageProvider>(context, listen: false).userData;
      _empCode = userData?['EmpCode'] ?? '';

      if (_empCode == null || _empCode!.isEmpty) return;

      final imageUrl = await _uploadProfileImage(context);
      if (imageUrl == null) return;

      final userDoc = _firestore.collection('profile').doc(_empCode);
      await userDoc.set({
        'bloodGroup': bloodGroupController.text,
        'emergencyContact': emergencyContactController.text,
        'emergencyPerson': emergencyPersonController.text,
        'profileImage': imageUrl,
        'EmpCode': _empCode,
        'profileComplete': true,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }

      _profileImage = null;
      notifyListeners();
    } catch (e) {
      print('Error saving profile: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to save profile');
      }
    }
  }

  Future<bool> isProfileComplete(BuildContext context) async {
    try {
      final userData =
          Provider.of<SigninpageProvider>(context, listen: false).userData;
      _empCode = userData?['EmpCode'] ?? '';
      // Ensure _empCode is set
      if (_empCode == null || _empCode!.isEmpty) {
        print('Employee code is null or empty');
        return false;
      }

      // Check if the document exists in Firestore
      final userDoc =
          await _firestore.collection('profile').doc(_empCode!).get();

      if (userDoc.exists) {
        final data = userDoc.data();

        // Check for all required fields
        bool profileComplete = data != null &&
            data['profileImage'] != null &&
            data['bloodGroup'] != null &&
            data['emergencyContact'] != null &&
            data['emergencyPerson'] != null &&
            data['profileComplete'] == true;

        return profileComplete;
      } else {
        print('Document does not exist');
        return false;
      }
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  Future<void> showProfileUpdateAlertIfNeeded(BuildContext context) async {
    final profileProvider =
        Provider.of<ProfileUpdateProvider>(context, listen: false);
    final profileComplete = await profileProvider.isProfileComplete(context);

    if (!profileComplete) {
      // Show alert if profile is not complete
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Profile Incomplete'),
            content: Text('Please complete your profile before proceeding.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Method to clear profile data
  void clearProfile() {
    _profileImage = null;
    bloodGroupController.clear();
    emergencyContactController.clear();
    emergencyPersonController.clear();
    notifyListeners();
  }

  // Method to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

// import 'package:image/image.dart' as img;
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileUpdateProvider with ChangeNotifier {
//   static const String profileCompletionKey = 'profileCompletion';
//   File? _profileImage;
//   String? _empCode;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();

//   // TextEditingController for blood group and emergency contact
//   final TextEditingController bloodGroupController = TextEditingController();
//   final TextEditingController emergencyContactController =
//       TextEditingController();
//   final TextEditingController emergencyPersonController =
//       TextEditingController();

//   File? get profileImage => _profileImage;

//   // Method to set employee code
//   void setEmpCode(String empCode) {
//     _empCode = empCode;
//     notifyListeners();
//   }

//   // Method to pick and set profile image
//   Future<void> setProfileImage(BuildContext context) async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           title: Text('Select Image'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   await _pickImage(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   await _pickImage(ImageSource.camera);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Helper method to pick image from specified source
//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? pickedImage = await _picker.pickImage(source: source);
//     if (pickedImage != null) {
//       _profileImage = File(pickedImage.path);
//       notifyListeners(); // Notify listeners to update the UI instantly
//     }
//   }

//   // Method to upload profile image to Firebase Storage
//   Future<File> _compressImage(File imageFile) async {
//     final imageBytes = await imageFile.readAsBytes();
//     final image = img.decodeImage(imageBytes);

//     if (image != null) {
//       final resizedImage =
//           img.copyResize(image, width: 800); // Adjust width as needed
//       int quality = 100;
//       List<int>? compressedImage;
//       int fileSizeInKB;

//       do {
//         compressedImage = img.encodeJpg(resizedImage,
//             quality: quality); // Ensure JPG encoding
//         fileSizeInKB = compressedImage.length ~/ 1024; // Convert to KB
//         quality -= 10; // Decrease quality in steps
//       } while (fileSizeInKB > 200 &&
//           quality > 0); // Stop when within desired range or quality too low

//       final compressedFile =
//           File('${imageFile.path}_compressed.jpg') // Save as JPG
//             ..writeAsBytesSync(compressedImage);

//       return compressedFile;
//     }

//     return imageFile;
//   }

//   // Modified _uploadProfileImage method to include compression
//   Future<String?> _uploadProfileImage(BuildContext context) async {
//     if (_profileImage != null && _empCode != null) {
//       try {
//         // Compress the image
//         File compressedImage = await _compressImage(_profileImage!);

//         // Convert the image to JPG format
//         final jpgImagePath = compressedImage.path.replaceAll('.png', '.jpg');
//         final jpgImageFile = File(jpgImagePath);
//         await jpgImageFile.writeAsBytes(await compressedImage.readAsBytes());

//         // Upload the JPG image
//         final ref =
//             _storage.ref().child('profile_images').child('$_empCode.jpg');
//         await ref.putFile(jpgImageFile);
//         return await ref.getDownloadURL();
//       } catch (e) {
//         print('Error uploading profile image: $e');
//         _showErrorDialog(context, 'Failed to upload image');
//       }
//     }
//     return null;
//   }

//   Future<String?> getProfileImageUrl(String empCode) async {
//     try {
//       final ref = _storage.ref().child('profile_images').child('$empCode.jpg');
//       final downloadUrl = await ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print('Error getting profile image URL: $e');
//       return null;
//     }
//   }

//   Future<void> saveProfile(BuildContext context) async {
//     try {
//       final userData =
//           Provider.of<SigninpageProvider>(context, listen: false).userData;
//       _empCode = userData?['EmpCode'] ?? '';

//       if (_empCode == null || _empCode!.isEmpty) return;

//       final imageUrl = await _uploadProfileImage(context);
//       if (imageUrl == null) return;

//       final userDoc = _firestore.collection('profile').doc(_empCode);
//       await userDoc.set({
//         'bloodGroup': bloodGroupController.text,
//         'emergencyContact': emergencyContactController.text,
//         'emergencyPerson': emergencyPersonController.text,
//         'profileImage': imageUrl,
//         'EmpCode': _empCode,
//         'profileComplete': true,
//       });

//       await _setProfileCompletionStatus(true);

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//       }

//       _profileImage = null;
//       notifyListeners();
//     } catch (e) {
//       print('Error saving profile: $e');
//       if (context.mounted) {
//         _showErrorDialog(context, 'Failed to save profile');
//       }
//     }
//   }

//   Future<bool> isProfileComplete() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final isProfileComplete = prefs.getBool(profileCompletionKey);

//       if (isProfileComplete == true) {
//         return true;
//       }

//       final userDoc =
//           await _firestore.collection('profile').doc(_empCode!).get();
//       final data = userDoc.data();

//       bool profileComplete = data != null &&
//           data['profileImage'] != null &&
//           data['bloodGroup'] != null &&
//           data['emergencyContact'] != null &&
//           data['emergencyPerson'] != null &&
//           data['profileComplete'] == true;

//       await _setProfileCompletionStatus(profileComplete);

//       return profileComplete;
//     } catch (e) {
//       print('Error checking profile completion: $e');
//       return false;
//     }
//   }

//   Future<void> _setProfileCompletionStatus(bool status) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(profileCompletionKey, status);
//   }

//   // Method to clear profile data
//   void clearProfile() {
//     _profileImage = null;
//     bloodGroupController.clear();
//     emergencyContactController.clear();
//     emergencyPersonController.clear();
//     notifyListeners();
//   }

//   // Method to show error dialog
//   void _showErrorDialog(BuildContext context, String message) {
//     if (context.mounted) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Error'),
//             content: Text(message),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// }
