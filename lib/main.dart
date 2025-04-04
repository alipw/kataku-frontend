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
                          list.name,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        final notes = provider.notes;

        return Scaffold(
          appBar: AppBar(
            title: Text(list.name),
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
                        onPressed: () {
                          final note = provider.addNote();
                          if (note != null) {
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
            onPressed: () {
              final note = provider.addNote();
              if (note != null) {
                _showNoteEditor(context, note);
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showNoteEditor(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: NoteEditor(
                  note: note,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Note editor widget
class NoteEditor extends StatefulWidget {
  final Note note;
  final ScrollController scrollController;

  const NoteEditor({
    super.key,
    required this.note,
    required this.scrollController,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document.fromJson(widget.note.content.toJson()),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    Provider.of<NoteProvider>(context, listen: false)
        .updateSelectedNoteContent(_controller.document.toDelta());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Note title',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 18),
          onChanged: (value) =>
              Provider.of<NoteProvider>(context, listen: false)
                  .updateSelectedNoteTitle(value),
        ),
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
                scrollController: widget.scrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
