import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _filterStatus = 'All'; // 'All', 'Unread'

  final List<Map<String, dynamic>> _allMessages = [
    {
      'id': '1',
      'name': 'Green Earth Recyclers',
      'lastMessage': 'Is the plastic sorted by color?',
      'time': '10:30 AM',
      'unread': 2,
      'avatar': 'G',
      'color': Colors.green,
    },
    {
      'id': '2',
      'name': 'Paper Recyclers Ltd',
      'lastMessage': 'We can pick up the cardboard tomorrow.',
      'time': 'Yesterday',
      'unread': 0,
      'avatar': 'P',
      'color': Colors.blue,
    },
    {
      'id': '3',
      'name': 'Metal Works Co.',
      'lastMessage': 'Payment has been processed.',
      'time': 'Yesterday',
      'unread': 0,
      'avatar': 'M',
      'color': Colors.orange,
    },
    {
      'id': '4',
      'name': 'EcoTech Solutions',
      'lastMessage': 'Thanks for the e-waste delivery.',
      'time': '2 days ago',
      'unread': 0,
      'avatar': 'E',
      'color': Colors.purple,
    },
  ];

  List<Map<String, dynamic>> get _filteredMessages {
    if (_filterStatus == 'Unread') {
      return _allMessages.where((m) => m['unread'] > 0).toList();
    }
    return _allMessages;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _buildFilterChip('All', isDark),
                const SizedBox(width: 12),
                _buildFilterChip('Unread', isDark),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredMessages.length,
        itemBuilder: (context, index) {
          final message = _filteredMessages[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.1) : AppTheme.lightGray.withOpacity(0.5),
                ),
              ),
              color: message['unread'] > 0 
                  ? (isDark ? AppTheme.darkPrimaryGreen.withOpacity(0.05) : AppTheme.primaryGreen.withOpacity(0.05))
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: message['color'],
                child: Text(
                  message['avatar'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    message['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: message['unread'] > 0 
                              ? (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)
                              : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
                          fontWeight: message['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (message['unread'] > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          message['unread'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              onTap: () {
                // Navigate to chat detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat with ${message['name']} coming soon!')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat feature coming soon!')),
          );
        },
        backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _filterStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
              : (isDark ? AppTheme.darkCardSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                : (isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : AppTheme.lightGray),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
