import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
      _speak("Welcome to Micro Finance Hub. Explore loan products and success stories to grow your business.");
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Micro Finance Hub'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up),
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
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.purple.shade700, size: 20),
                        onPressed: () => _speak("National Impact Dashboard showing statistics of micro finance across India"),
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
            Row(
              children: [
                Text(
                  'Popular Loan Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.blue, size: 20),
                  onPressed: () => _speak("Popular loan products section. Explore different types of micro loans available."),
                ),
              ],
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

            // Success Stories
            Row(
              children: [
                Text(
                  'Success Stories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.amber, size: 20),
                  onPressed: () => _speak("Success stories of entrepreneurs who transformed their businesses with micro loans."),
                ),
              ],
            ),
            SizedBox(height: 16),
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
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.blue, size: 20),
                        onPressed: () => _speak("Tips for successful loan application to increase your chances of approval."),
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
                      _speak("Loan calculator feature will be available soon");
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
                      _speak("Finding nearest micro finance institution");
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
              IconButton(
                icon: Icon(Icons.volume_up, color: color, size: 16),
                onPressed: () => _speak("$title: $value $subtitle"),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
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
              IconButton(
                icon: Icon(Icons.volume_up, color: color, size: 20),
                onPressed: () => _speak("$title. $subtitle. Loan range: $loanRange. Tenure: $tenure. Features: ${features.join(', ')}"),
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
  }

  Widget _buildLoanInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
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
            IconButton(
              icon: Icon(Icons.volume_up, color: Colors.amber.shade700, size: 18),
              onPressed: () => _speak("Success story of $name from $location. $story"),
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
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.blue, size: 16),
            onPressed: () => _speak(tip),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
