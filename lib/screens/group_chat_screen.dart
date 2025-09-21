import 'package:flutter/material.dart';
import '../services/groups_service.dart';
import '../services/user_service.dart';
import '../widgets/animated_background.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _currentUserHexCode;
  GroupMember? _currentMember;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await UserService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUserHexCode = user.hexCode;
        _currentMember = widget.group.getMemberByHexCode(user.hexCode);
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_currentUserHexCode == null || _currentMember == null) return;

    if (_currentMember!.isMuted) {
      _showErrorSnackBar('You are muted in this group');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await GroupsService.sendMessage(
        groupId: widget.group.id,
        senderUsername: _currentMember!.username,
        senderHexCode: _currentUserHexCode!,
        content: _messageController.text.trim(),
      );

      _messageController.clear();
      await _refreshGroup();
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshGroup() async {
    try {
      final updatedGroup = await GroupsService.getGroupById(widget.group.id);
      if (updatedGroup != null) {
        setState(() {
          // Update the group data
          widget.group.messages.clear();
          widget.group.messages.addAll(updatedGroup.messages);
          widget.group.members.clear();
          widget.group.members.addAll(updatedGroup.members);
        });
      }
    } catch (e) {
      print('Error refreshing group: $e');
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

  Future<void> _muteMember(GroupMember member) async {
    if (_currentUserHexCode == null) return;

    try {
      await GroupsService.muteMember(widget.group.id, member.hexCode, _currentUserHexCode!);
      await _refreshGroup();
      _showSuccessSnackBar(
        member.isMuted ? 'Member unmuted' : 'Member muted',
      );
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6A4C93),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _currentUserHexCode != null && widget.group.isOwner(_currentUserHexCode!);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.group.name,
                style: const TextStyle(
                  color: Color(0xFF6A4C93),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${widget.group.members.length} members',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6A4C93)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF6A4C93)),
              onSelected: (value) {
                switch (value) {
                  case 'members':
                    _showMembersDialog();
                    break;
                  case 'invite':
                    _showInviteDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'members',
                  child: Row(
                    children: [
                      Icon(Icons.people, color: Color(0xFF6A4C93)),
                      SizedBox(width: 8),
                      Text('View Members'),
                    ],
                  ),
                ),
                if (isOwner)
                  const PopupMenuItem(
                    value: 'invite',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Color(0xFF6A4C93)),
                        SizedBox(width: 8),
                        Text('Share Invite'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Group Info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A4C93).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isOwner 
                          ? const Color(0xFF6A4C93).withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      isOwner ? Icons.admin_panel_settings : Icons.group,
                      color: isOwner ? const Color(0xFF6A4C93) : Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A4C93),
                            fontSize: 16,
                          ),
                        ),
                        if (widget.group.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.group.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_currentMember?.isMuted == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Muted',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: widget.group.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: widget.group.messages.length,
                      itemBuilder: (context, index) {
                        final message = widget.group.messages[index];
                        final isCurrentUser = message.senderHexCode == _currentUserHexCode;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: isCurrentUser 
                                ? MainAxisAlignment.end 
                                : MainAxisAlignment.start,
                            children: [
                              if (!isCurrentUser) ...[
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6A4C93).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      message.senderUsername[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF6A4C93),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser 
                                        ? const Color(0xFF6A4C93)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isCurrentUser) ...[
                                        Text(
                                          message.senderUsername,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6A4C93),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Text(
                                        message.content,
                                        style: TextStyle(
                                          color: isCurrentUser ? Colors.white : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (message.verseReference != null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isCurrentUser 
                                                ? Colors.white.withOpacity(0.2)
                                                : const Color(0xFF6A4C93).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.verseReference!,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isCurrentUser 
                                                      ? Colors.white 
                                                      : const Color(0xFF6A4C93),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (message.verseText != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  message.verseText!,
                                                  style: TextStyle(
                                                    color: isCurrentUser 
                                                        ? Colors.white70 
                                                        : Colors.grey[700],
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTime(message.timestamp),
                                        style: TextStyle(
                                          color: isCurrentUser 
                                              ? Colors.white70 
                                              : Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6A4C93).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      message.senderUsername[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF6A4C93),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Message Input
            if (_currentMember?.isMuted != true)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A4C93),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMembersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Group Members',
          style: TextStyle(
            color: Color(0xFF6A4C93),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.group.members.length,
            itemBuilder: (context, index) {
              final member = widget.group.members[index];
              final isOwner = widget.group.isOwner(member.hexCode);
              final canMute = _currentUserHexCode != null && 
                  widget.group.canUserPerformAction(_currentUserHexCode!, GroupPermission.mute);

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isOwner 
                        ? const Color(0xFF6A4C93).withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      member.username[0].toUpperCase(),
                      style: TextStyle(
                        color: isOwner ? const Color(0xFF6A4C93) : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A4C93),
                        ),
                      ),
                    ),
                    if (isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A4C93).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A4C93),
                          ),
                        ),
                      ),
                    if (member.isMuted)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Muted',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  'Joined ${_formatDate(member.joinedAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: canMute && !isOwner
                    ? IconButton(
                        icon: Icon(
                          member.isMuted ? Icons.volume_up : Icons.volume_off,
                          color: member.isMuted ? Colors.green : Colors.orange,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _muteMember(member);
                        },
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6A4C93)),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Invite Code',
          style: TextStyle(
            color: Color(0xFF6A4C93),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share this code with others to invite them to your group:',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6A4C93).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6A4C93).withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.group.inviteCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4C93),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6A4C93)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
