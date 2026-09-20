import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/editor_state.dart';
import '../state/editor_notifier.dart';
import 'tool.dart';
import 'select_tool.dart';
import 'rect_tool.dart';
import 'ellipse_tool.dart';
import 'polygon_tool.dart';
import 'star_tool.dart';
import 'line_tool.dart';
import 'freehand_tool.dart';
import 'node_tool.dart';
import 'text_tool.dart';
import 'hand_tool.dart';
import 'pen_tool.dart';

final _selectTool = SelectTool();
final _rectTool = RectTool();
final _ellipseTool = EllipseTool();
final _polygonTool = PolygonTool();
final _starTool = StarTool();
final _lineTool = LineTool();
final _freehandTool = FreehandTool();
final _nodeTool = NodeTool();
final _textTool = TextTool();
final _handTool = HandTool();
final _penTool = PenTool();

final toolProvider = Provider<Tool>((ref) {
  final activeTool = ref.watch(editorProvider.select((state) => state.activeTool));
  switch (activeTool) {
    case ActiveTool.select: return _selectTool;
    case ActiveTool.rect: return _rectTool;
    case ActiveTool.ellipse: return _ellipseTool;
    case ActiveTool.polygon: return _polygonTool;
    case ActiveTool.star: return _starTool;
    case ActiveTool.line: return _lineTool;
    case ActiveTool.freehand: return _freehandTool;
    case ActiveTool.node: return _nodeTool;
    case ActiveTool.text: return _textTool;
    case ActiveTool.hand: return _handTool;
    case ActiveTool.pen: return _penTool;
  }
});
