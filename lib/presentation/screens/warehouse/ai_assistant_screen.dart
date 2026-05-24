import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/warehouse_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final WarehouseService _warehouseService = WarehouseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hello! I am your RecyConnect AI Business Partner. '
          'I can analyze your stock logs, operational expense sheets, and profit metrics. '
          'Ask me anything about your warehouse performance!'
    }
  ];

  bool _isTyping = false;

  final List<String> _shortcutPrompts = [
    'What is my current net profit estimate?',
    'Do I have any low stock warnings?',
    'How can I reduce operational expenses?',
    'What category has the highest stock level?'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Call API
    final reply = await _warehouseService.askAIAssistant(text);

    setState(() {
      _messages.add({'isUser': false, 'text': reply});
      _isTyping = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withOpacity(0.1),
              radius: 18,
              child: Icon(Icons.psychology, color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Business Partner',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Ready to assist',
                      style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),
          if (_isTyping) _buildTypingIndicator(isDark),
          _buildShortcutBar(isDark),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isDark) {
    final isUser = msg['isUser'] as bool;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser
        ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
        : (isDark ? AppTheme.darkCardSurface : Colors.white);
    final textColor = isUser
        ? Colors.white
        : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark);
    final border = Border.all(
      color: isUser
          ? Colors.transparent
          : (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: border,
        ),
        child: Text(
          msg['text'],
          style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              SizedBox(width: 8),
              Text('Thinking...', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutBar(bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _shortcutPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _shortcutPrompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor: isDark ? AppTheme.darkCardSurface : Colors.white,
              label: Text(
                prompt,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              onPressed: () => _sendMessage(prompt),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Ask business partner...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            )
          ],
        ),
      ),
    );
  }
}
