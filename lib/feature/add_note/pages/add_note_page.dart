import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/core/card_colors.dart';
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
      if (!widget.isForEdit) {
        final noteContent = _contentController.text.trim().split('\n');
        final title = noteContent[0];
        final content = noteContent.sublist(1).join('\n');
        final note = Note(
          images: imagesPath,
          id: DateTime.now().toString(),
          title: title,
          content: content,
        );
        await Provider.of<NoteProvider>(context, listen: false).addNote(
          note: note,
        );
        log(title);
        log(content);
      } else {
        // final noteContent = _contentController.text.trim().split('\n');
        // final title = noteContent[0];
        // final content = noteContent.skip(0).join('\n');
        // final note = _note?.copyWith(
        //   images: imagesPath,
        //   id: DateTime.now().toString(),
        //   title: title,
        //   content: content,
        // );
        // await Provider.of<NoteProvider>(context, listen: false).addNote(
        //   note: note!,
        //   isForEdit: true,
        // );
      }
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
        CardColors
            .cardsColor[math.Random().nextInt(CardColors.cardsColor.length)];
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
              if (widget.isForEdit) {
                Provider.of<NoteProvider>(context, listen: false)
                    .removeItem(widget.note?.id ?? '');
              }
              Navigator.of(context).pop();
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
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        image: FileImage(File(imagesPath[index])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            TextField(
              maxLines: null,
              controller: _contentController,
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
}
