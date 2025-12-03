import 'package:flutter/material.dart';
import '../../../core/services/admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _adminService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isSuspended = user['verificationStatus'] == 'SUSPENDED';
              return ListTile(
                title: Text(user['name'] ?? 'Unknown'),
                subtitle: Text('${user['email']} - ${user['role']}'),
                trailing: IconButton(
                  icon: Icon(isSuspended ? Icons.restore : Icons.block, color: isSuspended ? Colors.green : Colors.red),
                  onPressed: () async {
                    await _adminService.suspendUser(user['id'], !isSuspended);
                    _loadUsers();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
