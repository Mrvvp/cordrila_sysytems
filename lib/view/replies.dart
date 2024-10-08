import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class RepliesPage extends StatelessWidget {
  final String userId;

  const RepliesPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/Animation - 1722594040196.json',
                  fit: BoxFit.contain,
                ),
              );
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            }

            // Filter documents with a non-null and non-empty reply field
            final requests = snapshot.data?.docs.where((doc) {
              final reply = (doc.data() as Map<String, dynamic>)['reply'];
              return reply != null && reply.toString().trim().isNotEmpty;
            }).toList();

            if (requests == null || requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No notification',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    Lottie.asset(
                      width: 200,
                      'assets/animations/Animation - 1722593381652.json',
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final requestData = request.data() as Map<String, dynamic>;

                final reply = requestData['reply'];
                final request1 = requestData['request'];

                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 3,
                          spreadRadius: 3,
                          offset: const Offset(3, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Request: $request1',
                                          // Limit the number of lines
                                          // Ellipsis for overflow
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Reply: $reply',
                                      // Ellipsis for overflow
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class IconButtonWithBadge extends StatelessWidget {
  final ImageProvider image;
  final int badgeCount;
  final VoidCallback onPressed;

  const IconButtonWithBadge({
    Key? key,
    required this.image,
    required this.badgeCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allows the badge to overflow
      children: [
        IconButton(
          icon: Image(
            image: image,
            width: 38,
          ),
          onPressed: onPressed,
        ),
        if (badgeCount > 0) // Only show badge if there's a count
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
