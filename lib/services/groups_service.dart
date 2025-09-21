import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

enum GroupPermission {
  share,
  delete,
  add,
  mute,
}

enum GroupRole {
  owner,
  member,
}

class GroupMember {
  final String username;
  final String hexCode;
  final GroupRole role;
  final DateTime joinedAt;
  final bool isMuted;

  GroupMember({
    required this.username,
    required this.hexCode,
    required this.role,
    required this.joinedAt,
    this.isMuted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'hexCode': hexCode,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
      'isMuted': isMuted,
    };
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      username: json['username'],
      hexCode: json['hexCode'],
      role: GroupRole.values.firstWhere((e) => e.name == json['role']),
      joinedAt: DateTime.parse(json['joinedAt']),
      isMuted: json['isMuted'] ?? false,
    );
  }

  GroupMember copyWith({
    GroupRole? role,
    bool? isMuted,
  }) {
    return GroupMember(
      username: username,
      hexCode: hexCode,
      role: role ?? this.role,
      joinedAt: joinedAt,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class GroupMessage {
  final String id;
  final String senderUsername;
  final String senderHexCode;
  final String content;
  final DateTime timestamp;
  final String? verseReference;
  final String? verseText;

  GroupMessage({
    required this.id,
    required this.senderUsername,
    required this.senderHexCode,
    required this.content,
    required this.timestamp,
    this.verseReference,
    this.verseText,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUsername': senderUsername,
      'senderHexCode': senderHexCode,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'verseReference': verseReference,
      'verseText': verseText,
    };
  }

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'],
      senderUsername: json['senderUsername'],
      senderHexCode: json['senderHexCode'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      verseReference: json['verseReference'],
      verseText: json['verseText'],
    );
  }
}

class Group {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final String ownerUsername;
  final String ownerHexCode;
  final DateTime createdAt;
  final List<GroupMember> members;
  final List<GroupMessage> messages;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.inviteCode,
    required this.ownerUsername,
    required this.ownerHexCode,
    required this.createdAt,
    required this.members,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'inviteCode': inviteCode,
      'ownerUsername': ownerUsername,
      'ownerHexCode': ownerHexCode,
      'createdAt': createdAt.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      inviteCode: json['inviteCode'],
      ownerUsername: json['ownerUsername'],
      ownerHexCode: json['ownerHexCode'],
      createdAt: DateTime.parse(json['createdAt']),
      members: (json['members'] as List)
          .map((m) => GroupMember.fromJson(m))
          .toList(),
      messages: (json['messages'] as List)
          .map((m) => GroupMessage.fromJson(m))
          .toList(),
    );
  }

  Group copyWith({
    String? name,
    String? description,
    List<GroupMember>? members,
    List<GroupMessage>? messages,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      inviteCode: inviteCode,
      ownerUsername: ownerUsername,
      ownerHexCode: ownerHexCode,
      createdAt: createdAt,
      members: members ?? this.members,
      messages: messages ?? this.messages,
    );
  }

  GroupMember? getMemberByHexCode(String hexCode) {
    try {
      return members.firstWhere((member) => member.hexCode == hexCode);
    } catch (e) {
      return null;
    }
  }

  bool isOwner(String hexCode) {
    return ownerHexCode == hexCode;
  }

  bool isMember(String hexCode) {
    return getMemberByHexCode(hexCode) != null;
  }

  bool canUserPerformAction(String hexCode, GroupPermission permission) {
    final member = getMemberByHexCode(hexCode);
    if (member == null) return false;

    if (isOwner(hexCode)) {
      return true; // Owner can do everything
    }

    switch (permission) {
      case GroupPermission.share:
      case GroupPermission.delete:
      case GroupPermission.add:
        return false; // Only owner can do these
      case GroupPermission.mute:
        return false; // Only owner can mute
    }
  }
}

class GroupsService {
  static const String _groupsKey = 'bible_groups';

  static Future<String> generateInviteCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    
    String code;
    bool isUnique = false;
    int attempts = 0;
    
    do {
      code = List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
      isUnique = await isInviteCodeAvailable(code);
      attempts++;
      
      if (attempts > 100) {
        throw Exception('Unable to generate unique invite code');
      }
    } while (!isUnique);

