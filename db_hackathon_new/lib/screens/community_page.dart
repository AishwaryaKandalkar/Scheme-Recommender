import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityPage extends StatefulWidget {
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController postController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? userName;
  String? userUid;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      userUid = user.uid;
      _firestore.collection('users').doc(user.uid).get().then((doc) {
        setState(() {
          userName = doc['name'] ?? 'User';
        });
      });
    }
  }

  Future<List<dynamic>> fetchNews() async {
    try {
      // Use the same IP as other endpoints for consistency
      final res = await http.get(Uri.parse('http://10.166.220.105:5000/news'));
      print('News API Response Status: ${res.statusCode}');
      print('News API Response Body: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['news'] ?? [];
      } else {
        print('News API Error: Status ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('News API Exception: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Community Hub', style: TextStyle(color: Colors.pinkAccent)),
          backgroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Forum'),
              Tab(text: 'Trending News'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Forum Tab (unchanged)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: postController,
                          decoration: InputDecoration(
                            hintText: 'Share your doubt or discussion...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                        child: Text('Post', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          final text = postController.text.trim();
                          if (text.isNotEmpty && userName != null && userUid != null) {
                            await _firestore.collection('community_posts').add({
                              'text': text,
                              'image_url': '', // Add image upload logic if needed
                              'likes': 0,
                              'dislikes': 0,
                              'timestamp': FieldValue.serverTimestamp(),
                              'user_name': userName,
                              'user_uid': userUid,
                            });
                            postController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('community_posts')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final posts = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, idx) {
                          final post = posts[idx];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, color: Colors.pinkAccent),
                                      SizedBox(width: 8),
                                      Text(post['user_name'] ?? 'User',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(post['text'] ?? ''),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.thumb_up, color: Colors.pinkAccent),
                                        onPressed: () {
                                          post.reference.update({'likes': (post['likes'] ?? 0) + 1});
                                        },
                                      ),
                                      Text('${post['likes'] ?? 0}'),
                                      IconButton(
                                        icon: Icon(Icons.thumb_down, color: Colors.grey),
                                        onPressed: () {
                                          post.reference.update({'dislikes': (post['dislikes'] ?? 0) + 1});
                                        },
                                      ),
                                      Text('${post['dislikes'] ?? 0}'),
                                      Spacer(),
                                      Icon(Icons.comment, color: Colors.pinkAccent),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: post.reference.collection('comments').snapshots(),
                                        builder: (context, snap) {
                                          if (!snap.hasData) return Text('0');
                                          return Text('${snap.data!.docs.length}');
                                        },
                                      ),
                                    ],
                                  ),
                                  // Comments
                                  StreamBuilder<QuerySnapshot>(
                                    stream: post.reference.collection('comments').orderBy('timestamp').snapshots(),
                                    builder: (context, snap) {
                                      if (!snap.hasData) return SizedBox();
                                      final comments = snap.data!.docs;
                                      return Column(
                                        children: comments.map((c) => Row(
                                          children: [
                                            Icon(Icons.account_circle, size: 18, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(c['user_name'] ?? 'User',
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                            SizedBox(width: 8),
                                            Expanded(child: Text(c['text'] ?? '')),
                                            IconButton(
                                              icon: Icon(Icons.thumb_up, size: 16, color: Colors.pinkAccent),
                                              onPressed: () {
                                                c.reference.update({'likes': (c['likes'] ?? 0) + 1});
                                              },
                                            ),
                                            Text('${c['likes'] ?? 0}'),
                                            IconButton(
                                              icon: Icon(Icons.thumb_down, size: 16, color: Colors.grey),
                                              onPressed: () {
                                                c.reference.update({'dislikes': (c['dislikes'] ?? 0) + 1});
                                              },
                                            ),
                                            Text('${c['dislikes'] ?? 0}'),
                                          ],
                                        )).toList(),
                                      );
                                    },
                                  ),
                                  // Add comment box
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: commentController,
                                            decoration: InputDecoration(
                                              hintText: 'Add a comment...',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                                          child: Text('Comment', style: TextStyle(color: Colors.white)),
                                          onPressed: () async {
                                            final text = commentController.text.trim();
                                            if (text.isNotEmpty && userName != null && userUid != null) {
                                              await post.reference.collection('comments').add({
                                                'text': text,
                                                'likes': 0,
                                                'dislikes': 0,
                                                'timestamp': FieldValue.serverTimestamp(),
                                                'user_name': userName,
                                                'user_uid': userUid,
                                              });
                                              commentController.clear();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            // Trending News Tab (fetches from backend)
            FutureBuilder<List<dynamic>>(
              future: fetchNews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No news found.'));
                }
                final news = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: news.length,
                  itemBuilder: (context, idx) {
                    final item = news[idx];
                    return Card(
                      margin: EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['headline'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 6),
                            Text(item['summary'] ?? '', style: TextStyle(fontSize: 13)),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.visibility, color: Colors.pinkAccent, size: 16),
                                SizedBox(width: 4),
                                Text('${item['views'] ?? 0} Views', style: TextStyle(fontSize: 12)),
                                Spacer(),
                                TextButton(
                                  child: Text('Read More', style: TextStyle(color: Colors.pinkAccent)),
                                  onPressed: () {
                                    // TODO: Use url_launcher to open item['link']
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}