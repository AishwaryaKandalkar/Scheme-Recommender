import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MicroLoansPage extends StatefulWidget {
  @override
  _MicroLoansPageState createState() => _MicroLoansPageState();
}

class _MicroLoansPageState extends State<MicroLoansPage> {
  FlutterTts? flutterTts;
  static const darkBlue = Color(0xFF1A237E);

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
        title: Text(
          'Micro Finance Hub',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: darkBlue.withOpacity(0.1),
        iconTheme: IconThemeData(color: darkBlue),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBlue, darkBlue.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => _speak("Micro Finance Hub. Empowering small businesses and entrepreneurs across India."),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [darkBlue, darkBlue.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: darkBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Micro Finance Hub',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Empowering small businesses & entrepreneurs across India',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),

            // Impact Statistics Dashboard
            Container(
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
                        child: Icon(Icons.analytics, color: darkBlue, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'National Impact Dashboard',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.volume_up, color: darkBlue, size: 20),
                          onPressed: () => _speak("National Impact Dashboard showing statistics of micro finance across India"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.account_balance_wallet, color: darkBlue, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Popular Loan Products',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.volume_up, color: darkBlue, size: 20),
                    onPressed: () => _speak("Popular loan products section. Explore different types of micro loans available."),
                  ),
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
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.star, color: darkBlue, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Success Stories',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.volume_up, color: darkBlue, size: 20),
                    onPressed: () => _speak("Success stories of entrepreneurs who transformed their businesses with micro loans."),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.amber[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: darkBlue.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
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
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: darkBlue.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
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
                        child: Icon(Icons.lightbulb_outline, color: darkBlue, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tips for Successful Application',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.volume_up, color: darkBlue, size: 20),
                          onPressed: () => _speak("Tips for successful loan application to increase your chances of approval."),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [darkBlue, darkBlue.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _speak("Loan calculator feature will be available soon");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening loan calculator...'),
                            backgroundColor: darkBlue,
                          ),
                        );
                      },
                      icon: Icon(Icons.calculate, color: Colors.white, size: 22),
                      label: Text(
                        'Loan Calculator',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [darkBlue.withOpacity(0.8), darkBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _speak("Finding nearest micro finance institution");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Finding nearest MFI...'),
                            backgroundColor: darkBlue,
                          ),
                        );
                      },
                      icon: Icon(Icons.location_on, color: Colors.white, size: 22),
                      label: Text(
                        'Find MFI Near Me',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
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

  Widget _buildImpactCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12, 
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  icon: Icon(Icons.volume_up, color: color, size: 16),
                  onPressed: () => _speak("$title: $value $subtitle"),
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 11, 
              color: Colors.grey[600]
            ),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
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
                  borderRadius: BorderRadius.circular(15),
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
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14, 
                        color: Colors.grey[600]
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(Icons.volume_up, color: color, size: 20),
                  onPressed: () => _speak("$title. $subtitle. Loan range: $loanRange. Tenure: $tenure. Features: ${features.join(', ')}"),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
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
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: features
                .map((feature) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
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
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: darkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12, 
              color: Colors.grey[600]
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14, 
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[300]!, Colors.amber[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
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
                    name,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: darkBlue,
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(Icons.volume_up, color: Colors.amber[700], size: 20),
                onPressed: () => _speak("Success story of $name from $location. $story"),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            story,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String tip) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: darkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: darkBlue,
                height: 1.3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
              onPressed: () => _speak(tip),
            ),
          ),
        ],
      ),
    );
  }
}
