import 'package:flutter/material.dart';

class StockDetailScreen extends StatelessWidget {
  final String canonicalId;
  const StockDetailScreen({super.key, required this.canonicalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(canonicalId)),
      body: const Center(child: Text('상세 화면 (구현 예정)')),
    );
  }
}
