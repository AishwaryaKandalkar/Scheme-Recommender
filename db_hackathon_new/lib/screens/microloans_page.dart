import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../gen_l10n/app_localizations.dart';

class MicroLoansPage extends StatefulWidget {
  @override
  _MicroLoansPageState createState() => _MicroLoansPageState();
}

class _MicroLoansPageState extends State<MicroLoansPage> {
  FlutterTts? flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to Micro Loans section. Explore various microfinance options for your business needs.");
    });
  }

  @override
  void dispose() {
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (flutterTts != null) {
      await flutterTts!.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Micro Finance Hub'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.white),
            onPressed: () => _speak("Micro Finance Hub. Empowering small businesses and entrepreneurs across India."),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.white),
                    onPressed: () => _speak("Micro Finance Hub - Your gateway to microfinance opportunities"),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Impact Statistics Dashboard
            _buildImpactDashboard(),
            
            SizedBox(height: 24),
            
            // Loan Products Section
            Text(
              'Popular Loan Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildLoanProducts(),
            
            SizedBox(height: 24),
            
            // Success Stories
            _buildSuccessStories(),
            
            SizedBox(height: 24),
            
            // MFI Partners
            _buildMFIPartners(),
            
            SizedBox(height: 24),
            
            // Application Process Guide
            _buildApplicationGuide(),
            
            SizedBox(height: 24),
            
            // Call to Action
            _buildCallToAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactDashboard() {
    return Container(
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
              Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.purple.shade700, size: 20),
                onPressed: () => _speak("National Impact Dashboard showing microfinance statistics across India"),
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
    );
  }

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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
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
              Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up, color: color, size: 16),
                onPressed: () => _speak("$title: $value. $subtitle"),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanProducts() {
    return Column(
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
    );
  }

  Widget _buildLoanProduct({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.volume_up, color: color, size: 20),
                onPressed: () => _speak("$title. $subtitle. Loan range $loanRange. Tenure $tenure."),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailChip('Amount', loanRange, color),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildDetailChip('Tenure', tenure, color),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Key Features:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          SizedBox(height: 4),
          ...features.map((feature) => Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStories() {
    return Container(
      padding: EdgeInsets.all(16),
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
              Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.amber.shade700, size: 20),
                onPressed: () => _speak("Success Stories from microfinance beneficiaries"),
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
    );
  }

  Widget _buildSuccessStory({
    required String name,
    required String location,
    required String story,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.amber.shade200,
          child: Text(
            name[0],
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text(
                    location,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                story,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.volume_up, color: Colors.amber.shade700, size: 16),
          onPressed: () => _speak("Success story of $name from $location: $story"),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildMFIPartners() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leading Micro Finance Partners',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        _buildMFICard(
          name: 'Bandhan Bank',
          description: 'India\'s largest MFI with strong rural focus',
          interestRate: '12-18% p.a.',
          avgLoanSize: '₹35,000',
          branches: '4,570+',
          color: Colors.indigo,
        ),
        SizedBox(height: 12),
        _buildMFICard(
          name: 'Ujjivan Small Finance Bank',
          description: 'Urban and semi-urban microfinance specialist',
          interestRate: '15-22% p.a.',
          avgLoanSize: '₹40,000',
          branches: '635+',
          color: Colors.teal,
        ),
        SizedBox(height: 12),
        _buildMFICard(
          name: 'Spandana Sphoorty',
          description: 'Deep rural penetration and agriculture focus',
          interestRate: '16-24% p.a.',
          avgLoanSize: '₹32,000',
          branches: '2,400+',
          color: Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _buildMFICard({
    required String name,
    required String description,
    required String interestRate,
    required String avgLoanSize,
    required String branches,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance, color: color, size: 24),
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
                        color: color,
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
              IconButton(
                icon: Icon(Icons.volume_up, color: color, size: 20),
                onPressed: () => _speak("$name. $description. Interest rate $interestRate. Average loan size $avgLoanSize."),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDetailChip('Interest Rate', interestRate, color)),
              SizedBox(width: 8),
              Expanded(child: _buildDetailChip('Avg. Loan', avgLoanSize, color)),
              SizedBox(width: 8),
              Expanded(child: _buildDetailChip('Branches', branches, color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationGuide() {
    return Container(
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
                'Application Process Guide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.green.shade700, size: 20),
                onPressed: () => _speak("Complete application process guide for microfinance loans"),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildProcessStep('1', 'Eligibility Check', 'Age: 18-65 years, Business vintage: 6+ months', '5 minutes'),
          SizedBox(height: 12),
          _buildProcessStep('2', 'Document Submission', 'Upload required documents and fill application', '15 minutes'),
          SizedBox(height: 12),
          _buildProcessStep('3', 'Verification Process', 'Field verification and credit assessment', '2-3 days'),
          SizedBox(height: 12),
          _buildProcessStep('4', 'Loan Approval', 'Final approval and amount transfer to bank', '1-2 days'),
        ],
      ),
    );
  }

  Widget _buildProcessStep(String stepNumber, String title, String description, String timeRequired) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'Time: $timeRequired',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.volume_up, color: Colors.green.shade700, size: 16),
          onPressed: () => _speak("Step $stepNumber: $title. $description. Time required: $timeRequired."),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildCallToAction() {
    return Container(
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
                    _speak("Opening application portal");
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
                    _speak("Opening EMI calculator");
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
    );
  }
}
