import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteEditorPage extends StatefulWidget {
  final Note note;

  const NoteEditorPage({
    super.key,
    required this.note,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late QuillController _controller;
  late TextEditingController _titleController;
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document.fromJson(widget.note.content.toJson()),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _titleController = TextEditingController(text: widget.note.title);
    
    // Save changes whenever text changes
    _controller.addListener(_saveChanges);
    _titleController.addListener(_saveChanges);
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      await provider.updateSelectedNote(
        title: _titleController.text,
        content: _controller.document.toDelta(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Note title',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _controller,
              sharedConfigurations: const QuillSharedConfigurations(
                locale: Locale('en'),
              ),
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: true,
              showItalicButton: true,
              showSmallButton: false,
              showUnderLineButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: false,
              showLeftAlignment: false,
              showCenterAlignment: false,
              showRightAlignment: false,
              showJustifyAlignment: false,
              showHeaderStyle: false,
              showListNumbers: true,
              showListBullets: false,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showLink: false,
              showUndo: false,
              showRedo: false,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: QuillEditor(
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  padding: EdgeInsets.zero,
                  autoFocus: false,
                  expands: false,
                  placeholder: 'Start writing...',
                  scrollable: true,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                ),
                focusNode: _focusNode,
                scrollController: ScrollController(),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 