import 'package:flutter/material.dart';
import '../services/groups_service.dart';
import '../services/user_service.dart';
import '../widgets/animated_background.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await UserService.getCurrentUser();
      if (user == null) {
        throw Exception('Please create a profile first');
      }

      await GroupsService.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerUsername: user.username,
        ownerHexCode: user.hexCode,
      );

      setState(() => _isLoading = false);
      _showSuccessSnackBar('Group created successfully!');
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isLoading = false);
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
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Create Group',
            style: TextStyle(
              color: Color(0xFF6A4C93),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6A4C93)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A4C93)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          children: [
                            const Icon(
                              Icons.group_add,
                              size: 64,
                              color: Color(0xFF6A4C93),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Create a New Group',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A4C93),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a group to share Bible verses and connect with others',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Form
                      Container(
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Group Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A4C93),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Group Name
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Group Name',
                                labelStyle: const TextStyle(color: Color(0xFF6A4C93)),
                                hintText: 'Enter group name',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(
                                  Icons.group,
                                  color: Color(0xFF6A4C93),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF6A4C93)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF6A4C93), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a group name';
                                }
                                if (value.trim().length < 3) {
                                  return 'Group name must be at least 3 characters';
                                }
                                if (value.trim().length > 30) {
                                  return 'Group name must be less than 30 characters';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Group Description
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Description (Optional)',
                                labelStyle: const TextStyle(color: Color(0xFF6A4C93)),
                                hintText: 'Describe what this group is about...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(
                                  Icons.description,
                                  color: Color(0xFF6A4C93),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF6A4C93)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF6A4C93), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().length > 200) {
                                  return 'Description must be less than 200 characters';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Create Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _createGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A4C93),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Create Group',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A4C93).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6A4C93).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF6A4C93),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Group Features',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A4C93),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '• Share Bible verses with group members\n'
                              '• Send messages and discuss verses\n'
                              '• Invite others with a unique group code\n'
                              '• Manage member permissions as owner',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6A4C93),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
