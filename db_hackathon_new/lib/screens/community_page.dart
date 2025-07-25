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
      final res = await http.get(Uri.parse('http://10.146.241.105:5000/news'));
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
    const darkBlue = Color(0xFF1A237E);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Community Hub', style: TextStyle(
            fontFamily: 'Roboto',
            color: darkBlue, 
            fontWeight: FontWeight.bold,
            fontSize: 22
          )),
          backgroundColor: Colors.white,
          elevation: 4,
          shadowColor: darkBlue.withOpacity(0.1),
          iconTheme: IconThemeData(color: darkBlue),
          bottom: TabBar(
            labelColor: darkBlue,
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: darkBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 16),
            tabs: [
              Tab(
                icon: Icon(Icons.campaign, size: 20),
                text: 'News & Updates',
              ),
              Tab(
                icon: Icon(Icons.forum, size: 20),
                text: 'Q&A Forum',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // News & Updates Tab
            FutureBuilder<List<dynamic>>(
              future: fetchNews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No news found.', style: TextStyle(color: darkBlue, fontSize: 18)));
                }
                final news = snapshot.data!;
                return ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    ...news.map((item) => Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: darkBlue.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: darkBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.campaign, color: darkBlue, size: 24),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item['headline'] ?? '', 
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 19, 
                                      color: darkBlue,
                                      height: 1.3
                                    )
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: darkBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility, color: darkBlue, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        '${item['views'] ?? 0} Views', 
                                        style: TextStyle(
                                          fontFamily: 'Mulish',
                                          fontSize: 13, 
                                          color: darkBlue,
                                          fontWeight: FontWeight.w600
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [darkBlue, darkBlue.withOpacity(0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    icon: Icon(Icons.auto_stories, color: Colors.white, size: 18),
                                    label: Text(
                                      'Read More', 
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Colors.white, 
                                        fontSize: 16, 
                                        fontWeight: FontWeight.w600
                                      )
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return Container(
                                            height: MediaQuery.of(context).size.height * 0.8,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.white, Colors.blue[50]!],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(28.0),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        width: 50,
                                                        height: 5,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[300],
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      item['headline'] ?? '', 
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.bold, 
                                                        fontSize: 26, 
                                                        color: darkBlue,
                                                        height: 1.3
                                                      )
                                                    ),
                                                    SizedBox(height: 20),
                                                    Container(
                                                      padding: EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(20),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: darkBlue.withOpacity(0.05),
                                                            blurRadius: 10,
                                                            offset: Offset(0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        item['summary'] ?? '', 
                                                        style: TextStyle(
                                                          fontFamily: 'Mulish',
                                                          fontSize: 18,
                                                          height: 1.6,
                                                          color: Colors.grey[800]
                                                        )
                                                      ),
                                                    ),
                                                    if (item['content'] != null && item['content'].toString().isNotEmpty) ...[
                                                      SizedBox(height: 20),
                                                      Container(
                                                        padding: EdgeInsets.all(20),
                                                        decoration: BoxDecoration(
                                                          color: darkBlue.withOpacity(0.05),
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                          item['content'], 
                                                          style: TextStyle(
                                                            fontFamily: 'Mulish',
                                                            fontSize: 17,
                                                            height: 1.7,
                                                            color: Colors.grey[700]
                                                          )
                                                        ),
                                                      ),
                                                    ],
                                                    SizedBox(height: 30),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                          decoration: BoxDecoration(
                                                            color: darkBlue.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(25),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(Icons.visibility, color: darkBlue, size: 18),
                                                              SizedBox(width: 8),
                                                              Text(
                                                                '${item['views'] ?? 0} Views', 
                                                                style: TextStyle(
                                                                  fontFamily: 'Mulish',
                                                                  fontSize: 15, 
                                                                  color: darkBlue,
                                                                  fontWeight: FontWeight.w600
                                                                )
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [darkBlue, darkBlue.withOpacity(0.8)],
                                                            ),
                                                            borderRadius: BorderRadius.circular(25),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: darkBlue.withOpacity(0.3),
                                                                blurRadius: 10,
                                                                offset: Offset(0, 5),
                                                              ),
                                                            ],
                                                          ),
                                                          child: ElevatedButton.icon(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.transparent,
                                                              foregroundColor: Colors.white,
                                                              shadowColor: Colors.transparent,
                                                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                                            ),
                                                            icon: Icon(Icons.mic, size: 20),
                                                            label: Text(
                                                              'Listen',
                                                              style: TextStyle(
                                                                fontFamily: 'Roboto',
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 16
                                                              )
                                                            ),
                                                            onPressed: () {
                                                              // TODO: Integrate voice backend for news reading
                                                            },
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ],
                );
              },
            ),
            // Q&A Forum Tab
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: darkBlue.withOpacity(0.1)),
                            ),
                            child: TextField(
                              controller: postController,
                              decoration: InputDecoration(
                                hintText: 'Ask a question or start a discussion...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Mulish',
                                  color: Colors.grey[500]
                                ),
                                filled: false,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20), 
                                  borderSide: BorderSide.none
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              ),
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [darkBlue, darkBlue.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: darkBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                            ),
                            icon: Icon(Icons.send, size: 18),
                            label: Text('Post', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600)),
                            onPressed: () async {
                              final text = postController.text.trim();
                              if (text.isNotEmpty && userName != null && userUid != null) {
                                await _firestore.collection('community_posts').add({
                                  'text': text,
                                  'image_url': '',
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
                        ),
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [darkBlue.withOpacity(0.8), darkBlue],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: darkBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                            ),
                            icon: Icon(Icons.mic, size: 18),
                            label: Text('Voice', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600)),
                            onPressed: () {
                              // TODO: Implement voice input logic
                            },
                          ),
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
                        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: darkBlue));
                        final posts = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: posts.length,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (context, idx) {
                            final post = posts[idx];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.blue[50]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkBlue.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [darkBlue.withOpacity(0.1), darkBlue.withOpacity(0.05)],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            radius: 22,
                                            child: Text(
                                              (post['user_name'] ?? 'U').toString().split(' ').map((e) => e[0]).take(2).join(),
                                              style: TextStyle(
                                                color: darkBlue, 
                                                fontFamily: 'Roboto', 
                                                fontWeight: FontWeight.bold, 
                                                fontSize: 16
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['user_name'] ?? 'User', 
                                                style: TextStyle(
                                                  fontFamily: 'Roboto', 
                                                  fontWeight: FontWeight.bold, 
                                                  color: darkBlue, 
                                                  fontSize: 18
                                                )
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Active member',
                                                style: TextStyle(
                                                  fontFamily: 'Mulish',
                                                  color: Colors.grey[600],
                                                  fontSize: 13
                                                )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: darkBlue.withOpacity(0.1)),
                                      ),
                                      child: Text(
                                        post['text'] ?? '', 
                                        style: TextStyle(
                                          fontFamily: 'Mulish', 
                                          fontSize: 17, 
                                          fontWeight: FontWeight.w500,
                                          height: 1.5,
                                          color: Colors.grey[800]
                                        )
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _buildActionButton(
                                          icon: Icons.thumb_up,
                                          count: post['likes'] ?? 0,
                                          color: darkBlue,
                                          onPressed: () {
                                            post.reference.update({'likes': (post['likes'] ?? 0) + 1});
                                          },
                                        ),
                                        SizedBox(width: 12),
                                        _buildActionButton(
                                          icon: Icons.thumb_down,
                                          count: post['dislikes'] ?? 0,
                                          color: Colors.grey[600]!,
                                          onPressed: () {
                                            post.reference.update({'dislikes': (post['dislikes'] ?? 0) + 1});
                                          },
                                        ),
                                        Spacer(),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: post.reference.collection('comments').snapshots(),
                                          builder: (context, snap) {
                                            final commentCount = snap.hasData ? snap.data!.docs.length : 0;
                                            return _buildActionButton(
                                              icon: Icons.comment,
                                              count: commentCount,
                                              color: darkBlue,
                                              onPressed: () {},
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    // Comments section and add comment functionality remain the same but with improved styling
                                    StreamBuilder<QuerySnapshot>(
                                      stream: post.reference.collection('comments').orderBy('timestamp').snapshots(),
                                      builder: (context, snap) {
                                        if (!snap.hasData) return SizedBox();
                                        final comments = snap.data!.docs;
                                        return Column(
                                          children: [
                                            if (comments.isNotEmpty) ...[
                                              SizedBox(height: 16),
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[50],
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  children: comments.map((c) => Container(
                                                    margin: EdgeInsets.only(bottom: 12),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor: darkBlue.withOpacity(0.1),
                                                          radius: 14,
                                                          child: Text(
                                                            (c['user_name'] ?? 'U').toString().split(' ').map((e) => e[0]).take(2).join(),
                                                            style: TextStyle(fontSize: 12, color: darkBlue, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                c['user_name'] ?? 'User', 
                                                                style: TextStyle(
                                                                  fontFamily: 'Roboto', 
                                                                  fontWeight: FontWeight.w600, 
                                                                  fontSize: 14, 
                                                                  color: darkBlue
                                                                )
                                                              ),
                                                              SizedBox(height: 4),
                                                              Text(
                                                                c['text'] ?? '', 
                                                                style: TextStyle(
                                                                  fontFamily: 'Mulish', 
                                                                  fontSize: 14,
                                                                  color: Colors.grey[700]
                                                                )
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(Icons.thumb_up, size: 16, color: darkBlue),
                                                              onPressed: () {
                                                                c.reference.update({'likes': (c['likes'] ?? 0) + 1});
                                                              },
                                                            ),
                                                            Text('${c['likes'] ?? 0}', style: TextStyle(fontFamily: 'Mulish', color: darkBlue, fontSize: 12)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )).toList(),
                                                ),
                                              ),
                                            ],
                                            SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color: darkBlue.withOpacity(0.2)),
                                                    ),
                                                    child: TextField(
                                                      controller: commentController,
                                                      decoration: InputDecoration(
                                                        hintText: 'Add a comment...',
                                                        hintStyle: TextStyle(
                                                          fontFamily: 'Mulish',
                                                          color: Colors.grey[500]
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(20), 
                                                          borderSide: BorderSide.none
                                                        ),
                                                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                      ),
                                                      style: TextStyle(fontFamily: 'Roboto', fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [darkBlue, darkBlue.withOpacity(0.8)],
                                                    ),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.transparent,
                                                      foregroundColor: Colors.white,
                                                      shadowColor: Colors.transparent,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    ),
                                                    icon: Icon(Icons.send, size: 16),
                                                    label: Text('Reply', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 13)),
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
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'Mulish',
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }
}