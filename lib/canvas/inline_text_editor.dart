import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';
import '../state/history_manager.dart';
import '../commands/text_edit_command.dart';
import '../commands/delete_element_command.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class InlineTextEditor extends ConsumerStatefulWidget {
  final String elementId;
  const InlineTextEditor({super.key, required this.elementId});

  @override
  ConsumerState<InlineTextEditor> createState() => _InlineTextEditorState();
}

class _InlineTextEditorState extends ConsumerState<InlineTextEditor> {
  late TextEditingController _controller;
  late String _originalContent;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = ref.read(editorProvider);
    final element = state.document.elements.whereType<VxText>().firstWhere((e) => e.id == widget.elementId);
    _originalContent = element.content;
    _controller = TextEditingController(text: _originalContent);

    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commitAndClose();
    });
  }

  void _commitAndClose() {
    final state = ref.read(editorProvider);
    final current = state.document.elements.whereType<VxText>()
        .firstWhere((e) => e.id == widget.elementId);
    final newContent = _controller.text;

    // The live preview has already written newContent into the document, so the
    // command's "old" element has to be rebuilt from the content captured when
    // editing started. Passing the *current* element made old == new, which
    // recorded an undo step that reversed nothing (finding P1-6).
    final original = current.copyWith(content: _originalContent);

    if (newContent.trim().isEmpty) {
      ref.read(historyProvider).execute(DeleteElementCommand([current]));
    } else if (newContent != _originalContent) {
      ref.read(historyProvider).execute(
        TextEditCommand(
          oldElement: original,
          newElement: current.copyWith(content: newContent),
        ),
      );
    }
    ref.read(editorProvider.notifier).cancelTextEditing();
  }

  void _cancelAndClose() {
    _controller.text = _originalContent;
    ref.read(editorProvider.notifier).previewTextContent(widget.elementId, _originalContent);
    ref.read(editorProvider.notifier).cancelTextEditing();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final element = state.document.elements.whereType<VxText>().firstWhere((e) => e.id == widget.elementId);

    // Calculate position taking into account pan, zoom, and element transform
    // Note: for simplicity, we assume text transform is translation only in this MVP,
    // or we just place the text box where the origin is.

    final transform = element.transform;
    final pos = transform.transform3(Vector3(element.x, element.y, 0));

    final screenX = pos.x * state.viewport.zoom + state.viewport.pan.dx;
    final screenY = pos.y * state.viewport.zoom + state.viewport.pan.dy;

    return Positioned(
      left: screenX,
      top: screenY,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
          SingleActivator(LogicalKeyboardKey.enter, control: true): const ActivateIntent(),
        },
        child: Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) {
              _cancelAndClose();
              return null;
            }),
            ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
              _commitAndClose();
              return null;
            }),
          },
          child: Material(
            color: Colors.transparent,
            child: IntrinsicWidth(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(4),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: element.style.copyWith(
                  fontSize: element.style.fontSize! * state.viewport.zoom,
                ),
                onChanged: (value) {
                  ref.read(editorProvider.notifier).previewTextContent(widget.elementId, value);
                },
                onSubmitted: (_) => _commitAndClose(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
