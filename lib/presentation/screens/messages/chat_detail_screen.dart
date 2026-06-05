import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/chat/voice_note_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String otherParticipantName;
  final bool initialIsOnline;
  final bool initialIsClosed;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherParticipantName,
    this.initialIsOnline = false,
    this.initialIsClosed = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  late int _currentUserId;

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  bool _isChatClosed = false;

  @override
  void initState() {
    super.initState();
    _isChatClosed = widget.initialIsClosed;
    _currentUserId = Provider.of<AuthService>(context, listen: false).userId ?? 0;
    _fetchMessages(scroll: true);
    
    // Poll for new messages every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });

        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record voice notes.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
  }

  Future<void> _stopAndSendVoiceNote() async {
    try {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();
      
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
        _isSending = true;
      });

      if (path != null) {
        final result = await _chatService.uploadVoiceNote(path);
        final voiceUrl = result['voiceUrl'] as String?;

        if (voiceUrl != null) {
          await _chatService.sendMessage(
            conversationId: widget.conversationId,
            content: '',
            voiceUrl: voiceUrl,
            messageType: 'VOICE_NOTE',
          );
          _fetchMessages(silent: true, scroll: true);
        } else {
          throw Exception('Failed to get voice url from upload');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send voice note: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _fetchMessages({bool silent = false, bool scroll = false}) async {
    if (!silent && _messages.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final list = await _chatService.getMessages(widget.conversationId);
      if (mounted) {
        setState(() {
          _messages = list;
          _isLoading = false;
          if (list.isNotEmpty && list.last is Map) {
            _isChatClosed = list.last['isClosed'] == true;
          }
        });
        if (scroll) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _error = 'Failed to load messages: $e';
          _isLoading = false;
        });
      }
    }
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );
      _fetchMessages(silent: true, scroll: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _shareLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    try {
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationContent = 'LOCATION_SHARE:${pos.latitude},${pos.longitude}';
      
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        content: locationContent,
        messageType: 'LOCATION',
      );
      _fetchMessages(silent: true, scroll: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share location: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _openSharedLocation(String content) async {
    final parts = content.replaceFirst('LOCATION_SHARE:', '').split(',');
    if (parts.length == 2) {
      final double? lat = double.tryParse(parts[0]);
      final double? lon = double.tryParse(parts[1]);
      if (lat != null && lon != null) {
        final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.otherParticipantName.isNotEmpty ? widget.otherParticipantName[0] : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherParticipantName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Active Connection',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages thread
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _fetchMessages(scroll: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Start the conversation',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                const Text('Send a message or share location', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final int senderId = msg['senderId'] as int;
                              final bool isMe = senderId == _currentUserId;
                              final String content = msg['content'] ?? '';
                              final String messageType = msg['messageType'] ?? 'TEXT';
                              final String voiceUrl = msg['voiceUrl'] ?? '';
                              
                              final DateTime date = msg['createdAt'] != null
                                  ? DateTime.parse(msg['createdAt'])
                                  : DateTime.now();
                              final String timeStr = DateFormat('hh:mm a').format(date);

                              return _buildChatBubble(isMe, content, messageType, timeStr, isDark, voiceUrl: voiceUrl);
                            },
                          ),
          ),
          
          // Send input bar or Closed banner
          _isChatClosed
              ? Container(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, color: isDark ? Colors.white60 : Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          'This chat is closed.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _isRecording
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            const Icon(Icons.mic, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'Recording... ${_recordingDuration}s',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _cancelRecording,
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: _stopAndSendVoiceNote,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            // Location Share Button
                            IconButton(
                              icon: const Icon(Icons.location_on, color: Colors.orange),
                              onPressed: _isSending ? null : _shareLocation,
                              tooltip: 'Share Live Location',
                            ),
                            const SizedBox(width: 8),
                            
                            // Text input
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                onChanged: (text) {
                                  setState(() {});
                                },
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                                  border: InputBorder.none,
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Send or Record button
                            GestureDetector(
                              onTap: _messageController.text.trim().isEmpty
                                  ? _startRecording
                                  : _sendMessage,
                              child: CircleAvatar(
                                backgroundColor: AppTheme.primaryGreen,
                                radius: 22,
                                child: _isSending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Icon(
                                        _messageController.text.trim().isEmpty ? Icons.mic : Icons.send,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isMe, String content, String messageType, String timeStr, bool isDark, {String? voiceUrl}) {
    final bool isLocation = messageType == 'LOCATION' || content.startsWith('LOCATION_SHARE:');
    final bool isVoice = messageType == 'VOICE_NOTE' || (voiceUrl != null && voiceUrl.isNotEmpty);

    Widget body;
    if (isLocation) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Shared Location',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _openSharedLocation(content),
            icon: const Icon(Icons.map, size: 16),
            label: const Text('Open in Google Maps', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange[800],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: Colors.orange),
              elevation: 0,
            ),
          ),
        ],
      );
    } else if (isVoice) {
      body = VoiceNoteBubble(
        voiceUrl: voiceUrl ?? '',
        isMe: isMe,
      );
    } else {
      body = Text(
        content,
        style: TextStyle(
          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
          fontSize: 14.5,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: isLocation
                  ? Colors.orange[50]
                  : isMe
                      ? AppTheme.primaryGreen
                      : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              border: isLocation ? Border.all(color: Colors.orange.withOpacity(0.5)) : null,
            ),
            child: body,
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
