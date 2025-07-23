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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Micro Finance Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Empowering small businesses & entrepreneurs',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.people,
                  title: 'Active Borrowers',
                  value: '2.5M+',
                  subtitle: 'Across India',
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.account_balance,
                  title: 'Total Disbursed',
                  value: '₹45,000Cr',
                  subtitle: 'Last fiscal year',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Micro Finance Institutions
          Text(
            'Top Micro Finance Institutions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Column(
            children: [
              _buildMFICard(
                name: 'Bandhan Bank',
                description: 'Leading micro finance bank with focus on rural areas',
                interestRate: '16-24%',
                avgLoanSize: '₹35,000',
                branches: '4,500+',
                logo: Icons.account_balance,
              ),
              SizedBox(height: 12),
              _buildMFICard(
                name: 'SKS Microfinance',
                description: 'Pioneer in microfinance with technology-driven approach',
                interestRate: '18-26%',
                avgLoanSize: '₹30,000',
                branches: '2,100+',
                logo: Icons.business,
              ),
              SizedBox(height: 12),
              _buildMFICard(
                name: 'Ujjivan Small Finance Bank',
                description: 'Specialized in urban and semi-urban microfinance',
                interestRate: '15-22%',
                avgLoanSize: '₹40,000',
                branches: '600+',
                logo: Icons.location_city,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Loan Products
          Text(
            'Popular Micro Loan Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              _buildProductCard(
                title: 'Group Loans',
                subtitle: 'Joint Liability Group',
                amount: '₹15K - ₹1L',
                tenure: '12-24 months',
                features: ['No collateral', 'Group guarantee', 'Weekly payments'],
                color: Colors.purple,
                icon: Icons.group,
              ),
              _buildProductCard(
                title: 'Individual Loans',
                subtitle: 'Personal micro loans',
                amount: '₹25K - ₹2L',
                tenure: '6-36 months',
                features: ['Income proof needed', 'Quick processing', 'Flexible EMI'],
                color: Colors.orange,
                icon: Icons.person,
              ),
              _buildProductCard(
                title: 'Micro Enterprise',
                subtitle: 'Business expansion',
                amount: '₹50K - ₹5L',
                tenure: '12-60 months',
                features: ['Business plan', 'Growth focused', 'Mentorship'],
                color: Colors.teal,
                icon: Icons.store,
              ),
              _buildProductCard(
                title: 'Agriculture Micro',
                subtitle: 'Farming activities',
                amount: '₹10K - ₹1L',
                tenure: '6-18 months',
                features: ['Seasonal loans', 'Crop insurance', 'Input financing'],
                color: Colors.green,
                icon: Icons.agriculture,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Success Stories
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Success Stories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildSuccessStory(
                  name: 'Sunita Devi',
                  location: 'Bihar',
                  story: 'Started tailoring business with ₹25,000 loan. Now employs 5 women and earns ₹15,000/month.',
                ),
                Divider(height: 20),
                _buildSuccessStory(
                  name: 'Ravi Kumar',
                  location: 'Gujarat',
                  story: 'Expanded vegetable farming with ₹80,000 loan. Income increased by 150% in 2 years.',
                ),
                Divider(height: 20),
                _buildSuccessStory(
                  name: 'Meera Shah',
                  location: 'Rajasthan',
                  story: 'Started handicraft business with ₹40,000. Now exports to 5 countries.',
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Application Tips
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Tips for Successful Application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildTip('Maintain good credit history and repayment record'),
                _buildTip('Have a clear business plan and purpose for the loan'),
                _buildTip('Join self-help groups or micro finance groups in your area'),
                _buildTip('Keep all required documents ready before applying'),
                _buildTip('Start with smaller amounts and build trust with lenders'),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Contact and Apply
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening loan calculator...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: Icon(Icons.calculate, color: Colors.white),
                  label: Text('Loan Calculator', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Finding nearest MFI...'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: Icon(Icons.location_on, color: Colors.white),
                  label: Text('Find MFI Near Me', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMFICard({
    required String name,
    required String description,
    required String interestRate,
    required String avgLoanSize,
    required String branches,
    required IconData logo,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(logo, color: Colors.blue, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMFIDetail('Interest Rate', interestRate),
              ),
              Expanded(
                child: _buildMFIDetail('Avg Loan', avgLoanSize),
              ),
              Expanded(
                child: _buildMFIDetail('Branches', branches),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMFIDetail(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String title,
    required String subtitle,
    required String amount,
    required String tenure,
    required List<String> features,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            tenure,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          ...features.take(2).map((feature) => Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text(
              '• $feature',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSuccessStory({
    required String name,
    required String location,
    required String story,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.amber.shade200,
              child: Text(
                name[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          story,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
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
