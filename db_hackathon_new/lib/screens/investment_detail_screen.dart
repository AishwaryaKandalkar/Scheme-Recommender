import 'package:flutter/material.dart';

class InvestmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> investment;

  const InvestmentDetailScreen({Key? key, required this.investment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final extra = investment['extra_details'] ?? {};
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(investment['investment_name'] ?? 'Investment Details', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(investment['investment_name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(height: 10),
            Text('Type: ${investment['investment_type'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Returns: ${investment['total_returns'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Duration: ${investment['time_duration'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            if (investment['investment_amount'] != null)
              Text('Investment Amount: ${investment['investment_amount']}', style: TextStyle(fontSize: 16)),
            if (investment['current_value'] != null)
              Text('Current Value: ${investment['current_value']}', style: TextStyle(fontSize: 16)),
            Divider(height: 32),
            Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pink)),
            SizedBox(height: 10),
            Text('Risk: ${extra['risk'] ?? 'N/A'}', style: TextStyle(fontSize: 15)),
            Text('Demat Account Required: ${extra['demat_account_required'] == true ? "Yes" : "No"}', style: TextStyle(fontSize: 15)),
            Text('Eligibility: ${extra['eligibility'] ?? 'N/A'}', style: TextStyle(fontSize: 15)),
            Text('Documents Required: ${(extra['documents_required'] as List?)?.join(", ") ?? "N/A"}', style: TextStyle(fontSize: 15)),
            Text('Bank Account Required: ${extra['bank_account_required'] == true ? "Yes" : "No"}', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}