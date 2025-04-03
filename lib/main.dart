import 'package:flutter/material.dart';
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
      title: 'Kataku Notes', // Changed title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true, // Optional: Use Material 3 design
        navigationRailTheme: NavigationRailThemeData( // Style for wide screen sidebar
            selectedIconTheme: IconThemeData(color: Colors.teal[700]),
            selectedLabelTextStyle: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.bold),
        ),
      ),
      home: const HomePage(), // Changed home to HomePage
    );
  }
}

// New HomePage widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 720; // Adjusted breakpoint

        if (isWideScreen) {
          // Wide screen: Show Row with AllListsScreen + NotesScreen + EditorScreen
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: AllListsScreen(), // Screen for List Names
                ),
                const VerticalDivider(width: 1),
                 SizedBox(
                   width: 280, // Width for notes in the selected list
                   child: NotesInListScreen(), // Screen for Notes in List
                 ),
                 const VerticalDivider(width: 1),
                Expanded(
                  child: NoteEditorScreen(), // Editor remains expanded
                ),
              ],
            ),
          );
        } else {
          // Narrow screen: Show Editor + Drawer for Lists and Notes
          return Scaffold(
            appBar: AppBar(
              title: Consumer<NoteProvider>( // Show selected List name
                builder: (context, noteProvider, child) {
                  return Text(noteProvider.selectedNoteList?.name ?? 'Kataku Notes');
                },
              ),
              actions: [
                // Button to show Notes of the current list (if a LIST is selected)
                 Consumer<NoteProvider>(
                  builder: (context, noteProvider, child) {
                     if (noteProvider.selectedNoteList != null) {
                       return IconButton(
                         icon: const Icon(Icons.list_alt),
                         tooltip: 'Show Notes in List',
                         onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(title: Text(noteProvider.selectedNoteList?.name ?? 'Notes')),
                                body: NotesInListScreen(), // Navigate to notes list
                              ),
                            ),
                          );
                         },
                       );
                     }
                     // Hide if no list is selected
                     return const SizedBox.shrink(); 
                  },
                 ), 
              ],
            ),
            drawer: Drawer( // Drawer now contains the AllListsScreen
              width: 280,
              child: AllListsScreen(),
            ),
            body: NoteEditorScreen(),
          );
        }
      },
    );
  }
}

// --- Screen Widgets ---

// Screen to display all Note Lists (used in Sidebar/Drawer)
class AllListsScreen extends StatelessWidget {
  const AllListsScreen({super.key});

