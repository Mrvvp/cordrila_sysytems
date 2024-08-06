import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordrila_sysytems/controller/admin_request_provider.dart';
import 'package:intl/intl.dart';

class AdminRequestPage extends StatefulWidget {
  const AdminRequestPage({Key? key}) : super(key: key);

  @override
  _AdminRequestPageState createState() => _AdminRequestPageState();
}

class _AdminRequestPageState extends State<AdminRequestPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<AdminRequestProvider>().isLoading) {
        context.read<AdminRequestProvider>().fetchRequests();
      }
    });

    _searchController.addListener(() {
      context
          .read<AdminRequestProvider>()
          .filterRequests(_searchController.text);
    });
  }

  Future<void> _refreshData(BuildContext context) async {
    await Provider.of<AdminRequestProvider>(context, listen: false)
        .fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AdminRequestProvider>(
        builder: (context, requestProvider, child) {
          return RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: requestProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                IconButton(
                                  iconSize: 35,
                                  color: Colors.black45,
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Requests',
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                constraints: const BoxConstraints(maxHeight: 50),
                                contentPadding: const EdgeInsets.all(8),
                                prefixIcon: Icon(
                                  CupertinoIcons.search,
                                  color: Colors.grey.shade500,
                                ),
                                hintText: 'Enter ID',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            if (requestProvider.filteredRequests.isEmpty)
                              const Center(
                                  child: Text('No requests available')),
                            if (requestProvider
                                .filteredRequests.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    requestProvider.filteredRequests.length,
                                itemBuilder: (context, index) {
                                  final request =
                                      requestProvider.filteredRequests[index];
                                  final TextEditingController replyController =
                                      TextEditingController(
                                          text: request['reply'] ?? '');

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          blurRadius: 3,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Name: ${request['name']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'ID: ${request['userId']}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                if (request['timestamp'] != null)
                                                  Text(
                                                    'Time: ${DateFormat('yyyy-MM-dd HH:mm').format((request['timestamp'] as Timestamp).toDate())}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red.shade300,
                                              ),
                                              onPressed: () {
                                                requestProvider.deleteRequest(
                                                    request['id']);
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6, // Adjust the width as needed
                                          child: TextField(
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              filled: true,
                                              fillColor: Colors.grey.shade200,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color:
                                                        Colors.transparent),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text: '${request['request']}',
                                            ),
                                            readOnly: true,
                                            maxLines: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                           width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6, 
                                          child: TextField(
                                            controller: replyController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              filled: true,
                                              fillColor: Colors.grey.shade200,
                                              hintText: 'Enter reply',
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.transparent),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            requestProvider.sendReply(
                                                request['id'],
                                                replyController.text);
                                          },
                                          child: const Text('Send Reply'),
                                        ),
                                        if (request['reply'] != null)
                                          Text(
                                            'Reply: ${request['reply']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
