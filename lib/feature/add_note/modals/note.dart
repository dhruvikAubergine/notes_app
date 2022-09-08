import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class Note extends Equatable {
  const Note({this.id, this.title, this.content, this.images});

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? title;
  @HiveField(2)
  final String? content;
  @HiveField(3)
  final List<String>? images;

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? images,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id, title, content, images];
}
