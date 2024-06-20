import 'package:badges/badges.dart' as custom_badge;
import 'package:cordrila_sysytems/view/admin_utr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordrila_sysytems/controller/admin_request_provider.dart';
import 'package:cordrila_sysytems/view/admin_fresh.dart';
import 'package:cordrila_sysytems/view/admin_request.dart';
import 'package:cordrila_sysytems/view/admin_shopping.dart';
import 'package:cordrila_sysytems/view/edit_profile.dart';

class AdminLandingpage extends StatefulWidget {
  const AdminLandingpage({super.key});

  @override
  State<AdminLandingpage> createState() => _AdminLandingpageState();
}

class _AdminLandingpageState extends State<AdminLandingpage> {
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
              Container(
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
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AdminRequestPage(),
                            ),
                          );
                        },
                        icon: Stack(
                          children: [
                            Icon(
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
                                      style:
                                          const TextStyle(color: Colors.white),
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
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => AdminShoppingPage()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(blurRadius: 1.5, color: Colors.grey)
                                ]),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.shopping_cart,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Text(
                                    'Shopping',
                                    style: TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: "Poppins"),
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
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const AdminFreshPage(),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(blurRadius: 1.5, color: Colors.grey)
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: const Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.cube_box,
                                    color: Colors.black45,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Fresh',
                                    style: TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: "Poppins"),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black45,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                       GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const AdminUtrPage(),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(blurRadius: 1.5, color: Colors.grey)
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: const Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.cube_box,
                                    color: Colors.black45,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'UTR',
                                    style: TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: "Poppins"),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black45,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30,),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => EditProfilePage()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(blurRadius: 1.5, color: Colors.grey)
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.profile_circled,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Text(
                                    'Edit  Profile',
                                    style: TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: "Poppins"),
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
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
