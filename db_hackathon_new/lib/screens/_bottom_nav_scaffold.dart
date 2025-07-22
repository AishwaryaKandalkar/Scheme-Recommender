import 'package:flutter/material.dart';
import 'scheme_detail_screen.dart';

class _BottomNavScaffold extends StatefulWidget {
  final List<dynamic> pageSchemes;
  final bool loading;
  final String error;
  final TextEditingController goalController;
  final Future<void> Function({String? customGoal}) fetchSchemes;
  final int currentPage;
  final void Function(int) setCurrentPage;
  final int totalPages;

  const _BottomNavScaffold({
    required this.pageSchemes,
    required this.loading,
    required this.error,
    required this.goalController,
    required this.fetchSchemes,
    required this.currentPage,
    required this.setCurrentPage,
    required this.totalPages,
  });

  @override
  State<_BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<_BottomNavScaffold> {
  int _selectedIndex = 0;

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
              child: Text(
                'Welcome! Here are the schemes you are eligible for.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.goalController,
                      decoration: InputDecoration(
                        hintText: 'Type your goal or need (optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      minLines: 1,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: widget.loading
                        ? null
                        : () async {
                            widget.setCurrentPage(1);
                            await widget.fetchSchemes(customGoal: widget.goalController.text.isNotEmpty ? widget.goalController.text : null);
                          },
                    icon: widget.loading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.search),
                    label: widget.loading ? Text('') : Text('Find'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                child: Text(widget.error, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            SizedBox(height: 10),
            Container(
              constraints: BoxConstraints(minHeight: 300),
              child: widget.pageSchemes.isEmpty && !widget.loading && widget.error.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey, size: 48),
                          SizedBox(height: 10),
                          Text('No eligible recommendations found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.pageSchemes.length,
                      itemBuilder: (context, index) {
                        final scheme = widget.pageSchemes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Color(0xFFe3f0ff)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SchemeDetailScreen(
                                        schemeName: scheme['scheme_name'] ?? ''),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [Colors.orangeAccent, Colors.yellow.shade100],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.star, color: Colors.white, size: 24),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            scheme['scheme_name'] ?? '',
                                            style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blue.shade800,
                                              decoration: TextDecoration.underline,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    if ((scheme['scheme_goal'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.flag, color: Colors.green, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('Goal: ${scheme['scheme_goal']}', style: TextStyle(fontSize: 16))),
                                        ],
                                      ),
                                    if ((scheme['benefits'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.thumb_up, color: Colors.blueAccent, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('Benefits: ${scheme['benefits']}', style: TextStyle(fontSize: 16))),
                                        ],
                                      ),
                                    if ((scheme['total_returns'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.trending_up, color: Colors.purple, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('Returns: ${scheme['total_returns']}', style: TextStyle(fontSize: 16))),
                                        ],
                                      ),
                                    if ((scheme['time_duration'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.timer, color: Colors.teal, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('Duration: ${scheme['time_duration']}', style: TextStyle(fontSize: 16))),
                                        ],
                                      ),
                                    if ((scheme['scheme_website'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.link, color: Colors.indigo, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('Website: ${scheme['scheme_website']}', style: TextStyle(fontSize: 16, color: Colors.indigo))),
                                        ],
                                      ),
                                    if ((scheme['similarity_score'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.score, color: Colors.deepOrange, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('Match Score: ${scheme['similarity_score']?.toStringAsFixed(2) ?? ''}', style: TextStyle(fontSize: 16))),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ));
                        },
                      ),
            ),
            if (widget.pageSchemes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.totalPages, (i) {
                    final pageNum = i + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          widget.setCurrentPage(pageNum);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blueAccent),
                          backgroundColor: widget.currentPage == pageNum
                              ? Colors.blue.shade50
                              : Colors.white,
                        ),
                        child: Text('$pageNum'),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerContent() {
    return Center(child: Text('Tracker page coming soon!', style: TextStyle(fontSize: 18)));
  }
  Widget _buildProfileContent() {
    return Center(child: Text('Profile page coming soon!', style: TextStyle(fontSize: 18)));
  }
  Widget _buildMicroLoansContent() {
    return Center(child: Text('Micro Loans page coming soon!', style: TextStyle(fontSize: 18)));
  }

  List<Widget> get _tabContents => [
    _buildHomeContent(),
    _buildTrackerContent(),
    _buildProfileContent(),
    _buildMicroLoansContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f0ff), Color(0xFFf7fbff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _tabContents[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Micro Loans',
          ),
        ],
      ),
    );
  }
}
