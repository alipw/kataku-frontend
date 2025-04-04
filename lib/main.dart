import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Import Quill

import 'providers/note_provider.dart';
import 'models/note.dart';
import 'models/note_list.dart'; // Import NoteList model

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kataku Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.blue),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.blue),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      themeMode: ThemeMode.system, // This will follow system theme
      home: const ListsPage(),
    );
  }
}

// Main lists page
class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  void _showCreateListDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New List'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'List name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a list name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final provider = Provider.of<NoteProvider>(context, listen: false);
                provider.addNoteList(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        final lists = provider.noteLists;
        final error = provider.error;

        if (error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Lists'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading lists',
                    style: TextStyle(color: Colors.red[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => provider.loadLists(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Lists'),
          ),
          body: lists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No lists yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => _showCreateListDialog(context),
                        child: const Text('Create a list'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: lists.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.list_alt),
                        title: Text(
                          list.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          '${list.notes.length} notes',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        onTap: () {
                          provider.selectNoteList(list);
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => NotesPage(list: list),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateListDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// Notes page for a specific list
class NotesPage extends StatelessWidget {
  final NoteList list;

  const NotesPage({super.key, required this.list});

  void _showNoteEditor(BuildContext context, Note note) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => NoteEditorPage(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        final notes = provider.notes;

        return Scaffold(
          appBar: AppBar(
            title: Text(list.title),
            leading: BackButton(
              onPressed: () {
                provider.selectNoteList(null);
                Navigator.pop(context);
              },
            ),
          ),
          body: notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () async {
                          final note = await provider.addNote();
                          if (note != null && context.mounted) {
                            _showNoteEditor(context, note);
                          }
                        },
                        child: const Text('Add a note'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notes.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final preview = Document.fromJson(note.content.toJson())
                        .toPlainText()
                        .trim();

                    return Card(
                      child: ListTile(
                        title: Text(
                          note.title.isEmpty ? 'Untitled Note' : note.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: preview.isEmpty
                            ? const Text(
                                'Empty note',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              )
                            : Text(
                                preview.split('\n').first,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        onTap: () => _showNoteEditor(context, note),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => provider.deleteNote(note),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final note = await provider.addNote();
              if (note != null && context.mounted) {
                _showNoteEditor(context, note);
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document.fromJson(widget.note.content.toJson()),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _titleController = TextEditingController(text: widget.note.title);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _saveChanges();
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    _hasChanges = true;
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) return;
    
    final provider = Provider.of<NoteProvider>(context, listen: false);
    await provider.updateSelectedNote(
      title: _titleController.text,
      content: _controller.document.toDelta(),
    );
    _hasChanges = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveChanges();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              await _saveChanges();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Note title',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 18),
            onChanged: (value) {
              _hasChanges = true;
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
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
      ),
    );
  }
}