    return code;
  }

  static Future<bool> isInviteCodeAvailable(String code) async {
    try {
      final groups = await getAllGroups();
      return !groups.any((group) => group.inviteCode == code);
    } catch (e) {
      print('Error checking invite code availability: $e');
      return false;
    }
  }

  static Future<List<Group>> getAllGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getStringList(_groupsKey) ?? [];
      
      return groupsJson
          .map((json) => Group.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error loading groups: $e');
      return [];
    }
  }

  static Future<List<Group>> getUserGroups(String userHexCode) async {
    try {
      final allGroups = await getAllGroups();
      return allGroups.where((group) => group.isMember(userHexCode)).toList();
    } catch (e) {
      print('Error loading user groups: $e');
      return [];
    }
  }

  static Future<Group?> getGroupById(String id) async {
    try {
      final groups = await getAllGroups();
      return groups.firstWhere((group) => group.id == id);
    } catch (e) {
      print('Error getting group by id: $e');
      return null;
    }
  }

  static Future<Group?> getGroupByInviteCode(String inviteCode) async {
    try {
      final groups = await getAllGroups();
      return groups.firstWhere((group) => group.inviteCode == inviteCode);
    } catch (e) {
      print('Error getting group by invite code: $e');
      return null;
    }
  }

  static Future<String> createGroup({
    required String name,
    required String description,
    required String ownerUsername,
    required String ownerHexCode,
  }) async {
    try {
      final inviteCode = await generateInviteCode();
      final groupId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final group = Group(
        id: groupId,
        name: name,
        description: description,
        inviteCode: inviteCode,
        ownerUsername: ownerUsername,
        ownerHexCode: ownerHexCode,
        createdAt: DateTime.now(),
        members: [
          GroupMember(
            username: ownerUsername,
            hexCode: ownerHexCode,
            role: GroupRole.owner,
            joinedAt: DateTime.now(),
          ),
        ],
        messages: [],
      );

      await _saveGroup(group);
      return groupId;
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  static Future<bool> joinGroup(String inviteCode, String username, String hexCode) async {
    try {
      final group = await getGroupByInviteCode(inviteCode);
      if (group == null) {
        throw Exception('Group not found');
      }

      if (group.isMember(hexCode)) {
        throw Exception('Already a member of this group');
      }

      final newMember = GroupMember(
        username: username,
        hexCode: hexCode,
        role: GroupRole.member,
        joinedAt: DateTime.now(),
      );

      final updatedMembers = List<GroupMember>.from(group.members)..add(newMember);
      final updatedGroup = group.copyWith(members: updatedMembers);

      await _saveGroup(updatedGroup);
      return true;
    } catch (e) {
      print('Error joining group: $e');
      rethrow;
    }
  }

  static Future<bool> leaveGroup(String groupId, String userHexCode) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      if (group.isOwner(userHexCode)) {
        throw Exception('Owner cannot leave group. Delete the group instead.');
      }

      final updatedMembers = group.members.where((member) => member.hexCode != userHexCode).toList();
      final updatedGroup = group.copyWith(members: updatedMembers);

      await _saveGroup(updatedGroup);
      return true;
    } catch (e) {
      print('Error leaving group: $e');
      rethrow;
    }
  }

  static Future<bool> deleteGroup(String groupId, String userHexCode) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      if (!group.isOwner(userHexCode)) {
        throw Exception('Only the owner can delete the group');
      }

      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getStringList(_groupsKey) ?? [];
      final updatedGroups = groupsJson.where((json) {
        final existingGroup = Group.fromJson(jsonDecode(json));
        return existingGroup.id != groupId;
      }).toList();

      await prefs.setStringList(_groupsKey, updatedGroups);
      return true;
    } catch (e) {
      print('Error deleting group: $e');
      rethrow;
    }
  }

  static Future<bool> muteMember(String groupId, String memberHexCode, String ownerHexCode) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      if (!group.canUserPerformAction(ownerHexCode, GroupPermission.mute)) {
        throw Exception('Permission denied');
      }

      final updatedMembers = group.members.map((member) {
        if (member.hexCode == memberHexCode) {
          return member.copyWith(isMuted: !member.isMuted);
        }
        return member;
      }).toList();

      final updatedGroup = group.copyWith(members: updatedMembers);
      await _saveGroup(updatedGroup);
      return true;
    } catch (e) {
      print('Error muting member: $e');
      rethrow;
    }
  }

  static Future<String> sendMessage({
    required String groupId,
    required String senderUsername,
    required String senderHexCode,
    required String content,
    String? verseReference,
    String? verseText,
  }) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      final member = group.getMemberByHexCode(senderHexCode);
      if (member == null) {
        throw Exception('You are not a member of this group');
      }

      if (member.isMuted) {
        throw Exception('You are muted in this group');
      }

      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final message = GroupMessage(
        id: messageId,
        senderUsername: senderUsername,
        senderHexCode: senderHexCode,
        content: content,
        timestamp: DateTime.now(),
        verseReference: verseReference,
        verseText: verseText,
      );

      final updatedMessages = List<GroupMessage>.from(group.messages)..add(message);
      final updatedGroup = group.copyWith(messages: updatedMessages);

      await _saveGroup(updatedGroup);
      return messageId;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  static Future<bool> _saveGroup(Group group) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getStringList(_groupsKey) ?? [];
      
      // Remove existing group if updating
      final updatedGroups = groupsJson.where((json) {
        final existingGroup = Group.fromJson(jsonDecode(json));
        return existingGroup.id != group.id;
      }).toList();
      
      // Add updated group
      updatedGroups.add(jsonEncode(group.toJson()));
      
      await prefs.setStringList(_groupsKey, updatedGroups);
      return true;
    } catch (e) {
      print('Error saving group: $e');
      return false;
    }
  }
}
