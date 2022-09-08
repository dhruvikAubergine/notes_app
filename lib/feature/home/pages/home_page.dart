import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes_app/core/card_colors.dart';
import 'package:notes_app/feature/add_note/pages/add_note_page.dart';
import 'package:notes_app/feature/home/provider/note_provider.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NoteProvider _noteProvider;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _noteProvider = Provider.of<NoteProvider>(context, listen: false)
        ..fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardColors = CardColors.cardsColor;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notes App'),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) => noteProvider.getNotes.isEmpty
            ? const Center(child: Text('No Note available'))
            : ReorderableGridView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _noteProvider.getNotes.length,
                onReorder: (oldIndex, newIndex) {
                  final item = _noteProvider.getNotes.removeAt(oldIndex);
                  _noteProvider.getNotes.insert(newIndex, item);
                  _noteProvider.reorderedNotes();
                  setState(() {});
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, index) {
                  final note = _noteProvider.getNotes[index];
                  final color = cardColors[_random.nextInt(cardColors.length)];
                  return Card(
                    color: color,
                    key: ValueKey(index),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNotePage(
                                note: note,
                                isForEdit: true,
                                backround: color,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              maxLines: 1,
                              note.title!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              maxLines: 3,
                              note.content!,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
