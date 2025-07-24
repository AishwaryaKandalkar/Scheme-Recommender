import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  final List<Map<String, String>> news = [
    {
      'title': 'New Microloan Portal Launched for Rural India',
      'desc': 'Personal Loans • 2 hours ago',
      'image': 'assets/images/news1.jpg',
      'likes': '127',
      'comments': '23',
    },
    {
      'title': 'Financial Literacy Workshop Begins This Month',
      'desc': 'Community Event • 1 day ago',
      'image': 'assets/images/news2.jpg',
      'likes': '98',
      'comments': '15',
    },
  ];

  final List<Map<String, dynamic>> questions = [
    {
      'user': 'Alice N.',
      'question': 'What are the best strategies for managing debt effectively?',
      'desc': 'Looking for practical advice on how to prioritize and pay off different types of debt, especially credit card debt.',
      'tags': ['Debt Management'],
      'answers': 13,
      'views': 1156,
      'lang': 'en',
    },
    {
      'user': 'John M.',
      'question': 'How can I start saving for a down payment on a house?',
      'desc': 'First-time homebuyer here! What are some realistic saving goals and methods for accumulating a down payment?',
      'tags': ['Savings', 'Housing'],
      'answers': 18,
      'views': 987,
      'lang': 'en',
    },
    {
      'user': 'Michael K.',
      'question': 'Understanding Compound Interest: Beginner\'s Guide',
      'desc': 'I\'m trying to wrap my head around compound interest. Can someone explain it in simple terms?',
      'tags': ['Investing'],
      'answers': 11,
      'views': 743,
      'lang': 'en',
    },
    {
      'user': 'राहुल एस.',
      'question': 'मुझे प्रधानमंत्री मुद्रा योजना के लिए कैसे आवेदन करना चाहिए?',
      'desc': 'क्या कोई मुझे मुद्रा योजना के आवेदन की प्रक्रिया हिंदी में समझा सकता है?',
      'tags': ['मुद्रा योजना', 'लोन'],
      'answers': 9,
      'views': 520,
      'lang': 'hi',
    },
    {
      'user': 'स्मिता जे.',
      'question': 'महिलाओं के लिए कौनसी सरकारी योजनाएँ उपलब्ध हैं?',
      'desc': 'मैं महिला उद्यमी हूँ, मुझे सरकारी सहायता की जानकारी चाहिए।',
      'tags': ['महिला योजना', 'सरकारी सहायता'],
      'answers': 7,
      'views': 410,
      'lang': 'hi',
    },
    {
      'user': 'अमोल प.',
      'question': 'शेअर बाजारात गुंतवणूक कशी करावी?',
      'desc': 'शेअर बाजारात सुरुवात करण्यासाठी कोणती माहिती आवश्यक आहे?',
      'tags': ['गुंतवणूक', 'शेअर बाजार'],
      'answers': 5,
      'views': 320,
      'lang': 'mr',
    },
    {
      'user': 'संगीता आर.',
      'question': 'शेतकऱ्यांसाठी कोणती कर्ज योजना आहे?',
      'desc': 'माझ्या शेतासाठी कर्ज मिळवण्यासाठी कोणती योजना उपयुक्त आहे?',
      'tags': ['शेतकरी', 'कर्ज'],
      'answers': 6,
      'views': 295,
      'lang': 'mr',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF7F8FA),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Hub',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              // News & Updates
              Text(
                'News & Updates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              ...news.map((item) => Container(
                    margin: EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.pink.shade50),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: item['image'] != null
                              ? Image.asset(
                                  item['image']!,
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(height: 110, color: Colors.pink.shade50),
                        ),
                        Container(
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.15), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'] ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(item['desc'] ?? '',
                                      style: TextStyle(fontSize: 12, color: Colors.white)),
                                  Spacer(),
                                  Icon(Icons.favorite, color: Colors.pinkAccent, size: 16),
                                  SizedBox(width: 4),
                                  Text(item['likes'] ?? '0',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                  SizedBox(width: 12),
                                  Icon(Icons.comment, color: Colors.pinkAccent, size: 16),
                                  SizedBox(width: 4),
                                  Text(item['comments'] ?? '0',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 24),
              // Q&A Forum
              Text(
                'Q&A Forum',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              ...questions.map((item) => Container(
                    margin: EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.pink.shade50),
                    ),
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                item['user'].toString()[0],
                                style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              item['user'],
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            if (item['lang'] == 'hi')
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Text('हिंदी', style: TextStyle(color: Colors.orange, fontSize: 12)),
                              ),
                            if (item['lang'] == 'mr')
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Text('मराठी', style: TextStyle(color: Colors.deepPurple, fontSize: 12)),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          item['question'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.pinkAccent),
                        ),
                        SizedBox(height: 4),
                        Text(
                          item['desc'],
                          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: (item['tags'] as List<String>).map((tag) => Chip(
                            label: Text(tag, style: TextStyle(fontSize: 11, color: Colors.pinkAccent)),
                            backgroundColor: Colors.pink.shade50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          )).toList(),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.question_answer, color: Colors.pinkAccent, size: 16),
                            SizedBox(width: 4),
                            Text('${item['answers']} Answers', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 16),
                            Icon(Icons.visibility, color: Colors.grey, size: 16),
                            SizedBox(width: 4),
                            Text('${item['views']} Views', style: TextStyle(fontSize: 12)),
                            Spacer(),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.pinkAccent,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.pink.shade100),
                                ),
                              ),
                              onPressed: () {},
                              child: Text("View Details"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
                      child: Text('New Question'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
                      child: Text('Video Input'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}