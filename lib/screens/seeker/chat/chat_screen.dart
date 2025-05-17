// lib/screens/seeker/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';

class ChatScreen extends StatefulWidget {
  final String? otherUserId;
  final String? chatId;
  
  const ChatScreen({
    Key? key,
    this.otherUserId,
    this.chatId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  
  // Mock data for UI design
  final String _otherUserName = "John Doe";
  final String? _otherUserImage = null;
  final List<Map<String, dynamic>> _messages = [
    {
      'senderId': 'other',
      'content': 'Hello, I see you booked my plumbing service.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 40)),
      'isRead': true,
    },
    {
      'senderId': 'me',
      'content': 'Yes, I have a leaking pipe in the kitchen that needs repair.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 38)),
      'isRead': true,
    },
    {
      'senderId': 'other',
      'content': 'Ill be there on time. Do you have any specific requirements I should know about?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 36)),
      'isRead': true,
    },
    {
      'senderId': 'me',
      'content': 'The leak is under the sink. Ill need to shut off the water supply before you arrive?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 32)),
      'isRead': true,
    },
    {
      'senderId': 'other',
      'content': 'That would be helpful. Please shut it off about 15 minutes before our appointment.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': true,
    },
    {
      'senderId': 'me',
      'content': 'Great! Looking forward to getting this fixed.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 28)),
      'isRead': true,
    },
    {
      'senderId': 'other',
      'content': 'No problem. See you tomorrow!',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 27)),
      'isRead': false,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.backgroundLight,
              backgroundImage: _otherUserImage != null
                  ? NetworkImage(_otherUserImage!)
                  : null,
              child: _otherUserImage == null
                  ? Text(
                      _getInitials(_otherUserName),
                      style: AppStyles.captionBoldStyle.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // This would show options menu (not implemented)
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chat Messages
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      reverse: false,
                      itemCount: _messages.length,
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final bool isMe = message['senderId'] == 'me';
                        
                        return _buildMessageItem(message, isMe);
                      },
                    ),
                  ),
                ),
                
                // Message Input
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Attachment Button
                      IconButton(
                        icon: const Icon(
                          Icons.attach_file,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          // This would show attachment options (not implemented)
                        },
                      ),
                      
                      // Text Input
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: AppTexts.typeMessage,
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      
                      // Send Button
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          // This would send the message (not implemented)
                          // Just clear the input for design demo
                          _messageController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildMessageItem(Map<String, dynamic> message, bool isMe) {
    final DateTime timestamp = message['timestamp'] as DateTime;
    final String formattedTime = _formatTime(timestamp);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Profile picture (only for other user's messages)
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.backgroundLight,
              backgroundImage: _otherUserImage != null
                  ? NetworkImage(_otherUserImage!)
                  : null,
              child: _otherUserImage == null
                  ? Text(
                      _getInitials(_otherUserName),
                      style: AppStyles.captionBoldStyle.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.backgroundLight,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['content'] as String,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: isMe 
                            ? Colors.white.withOpacity(0.7) 
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message['isRead'] ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message['isRead'] 
                            ? Colors.white.withOpacity(0.7) 
                            : Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Space after my messages
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    
    return '';
  }
}