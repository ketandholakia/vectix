import 'package:flutter/material.dart';
import 'command.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';

class AlignCommand implements Command {
  final List<VxElement> oldElements;
  final List<VxElement> newElements;

  const AlignCommand(this.oldElements, this.newElements);

  @override
  void execute(EditorNotifier editor) {
    for (final el in newElements) {
      editor.updateElement(el);
    }
  }

  @override
  void undo(EditorNotifier editor) {
    for (final el in oldElements) {
      editor.updateElement(el);
    }
  }

  @override
  String get description => 'Align elements';
}