  // Function to show Add/Rename List Dialog
  Future<void> _showListDialog(BuildContext context, NoteProvider provider, {NoteList? existingList}) async {
    final nameController = TextEditingController(text: existingList?.name ?? '');
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(existingList == null ? 'Add New List' : 'Rename List'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'List Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a list name';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(existingList == null ? 'Add' : 'Rename'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                   final name = nameController.text.trim();
                   if (existingList == null) {
                     provider.addNoteList(name);
                   } else {
                     provider.renameNoteList(existingList, name);
                   }
                   Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final lists = noteProvider.noteLists;
    final selectedList = noteProvider.selectedNoteList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Lists'),
        automaticallyImplyLeading: false, // No back button here
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add List',
            onPressed: () => _showListDialog(context, noteProvider),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: lists.length,
        itemBuilder: (context, index) {
          final list = lists[index];
          return ListTile(
            leading: const Icon(Icons.list), // Icon for list
            title: Text(list.name),
            selected: list.id == selectedList?.id,
            selectedTileColor: Colors.teal.withOpacity(0.1),
            onTap: () {
              noteProvider.selectNoteList(list);
              // Don't pop drawer automatically here, user might want to see notes first
            },
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              tooltip: 'List Options',
              onSelected: (value) {
                if (value == 'rename') {
                  _showListDialog(context, noteProvider, existingList: list);
                } else if (value == 'delete') {
                   // Optional: Add confirmation dialog
                   noteProvider.deleteNoteList(list);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'rename',
                  child: Text('Rename'),
                ),
                 const PopupMenuItem<String>(
                   value: 'delete',
                   child: Text('Delete'),
                 ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// Screen to display notes within the selected list
class NotesInListScreen extends StatelessWidget {
  const NotesInListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    // Get notes from the provider (which respects the selected list)
    final notes = noteProvider.notes;
    final selectedNote = noteProvider.selectedNote;
    final selectedList = noteProvider.selectedNoteList; // Get selected list for title/actions

    return Scaffold(
      appBar: AppBar(
         // Title shows list name, or generic if none selected (shouldn't happen here ideally)
         title: Text(selectedList?.name ?? 'Notes'),
        automaticallyImplyLeading: false, // No back button here
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Note',
            onPressed: selectedList == null ? null : () { // Disable if no list selected
              noteProvider.addNote();
              // If this screen is in a drawer, potentially close it?
              // Or, if on wide screen, just adding is fine.
               // On narrow screen, this screen might be pushed, so adding selects it.
            },
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes in this list yet.'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                // Create a temporary document for plain text preview
                final previewDoc = Document.fromJson(note.content.toJson());
                return ListTile(
                  title: Text(note.title.isEmpty ? '(Untitled Note)' : note.title),
                  subtitle: Text(
                     // Use previewDoc.toPlainText()
                     previewDoc.toPlainText().split('\n').first.characters.take(50).toString(),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                  ),
                  selected: note.id == selectedNote?.id,
                  selectedTileColor: Colors.teal.withOpacity(0.1),
                  onTap: () {
                    noteProvider.selectNote(note);
                     // Simplified logic: Pop route if possible (covers pushed screen case)
                     // User manually closes main drawer if needed.
                    if (Navigator.canPop(context)) {
                       // Check if it's not the main scaffold's drawer route
                       final parentRoute = ModalRoute.of(context);
                       // Avoid popping if it's the main drawer content being shown
                       // This check might need refinement depending on exact routing.
                       bool isLikelyDrawerContent = !(parentRoute?.canPop ?? false);
                       if (!isLikelyDrawerContent) {
                           Navigator.pop(context);
                       }
                    }
                  },
                   trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Delete Note',
                    onPressed: () {
                      // Optional: Show confirmation dialog
                      noteProvider.deleteNote(note);
                    },
                  ),
                );
              },
            ),
    );
  }
}

// Widget to display the Quill editor for the selected note
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
   QuillController? _controller;
   final FocusNode _focusNode = FocusNode();
   final TextEditingController _titleController = TextEditingController();
   final ScrollController _scrollController = ScrollController();
   String? _currentNoteId; // Keep track of the loaded note ID

   @override
  void dispose() {
    _controller?.dispose();
    _focusNode.dispose();
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Listener for QuillController changes
  void _onQuillChange() {
     if (_controller == null || !mounted) return; // Add mounted check
     // Update the provider
     Provider.of<NoteProvider>(context, listen: false)
            .updateSelectedNoteContent(_controller!.document.toDelta());
   }

  void _loadNote(Note note) {
    _currentNoteId = note.id;
    final doc = Document.fromJson(note.content.toJson());

    // Remove listener from old controller before disposing
    _controller?.removeListener(_onQuillChange); // Change: Remove listener from controller
    _controller?.dispose();

    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _titleController.text = note.title;

    // Add listener to the new controller
    _controller!.addListener(_onQuillChange); // Change: Add listener to controller

     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) { }
     });
  }

   @override
  Widget build(BuildContext context) {
    // Watch for changes in the selected note *and* selected list
    final noteProvider = Provider.of<NoteProvider>(context);
    final selectedNote = noteProvider.selectedNote;
    final selectedList = noteProvider.selectedNoteList;

    // Determine if editor should be shown
    bool shouldShowEditor = selectedNote != null && selectedList != null && selectedList.notes.contains(selectedNote);

    // Load or reload note content only if the selected note ID changes
    if (shouldShowEditor && _currentNoteId != selectedNote.id) {
       // Use a post-frame callback to avoid modifying state during build
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) { // Check if the widget is still in the tree
           _loadNote(selectedNote);
            // Force rebuild after loading note if necessary
            setState(() {});
         }
       });
     } else if (!shouldShowEditor && _controller != null) {
        // Clear editor if no valid note is selected
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
              _controller?.removeListener(_onQuillChange); // Change: Remove listener from controller
              _controller?.dispose();
              _controller = null;
              _titleController.clear();
              _currentNoteId = null;
              setState(() {});
           }
        });
     }

    // Show placeholder if no note/list is selected or if controller isn't ready
    if (!shouldShowEditor || _controller == null) {
       return Center(child: Text(selectedList == null 
            ? 'Select or create a Note List.'
            : 'Select a note or create a new one in "${selectedList.name}".'));
     }

    // Main editor view
    return Scaffold(
       body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure children fill width
           children: [
             // Title TextField
             TextField(
               controller: _titleController,
               decoration: const InputDecoration(
                 hintText: 'Note Title',
                 border: InputBorder.none,
               ),
               style: Theme.of(context).textTheme.headlineSmall,
               // Update provider only when editing finishes or focus changes
               // to avoid excessive updates on every keystroke.
               onChanged: (newTitle) {
                  noteProvider.updateSelectedNoteTitle(newTitle);
               },
             ),
             const Divider(),
             // Quill Toolbar
             QuillToolbar.simple(
               configurations: QuillSimpleToolbarConfigurations(
                 controller: _controller!,
                 sharedConfigurations: const QuillSharedConfigurations(
                   locale: Locale('en'),
                 ),
                 // Customize toolbar options if needed
                 // showBoldButton: true,
                 // showCodeBlock: false,
               ),
             ),
             const Divider(),
             // Quill Editor
             Expanded(
               child: QuillEditor(
                 configurations: QuillEditorConfigurations(
                   controller: _controller!,
                   padding: const EdgeInsets.symmetric(vertical: 8), // Adjust padding
                   sharedConfigurations: const QuillSharedConfigurations(
                     locale: Locale('en'),
                   ),
                 ),
                 scrollController: _scrollController,
                 focusNode: _focusNode,
               ),
             ),
           ],
         ),
       ),
     );
   }
}
