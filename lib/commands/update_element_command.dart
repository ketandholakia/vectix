import 'command.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';

class UpdateElementCommand implements Command {
  final List<VxElement> oldElements;
  final List<VxElement> newElements;
  final String actionName;

  const UpdateElementCommand({
    required this.oldElements,
    required this.newElements,
    this.actionName = 'Update element(s)',
  });

  @override
  void execute(EditorNotifier editor) {
    editor.replaceElements(
      _replace(editor.state.document.elements, newElements),
    );
  }

  @override
  void undo(EditorNotifier editor) {
    editor.replaceElements(
      _replace(editor.state.document.elements, oldElements),
    );
  }

  @override
  String get description => actionName;

  List<VxElement> _replace(List<VxElement> current, List<VxElement> updates) {
    final map = {for (final e in updates) e.id: e};
    return current.map((e) {
      final updated = map[e.id];
      if (updated != null) return updated;
      return e.when(
        rect:
            (
              id,
              artboardId,
              x,
              y,
              width,
              height,
              transform,
              fill,
              stroke,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => e,
        ellipse:
            (
              id,
              artboardId,
              cx,
              cy,
              rx,
              ry,
              transform,
              fill,
              stroke,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => e,
        path:
            (
              id,
              artboardId,
              segments,
              transform,
              fill,
              stroke,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => e,
        text:
            (
              id,
              artboardId,
              content,
              x,
              y,
              style,
              align,
              letterSpacing,
              wordSpacing,
              lineHeight,
              fontWeightValue,
              fontStyle,
              maxLines,
              transform,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => e,
        group:
            (
              id,
              artboardId,
              children,
              transform,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => VxElement.group(
              id: id,
              artboardId: artboardId,
              children: _replace(children, updates),
              transform: transform,
              opacity: opacity,
              locked: locked,
              visible: visible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        compound:
            (
              id,
              artboardId,
              operation,
              children,
              transform,
              fill,
              stroke,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => VxElement.compound(
              id: id,
              artboardId: artboardId,
              operation: operation,
              children: _replace(children, updates),
              transform: transform,
              fill: fill,
              stroke: stroke,
              opacity: opacity,
              locked: locked,
              visible: visible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        use:
            (
              id,
              artboardId,
              href,
              transform,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => e,
        symbol:
            (
              id,
              artboardId,
              children,
              transform,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => VxElement.symbol(
              id: id,
              artboardId: artboardId,
              children: _replace(children, updates),
              transform: transform,
              opacity: opacity,
              locked: locked,
              visible: visible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
      );
    }).toList();
  }
}
