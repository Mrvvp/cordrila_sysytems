import 'package:badges/badges.dart' as custom_badge;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cordrila_sysytems/controller/admin_request_provider.dart';
import 'package:cordrila_sysytems/view/admin_fresh.dart';
import 'package:cordrila_sysytems/view/admin_request.dart';
import 'package:cordrila_sysytems/view/admin_shopping.dart';
import 'package:cordrila_sysytems/view/admin_utr.dart';
import 'package:cordrila_sysytems/view/edit_profile.dart';

class AdminLandingPage extends StatefulWidget {
  const AdminLandingPage({super.key});

  @override
  _AdminLandingPageState createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<AdminRequestProvider>().isLoading) {
        context.read<AdminRequestProvider>().fetchRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            const Text(
              'Cordrila',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins"),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const AdminRequestPage(),
                  ),
                );
              },
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 40,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Consumer<AdminRequestProvider>(
                      builder: (context, requestProvider, child) {
                        return custom_badge.Badge(
                          badgeContent: Text(
                            requestProvider.requestCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          showBadge: requestProvider.requestCount > 0,
                          position: custom_badge.BadgePosition.topEnd(
                            top: 15,
                            end: 15,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            _buildMenuItem(
              context,
              icon: CupertinoIcons.shopping_cart,
              title: 'Shopping',
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AdminShoppingPage(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildMenuItem(
              context,
              icon: CupertinoIcons.cube_box,
              title: 'Fresh',
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AdminFreshPage(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildMenuItem(
              context,
              icon: CupertinoIcons.cube_box,
              title: 'UTR',
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AdminUtrPage(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildMenuItem(
              context,
              icon: CupertinoIcons.profile_circled,
              title: 'Edit Profile',
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(blurRadius: 1.5, color: Colors.grey)],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.black45),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: "Poppins",
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black45,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
