import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../state/editor_notifier.dart';
import '../state/history_manager.dart';
import '../commands/add_element_command.dart';
import '../models/vx_element.dart';
import 'clipboard_service.dart';

class ShortcutHandler extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onSave;

  const ShortcutHandler({super.key, required this.child, this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final isCtrlOrCmd = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
                              HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight) ||
                              HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) ||
                              HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaRight);

          if (isCtrlOrCmd) {
            if (event.logicalKey == LogicalKeyboardKey.keyC) {
              _copy(ref);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
              _paste(ref);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              _duplicate(ref);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
              final isShift = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
                              HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
              if (isShift) {
                ref.read(historyProvider).redo();
              } else {
                ref.read(historyProvider).undo();
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              onSave?.call();
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.delete || event.logicalKey == LogicalKeyboardKey.backspace) {
            // Wait, we need to make sure we aren't focused in a text field!
            // But since this is a top level Focus, if a text field is focused, it handles it first if we let it.
            // Actually, if we intercept here, it might block text field delete.
            // So we'll skip delete/backspace here and keep it as is, or handle it carefully.
            return KeyEventResult.ignored;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  void _copy(WidgetRef ref) {
    final state = ref.read(editorProvider);
    if (state.selectedIds.isEmpty) return;

    final elementsToCopy = state.document.elements.where((e) => state.selectedIds.contains(e.id)).toList();
    ref.read(clipboardProvider.notifier).state = elementsToCopy;
  }

  void _paste(WidgetRef ref) {
    final clipboard = ref.read(clipboardProvider);
    if (clipboard.isEmpty) return;

    final uuid = const Uuid();
    final newElements = <VxElement>[];
    final newSelectedIds = <String>{};

    for (final el in clipboard) {
      final newId = uuid.v4();
      final offsetTransform = el.transform.clone()..translate(10.0, 10.0);
      
      VxElement updated = el.when(
        rect: (id, artboardId, x, y, w, h, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.rect(id: newId, artboardId: artboardId, x: x, y: y, width: w, height: h, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        ellipse: (id, artboardId, cx, cy, rx, ry, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.ellipse(id: newId, artboardId: artboardId, cx: cx, cy: cy, rx: rx, ry: ry, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        path: (id, artboardId, segs, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.path(id: newId, artboardId: artboardId, segments: segs, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        text: (id, artboardId, c, x, y, st, align, letterSpacing, wordSpacing, lineHeight, fontWeightValue, fontStyle, maxLines, t, opacity, locked, visible, clipPathId, maskId) => VxElement.text(
          id: newId,
          artboardId: artboardId,
          content: c,
          x: x,
          y: y,
          style: st,
          align: align,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          lineHeight: lineHeight,
          fontWeightValue: fontWeightValue,
          fontStyle: fontStyle,
          maxLines: maxLines,
          transform: offsetTransform,
          opacity: opacity,
          locked: locked,
          visible: visible,
          clipPathId: clipPathId,
          maskId: maskId,
        ),
        group: (id, artboardId, children, t, opacity, locked, visible, clipPathId, maskId) => VxElement.group(id: newId, artboardId: artboardId, children: children, transform: offsetTransform, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        compound: (id, artboardId, op, children, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.compound(id: newId, artboardId: artboardId, operation: op, children: children, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        use: (id, artboardId, href, t, opacity, locked, visible, clipPathId, maskId) => VxElement.use(id: newId, artboardId: artboardId, href: href, transform: offsetTransform, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        symbol: (id, artboardId, children, t, opacity, locked, visible, clipPathId, maskId) => VxElement.symbol(id: newId, artboardId: artboardId, children: children, transform: offsetTransform, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
      );
      
      newElements.add(updated);
      newSelectedIds.add(newId);
    }

    for (final el in newElements) {
      ref.read(historyProvider).execute(AddElementCommand(el));
    }
    
    ref.read(editorProvider.notifier).setSelection(newSelectedIds);
  }

  void _duplicate(WidgetRef ref) {
    _copy(ref);
    _paste(ref);
  }
}
