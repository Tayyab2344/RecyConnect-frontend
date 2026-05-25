import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/warehouse_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with TickerProviderStateMixin {
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
  late AnimationController _typingController;

  final List<String> _shortcutPrompts = [
    'What is my current net profit estimate?',
    'Do I have any low stock warnings?',
    'How can I reduce operational expenses?',
    'What category has the highest stock level?'
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
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
    final primaryColor = isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              radius: 18,
              child: Icon(Icons.psychology, color: primaryColor),
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
          color: primaryColor,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, isDark, primaryColor);
              },
            ),
          ),
          if (_isTyping) _buildTypingIndicator(isDark, primaryColor),
          _buildShortcutBar(isDark),
          _buildInputBar(isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isDark, Color primaryColor) {
    final isUser = msg['isUser'] as bool;
    final text = msg['text'] as String;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : (isDark ? AppTheme.darkCardSurface : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: _buildFormattedText(text, isUser, isDark),
            ),
            // Dynamic Context Card injections based on text matching patterns
            if (!isUser) ..._injectContextCards(text, isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String content, bool isUser, bool isDark) {
    final defaultColor = isUser
        ? Colors.white
        : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark);
    
    // Simple inline parser for bold markdown: **bold text**
    final parts = content.split('**');
    if (parts.length > 1) {
      final textSpans = <TextSpan>[];
      for (var i = 0; i < parts.length; i++) {
        final isBold = i % 2 == 1;
        textSpans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: defaultColor,
            ),
          ),
        );
      }
      return RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13, height: 1.4, fontFamily: 'Outfit'),
          children: textSpans,
        ),
      );
    }

    return Text(
      content,
      style: TextStyle(color: defaultColor, fontSize: 13, height: 1.4, fontFamily: 'Outfit'),
    );
  }

  // Parses content to render structured UI components dynamically in chat
  List<Widget> _injectContextCards(String content, bool isDark, Color primaryColor) {
    final widgets = <Widget>[];

    // 1. Finance Card Injection (if response mentions profit numbers)
    if (content.contains('PKR') && (content.contains('Profit') || content.contains('profit'))) {
      widgets.add(
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkCardSurface : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.emerald.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: Colors.emerald, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'FINANCIAL INSIGHT SUMMARY',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.emerald),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Balance Health:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text('Calculated ✅', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 2. Alert Warning Card Injection (if warnings or low stock detected)
    if (content.contains('⚠️') || content.contains('low') || content.contains('Low')) {
      widgets.add(
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkCardSurface : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'INVENTORY WARNING ALERT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Some waste categories are below reorder thresholds. Auditing is recommended.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildTypingIndicator(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardSurface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _typingController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(3, (index) {
                      final offset = (index * 0.2);
                      var value = _typingController.value + offset;
                      if (value > 1.0) value -= 1.0;
                      final size = 4.0 + (value < 0.5 ? value * 6.0 : (1.0 - value) * 6.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(width: 10),
              const Text('Partner thinking...', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutBar(bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _shortcutPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _shortcutPrompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              elevation: 0,
              pressElevation: 1,
              shadowColor: Colors.transparent,
              backgroundColor: isDark ? AppTheme.darkCardSurface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
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

  Widget _buildInputBar(bool isDark, Color primaryColor) {
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
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Ask business partner...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: primaryColor,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 16),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            )
          ],
        ),
      ),
    );
  }
}
