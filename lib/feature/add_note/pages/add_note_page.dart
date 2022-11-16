import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/feature/add_note/modals/note.dart';
import 'package:notes_app/feature/home/provider/note_provider.dart';
import 'package:provider/provider.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({
    super.key,
    this.note,
    this.backround,
    this.isForEdit = false,
  });
  final Note? note;
  final bool isForEdit;
  final Color? backround;

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _contentController = TextEditingController();

  late Note? _note;
  late Color? backgroundColor;
  late List<String> imagesPath;
  final _random = math.Random();

  Future<void> pickImage(ImageSource imageType) async {
    try {
      final imageFile = await ImagePicker().pickImage(source: imageType);
      if (imageFile != null) {
        final tempImage = File(imageFile.path);

        setState(() {
          imagesPath.add(tempImage.path);
        });
        log(tempImage.path);
        log(imagesPath.length.toString());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image is not selected')),
        );
      }
    } on Exception catch (e) {
      log(e.toString(), name: 'Image Picker');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image is not selected')),
      );
    }
  }

  Future<void> _onSave() async {
    if (_contentController.text.trim().isNotEmpty) {
      final noteContent = _contentController.text.trim().split('\n');
      final titleIndex = noteContent[0].indexOf('.');
      final title = titleIndex < 0
          ? noteContent[0].trim()
          : noteContent[0].substring(0, titleIndex + 1).trim();
      final content = titleIndex < 0
          ? noteContent.sublist(1).join('\n').trim()
          : noteContent[0].substring(titleIndex + 1) +
              noteContent.sublist(1).join('\n').trim();

      log('${imagesPath.length}');
      final note = _note?.copyWith(
            title: title,
            content: content,
            images: imagesPath,
          ) ??
          Note(
            title: title,
            content: content,
            images: imagesPath,
            id: DateTime.now().toString(),
            backgroundColor: backgroundColor?.value.toString() ?? '',
          );
      await Provider.of<NoteProvider>(context, listen: false).addNote(
        note: note,
        isForEdit: widget.isForEdit,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note edited')),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter note here')),
      );
    }
  }

  void _updateFields() {
    _contentController.text = widget.isForEdit
        ? '${_note?.title ?? ''}\n${_note?.content ?? ''}'
        : '';
    imagesPath = _note?.images ?? [];
    backgroundColor = widget.backround ??
        Colors.primaries[_random.nextInt(Colors.primaries.length)].shade50;
    // Color.fromARGB(
    //   _random.nextInt(256),
    //   _random.nextInt(256),
    //   _random.nextInt(256),
    //   _random.nextInt(256),
    // ).withOpacity(0.1);
  }

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _updateFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 5,
        actions: [
          IconButton(
            onPressed: () => pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_rounded),
          ),
          IconButton(
            onPressed: () => pickImage(ImageSource.gallery),
            icon: const Icon(Icons.image_rounded),
          ),
          IconButton(
            onPressed: () {
              onDeleteNote(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ColoredBox(
        color: backgroundColor!,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            if (imagesPath.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                itemCount: imagesPath.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onLongPress: () {
                      onDeleteImage(context, index);
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        image: DecorationImage(
                          image: FileImage(File(imagesPath[index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            TextField(
              maxLines: null,
              controller: _contentController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Note here',
                border: InputBorder.none,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSave,
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<dynamic> onDeleteNote(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to delete this note?'),
          actions: [
            ElevatedButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () {
                if (widget.isForEdit) {
                  // Provider.of<NoteProvider>(context, listen: false).clear();
                  Provider.of<NoteProvider>(context, listen: false)
                      .removeItem(widget.note?.id ?? '');
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note is deleted!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> onDeleteImage(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to delete this image?'),
          actions: [
            ElevatedButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  imagesPath.removeAt(index);
                  log(imagesPath.toString());
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image is deleted!'),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}
