import 'package:flutter/material.dart';
import '../services/groups_service.dart';
import '../services/user_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_drawer.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';
import 'group_chat_screen.dart';
import 'main_navigation.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  List<Group> _userGroups = [];
  bool _isLoading = true;
  String? _currentUserHexCode;

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  Future<void> _loadUserGroups() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserService.getCurrentUser();
      if (user != null) {
        _currentUserHexCode = user.hexCode;
        final groups = await GroupsService.getUserGroups(user.hexCode);
        setState(() {
          _userGroups = groups;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Please create a profile first');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load groups');
    }
  }

  Future<void> _deleteGroup(Group group) async {
    if (_currentUserHexCode == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Group',
          style: TextStyle(
            color: Color(0xFF6A4C93),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${group.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GroupsService.deleteGroup(group.id, _currentUserHexCode!);
        await _loadUserGroups();
        _showSuccessSnackBar('Group deleted successfully');
      } catch (e) {
        _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _leaveGroup(Group group) async {
    if (_currentUserHexCode == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Leave Group',
          style: TextStyle(
            color: Color(0xFF6A4C93),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to leave "${group.name}"?',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GroupsService.leaveGroup(group.id, _currentUserHexCode!);
        await _loadUserGroups();
        _showSuccessSnackBar('Left group successfully');
      } catch (e) {
        _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
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
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Groups',
            style: TextStyle(
              color: Color(0xFF6A4C93),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF6A4C93)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF6A4C93)),
              onPressed: _loadUserGroups,
            ),
          ],
        ),
        drawer: CustomDrawer(
          currentScreen: 'Groups',
          onNavigate: (index) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainNavigation(initialIndex: index),
              ),
            );
          },
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A4C93)),
                ),
              )
            : _userGroups.isEmpty
                ? _buildEmptyState()
                : _buildGroupsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateGroupScreen(),
              ),
            );
            if (result == true) {
              _loadUserGroups();
            }
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Groups Yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a group or join one to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadUserGroups();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4C93),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinGroupScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadUserGroups();
                  }
                },
                icon: const Icon(Icons.group_add),
                label: const Text('Join Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userGroups.length,
      itemBuilder: (context, index) {
        final group = _userGroups[index];
        final isOwner = _currentUserHexCode != null && group.isOwner(_currentUserHexCode!);
        final member = _currentUserHexCode != null ? group.getMemberByHexCode(_currentUserHexCode!) : null;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(group: group),
                ),
              );
              if (result == true) {
                _loadUserGroups();
              }
            },
            leading: Container(
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
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A4C93),
                      fontSize: 16,
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
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  group.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.members.length} members',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.chat,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.messages.length} messages',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(group.createdAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                if (member?.isMuted == true) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Muted',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF6A4C93),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'chat':
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(group: group),
                      ),
                    );
                    if (result == true) {
                      _loadUserGroups();
                    }
                    break;
                  case 'delete':
                    _deleteGroup(group);
                    break;
                  case 'leave':
                    _leaveGroup(group);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'chat',
                  child: Row(
                    children: [
                      Icon(Icons.chat, color: Color(0xFF6A4C93)),
                      SizedBox(width: 8),
                      Text('Open Chat'),
                    ],
                  ),
                ),
                if (isOwner)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Group'),
                      ],
                    ),
                  ),
                if (!isOwner)
                  const PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Leave Group'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
