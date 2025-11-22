import 'package:flutter/material.dart';

class AdminLogsScreen extends StatelessWidget {
  const AdminLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Logs"),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          "No logs available yet",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
