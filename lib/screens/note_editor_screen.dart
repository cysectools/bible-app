import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notes_service.dart';
import '../widgets/animated_background.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late QuillController _controller;
  final TextEditingController _verseReferenceController = TextEditingController();
  final TextEditingController _verseTextController = TextEditingController();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  void _initializeEditor() {
    if (widget.note != null) {
      // Editing existing note
      _verseReferenceController.text = widget.note!.verseReference;
      _verseTextController.text = widget.note!.verseText;
      
      // Initialize Quill controller with existing content
      _controller = QuillController.basic();
      _controller.document = Document.fromJson(
        _parseContentToQuillJson(widget.note!.content),
      );
    } else {
      // Creating new note
      _controller = QuillController.basic();
    }
    
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  List<Map<String, dynamic>> _parseContentToQuillJson(String content) {
    // Simple parsing - in a real app you might want more sophisticated parsing
    return [
      {
        'insert': content,
        'attributes': {}
      }
    ];
  }

  String _getQuillContentAsPlainText() {
    return _controller.document.toPlainText();
  }

  Future<void> _saveNote() async {
    if (_verseReferenceController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a verse reference');
      return;
    }

    if (_verseTextController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter the verse text');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await NotesService.saveNote(
        id: widget.note?.id,
        verseReference: _verseReferenceController.text.trim(),
        verseText: _verseTextController.text.trim(),
        content: _getQuillContentAsPlainText(),
      );

      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });

      _showSuccessSnackBar(
        widget.note != null ? 'Note updated successfully' : 'Note saved successfully',
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to save note');
    }
  }

  Future<void> _shareNote() async {
    final content = _getQuillContentAsPlainText();
    if (content.trim().isEmpty) {
      _showErrorSnackBar('Nothing to share');
      return;
    }

    final shareText = '''
${_verseReferenceController.text.trim()}

"${_verseTextController.text.trim()}"

My Notes:
$content
''';

    try {
      await Share.share(shareText, subject: 'Bible Note: ${_verseReferenceController.text.trim()}');
    } catch (e) {
      _showErrorSnackBar('Failed to share note');
    }
  }

  Future<void> _copyToClipboard() async {
    final content = _getQuillContentAsPlainText();
    if (content.trim().isEmpty) {
      _showErrorSnackBar('Nothing to copy');
      return;
    }

    await Clipboard.setData(ClipboardData(text: content));
    _showSuccessSnackBar('Note copied to clipboard');
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

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Unsaved Changes',
          style: TextStyle(
            color: Color(0xFF6A4C93),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'You have unsaved changes. Do you want to save before leaving?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF6A4C93)),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveNote();
      return false; // Don't pop, saveNote will handle navigation
    }

    return result ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _verseReferenceController.dispose();
    _verseTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.note != null ? 'Edit Note' : 'New Note',
              style: const TextStyle(
                color: Color(0xFF6A4C93),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6A4C93)),
              onPressed: () async {
                final shouldPop = await _onWillPop();
                if (shouldPop) {
                  Navigator.of(context).pop();
                }
              },
            ),
            actions: [
              if (_hasUnsavedChanges)
                IconButton(
                  icon: const Icon(Icons.save, color: Color(0xFF6A4C93)),
                  onPressed: _isLoading ? null : _saveNote,
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF6A4C93)),
                onSelected: (value) async {
                  switch (value) {
                    case 'share':
                      _shareNote();
                      break;
                    case 'copy':
                      _copyToClipboard();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Color(0xFF6A4C93)),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, color: Color(0xFF6A4C93)),
                        SizedBox(width: 8),
                        Text('Copy'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A4C93)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse Reference Input
                      Container(
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
                        child: TextField(
                          controller: _verseReferenceController,
                          decoration: const InputDecoration(
                            labelText: 'Verse Reference',
                            labelStyle: TextStyle(color: Color(0xFF6A4C93)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.bookmark,
                              color: Color(0xFF6A4C93),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Verse Text Input
                      Container(
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
                        child: TextField(
                          controller: _verseTextController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Verse Text',
                            labelStyle: TextStyle(color: Color(0xFF6A4C93)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.format_quote,
                              color: Color(0xFF6A4C93),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notes Section Header
                      const Text(
                        'My Notes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A4C93),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Rich Text Editor
                      Container(
                        height: 300,
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
                            // Toolbar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: QuillToolbar.simple(
                                configurations: QuillSimpleToolbarConfigurations(
                                  controller: _controller,
                                  sharedConfigurations: const QuillSharedConfigurations(
                                    locale: Locale('en'),
                                  ),
                                  showBoldButton: true,
                                  showItalicButton: true,
                                  showUnderLineButton: true,
                                  showStrikeThrough: false,
                                  showInlineCode: false,
                                  showColorButton: true,
                                  showBackgroundColorButton: true,
                                  showClearFormat: true,
                                  showAlignmentButtons: false,
                                  showLeftAlignment: false,
                                  showCenterAlignment: false,
                                  showRightAlignment: false,
                                  showJustifyAlignment: false,
                                  showHeaderStyle: false,
                                  showListNumbers: false,
                                  showListBullets: false,
                                  showListCheck: false,
                                  showCodeBlock: false,
                                  showQuote: true,
                                  showIndent: false,
                                  showLink: false,
                                  showUndo: true,
                                  showRedo: true,
                                  showDirection: false,
                                  showSearchButton: false,
                                ),
                              ),
                            ),
                            
                            // Editor
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                              child: QuillEditor.basic(
                                configurations: QuillEditorConfigurations(
                                  controller: _controller,
                                  sharedConfigurations: const QuillSharedConfigurations(
                                    locale: Locale('en'),
                                  ),
                                  placeholder: 'Start writing your notes here...',
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A4C93),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.note != null ? 'Update Note' : 'Save Note',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
