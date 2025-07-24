import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';
import 'scheme_detail_screen.dart';
import '../widgets/language_selector.dart';

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
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LanguageSelector(
                    showAsAppBarAction: false,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  Expanded(
                    child: Text(
                      'Welcome! Here are the schemes you are eligible for.',
                      textAlign: TextAlign.center,
// ...existing code...

  // All misplaced widget code outside of methods has been removed.
  // Only valid class members and methods remain.
  // Ensure all widget code is inside methods like _buildMicroLoansContent and helpers.
  // If you need to restore the microloan UI, do so inside _buildMicroLoansContent.
  // No widget code should exist outside of a method or class member.
                                      ),
                                    if ((scheme['scheme_website'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.link, color: Colors.indigo, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('${loc.website}: ${scheme['scheme_website']}', style: TextStyle(fontSize: 16, color: Colors.indigo))),
                                        ],
                                      ),
                                    if ((scheme['similarity_score'] ?? '').toString().isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.score, color: Colors.deepOrange, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('${loc.matchScore}: ${scheme['similarity_score']?.toStringAsFixed(2) ?? ''}', style: TextStyle(fontSize: 16))),
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
    final loc = AppLocalizations.of(context)!;
    return Center(child: Text(loc.trackerComingSoon, style: TextStyle(fontSize: 18)));
  }
  Widget _buildProfileContent() {
    final loc = AppLocalizations.of(context)!;
    return Center(child: Text(loc.profileComingSoon, style: TextStyle(fontSize: 18)));
  }
  Widget _buildMicroLoansContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
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
                        'Empowering small businesses & entrepreneurs across India',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Impact Statistics Dashboard
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.purple.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.purple.shade700, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'National Impact Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.people,
                        title: 'Active Borrowers',
                        value: '3.2 Crore',
                        subtitle: 'Across India',
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.account_balance,
                        title: 'Total Disbursed',
                        value: '₹85,000 Cr',
                        subtitle: 'FY 2023-24',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.business,
                        title: 'Businesses Funded',
                        value: '2.8 Crore',
                        subtitle: 'Small enterprises',
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.trending_up,
                        title: 'Growth Rate',
                        value: '15.2%',
                        subtitle: 'YoY increase',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Loan Products Section
          Text(
            'Popular Loan Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Column(
            children: [
              _buildLoanProduct(
                title: 'Individual Business Loans',
                subtitle: 'For solo entrepreneurs and small business owners',
                loanRange: '₹25,000 - ₹10,00,000',
                tenure: '12-60 months',
                features: ['Minimal documentation', 'Quick approval', 'Flexible repayment'],
                icon: Icons.person,
                color: Colors.blue,
              ),
              SizedBox(height: 12),
              _buildLoanProduct(
                title: 'Joint Liability Group (JLG) Loans',
                subtitle: 'Group-based lending for collective responsibility',
                loanRange: '₹15,000 - ₹5,00,000',
                tenure: '12-36 months',
                features: ['No collateral', 'Lower interest rates', 'Group support'],
                icon: Icons.group,
                color: Colors.green,
              ),
              SizedBox(height: 12),
              _buildLoanProduct(
                title: 'Women Entrepreneur Loans',
                subtitle: 'Special schemes for women-led businesses',
                loanRange: '₹10,000 - ₹15,00,000',
                tenure: '12-84 months',
                features: ['Subsidized rates', 'Training support', 'Priority processing'],
                icon: Icons.woman,
                color: Colors.pink,
              ),
              SizedBox(height: 12),
              _buildLoanProduct(
                title: 'Agricultural Micro Loans',
                subtitle: 'For farming and allied activities',
                loanRange: '₹20,000 - ₹3,00,000',
                tenure: '12-48 months',
                features: ['Seasonal repayment', 'Crop insurance', 'Input financing'],
                icon: Icons.agriculture,
                color: Colors.amber,
              ),
            ],
          ),
          SizedBox(height: 24),
          // Success Story Carousel
          Text(
            'Inspiring Success Stories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: PageView(
              children: [
                _buildSuccessStoryCard(
                  name: 'Sunita Devi',
                  business: 'Handicrafts Business',
                  location: 'Uttar Pradesh',
                  initialLoan: '₹25,000',
                  currentTurnover: '₹8,00,000/year',
                  story: 'Started with traditional handicrafts, now exports to 5 countries',
                  employees: '12 women employed',
                  image: Icons.handyman,
                ),
                _buildSuccessStoryCard(
                  name: 'Rajesh Kumar',
                  business: 'Mobile Repair Shop',
                  location: 'Bihar',
                  initialLoan: '₹50,000',
                  currentTurnover: '₹15,00,000/year',
                  story: 'Expanded from single shop to 4 locations with technical training',
                  employees: '8 technicians employed',
                  image: Icons.phone_android,
                ),
                _buildSuccessStoryCard(
                  name: 'Lakshmi Nair',
                  business: 'Organic Food Processing',
                  location: 'Kerala',
                  initialLoan: '₹1,00,000',
                  currentTurnover: '₹25,00,000/year',
                  story: 'Processing local spices and herbs for national distribution',
                  employees: '20 farmers benefited',
                  image: Icons.eco,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // MFI Partners with Detailed Info
          Text(
            'Leading Micro Finance Partners',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Column(
            children: [
              _buildDetailedMFICard(
                name: 'Bandhan Bank',
                description: 'India\'s largest MFI with strong rural focus and technology adoption',
                founded: '2001',
                headquarters: 'Kolkata',
                interestRate: '12-18% p.a.',
                avgLoanSize: '₹35,000',
                branches: '4,570+',
                customers: '2.3 Crore',
                states: '34 states',
                portfolio: '₹31,000 Cr',
                specialization: 'Rural microfinance, women empowerment',
                logo: Icons.account_balance,
                color: Colors.indigo,
              ),
              SizedBox(height: 16),
              _buildDetailedMFICard(
                name: 'Ujjivan Small Finance Bank',
                description: 'Focused on urban and semi-urban micro finance with digital innovation',
                founded: '2005',
                headquarters: 'Bangalore',
                interestRate: '15-22% p.a.',
                avgLoanSize: '₹40,000',
                branches: '635+',
                customers: '65 Lakh',
                states: '24 states',
                portfolio: '₹18,500 Cr',
                specialization: 'Urban microfinance, digital payments',
                logo: Icons.business,
                color: Colors.teal,
              ),
              SizedBox(height: 16),
              _buildDetailedMFICard(
                name: 'Spandana Sphoorty',
                description: 'One of India\'s oldest MFIs with deep rural penetration',
                founded: '1998',
                headquarters: 'Hyderabad',
                interestRate: '16-24% p.a.',
                avgLoanSize: '₹32,000',
                branches: '2,400+',
                customers: '85 Lakh',
                states: '18 states',
                portfolio: '₹12,800 Cr',
                specialization: 'Rural development, agriculture financing',
                logo: Icons.location_city,
                color: Colors.deepOrange,
              ),
            ],
          ),
          SizedBox(height: 24),
          // Application Process Guide
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment, color: Colors.green.shade700, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Complete Application Guide',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    _buildProcessStepDetailed(
                      stepNumber: '1',
                      title: 'Eligibility Check',
                      description: 'Age: 18-65 years, Business vintage: 6+ months',
                      documents: ['Aadhar Card', 'PAN Card', 'Business Proof'],
                      timeRequired: '5 minutes',
                    ),
                    SizedBox(height: 12),
                    _buildProcessStepDetailed(
                      stepNumber: '2',
                      title: 'Document Submission',
                      description: 'Upload required documents and fill application form',
                      documents: ['Bank Statements (6 months)', 'ITR/GST Returns', 'Business Photos'],
                      timeRequired: '15 minutes',
                    ),
                    SizedBox(height: 12),
                    _buildProcessStepDetailed(
                      stepNumber: '3',
                      title: 'Verification Process',
                      description: 'Field verification and credit assessment',
                      documents: ['Field visit', 'Reference check', 'Credit bureau check'],
                      timeRequired: '2-3 days',
                    ),
                    SizedBox(height: 12),
                    _buildProcessStepDetailed(
                      stepNumber: '4',
                      title: 'Loan Approval & Disbursal',
                      description: 'Final approval and amount transfer to bank account',
                      documents: ['Loan agreement', 'Direct bank transfer', 'Welcome kit'],
                      timeRequired: '1-2 days',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // CTA Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 40),
                SizedBox(height: 12),
                Text(
                  'Transform Your Business Today',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Join millions of successful entrepreneurs who started with micro loans',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Application portal opening soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('EMI calculator coming soon!')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('EMI Calculator'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
    final loc = AppLocalizations.of(context)!;
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: loc.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: loc.tracker,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: loc.profile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: loc.microLoans,
          ),
        ],
      ),
    );
  }

  // Additional helper methods for enhanced microloan content
  Widget _buildImpactCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanProduct({
    required String title,
    required String subtitle,
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                child: _buildLoanInfo('Loan Range', loanRange),
              ),
              Expanded(
                child: _buildLoanInfo('Tenure', tenure),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
    required String title,
    required String subtitle,
    required String loanRange,
    required String tenure,
    required List<String> features,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                child: _buildLoanInfo('Loan Range', loanRange),
              ),
              Expanded(
                child: _buildLoanInfo('Tenure', tenure),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: features
                .map((feature) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    Text(
                      '$business • $location',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            story,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStoryMetric('Initial Loan', initialLoan),
              ),
              Expanded(
                child: _buildStoryMetric('Current Turnover', currentTurnover),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            employees,
            style: TextStyle(
              fontSize: 10,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
                      ),
                    ),
                    Text(
                      '$business • $location',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            story,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStoryMetric('Initial Loan', initialLoan),
              ),
              Expanded(
                child: _buildStoryMetric('Current Turnover', currentTurnover),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            employees,
            style: TextStyle(
              fontSize: 10,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDetailedMFICard({
    required String name,
    required String description,
    required String founded,
    required String headquarters,
    required String interestRate,
    required String avgLoanSize,
    required String branches,
    required String customers,
    required String states,
    required String portfolio,
    required String specialization,
    required IconData logo,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(logo, color: color, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Est. $founded • $headquarters',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMFIMetric('Interest Rate', interestRate, Icons.percent),
                    ),
                    Expanded(
                      child: _buildMFIMetric('Avg. Loan Size', avgLoanSize, Icons.account_balance_wallet),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMFIMetric('Branches', branches, Icons.location_on),
                    ),
                    Expanded(
                      child: _buildMFIMetric('Customers', customers, Icons.people),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMFIMetric('States Covered', states, Icons.map),
                    ),
                    Expanded(
                      child: _buildMFIMetric('Portfolio', portfolio, Icons.trending_up),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
    required String name,
    required String business,
    required String location,
    required String initialLoan,
    required String currentTurnover,
    required String story,
    required String employees,
    required IconData image,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(image, color: Colors.orange.shade700, size: 24),
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
                        color: Colors.orange.shade800,
                      ),
                    ),
                    Text(
                      '$business • $location',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            story,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStoryMetric('Initial Loan', initialLoan),
              ),
              Expanded(
                child: _buildStoryMetric('Current Turnover', currentTurnover),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            employees,
            style: TextStyle(
              fontSize: 10,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
                    color: Colors.green.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: documents
                      .map((doc) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              doc,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.orange.shade600),
                    SizedBox(width: 4),
                    Text(
                      'Time: $timeRequired',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
