import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/editor_state.dart';
import '../../state/editor_notifier.dart';
import '../../tools/tool_provider.dart';

class ToolSidebar extends ConsumerWidget {
  final bool isHorizontal;
  
  const ToolSidebar({super.key, this.isHorizontal = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(editorProvider.select((s) => s.activeTool));

    final children = [
          _ToolButton(
            icon: Icons.near_me,
            tool: ActiveTool.select,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.select);
            },
          ),
          _ToolButton(
            icon: Icons.crop_square,
            tool: ActiveTool.rect,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.rect);
            },
          ),
          _ToolButton(
            icon: Icons.circle_outlined,
            tool: ActiveTool.ellipse,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.ellipse);
            },
          ),
          _ToolButton(
            icon: Icons.horizontal_rule,
            tool: ActiveTool.line,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.line);
            },
          ),
          _ToolButton(
            icon: Icons.hexagon_outlined,
            tool: ActiveTool.polygon,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.polygon);
            },
          ),
          _ToolButton(
            icon: Icons.stars,
            tool: ActiveTool.star,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.star);
            },
          ),
          _ToolButton(
            icon: Icons.gesture,
            tool: ActiveTool.freehand,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.freehand);
            },
          ),
          _ToolButton(
            icon: Icons.edit,
            tool: ActiveTool.freehand,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.freehand);
            },
          ),
          _ToolButton(
            icon: Icons.title,
            tool: ActiveTool.text,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.text);
            },
          ),
          _ToolButton(
            icon: Icons.device_hub,
            tool: ActiveTool.node,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.node);
            },
          ),
          _ToolButton(
            icon: Icons.pan_tool,
            tool: ActiveTool.hand,
            activeTool: activeTool,
            onPressed: () {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.hand);
            },
          ),
    ];

    if (isHorizontal) {
      return Container(
        height: 50,
        color: Colors.grey[850],
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children,
          ),
        ),
      );
    } else {
      return Container(
        width: 50,
        color: Colors.grey[850],
        child: SingleChildScrollView(
          child: Column(
            children: children,
          ),
        ),
      );
    }
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final ActiveTool tool;
  final ActiveTool activeTool;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.tool,
    required this.activeTool,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tool == activeTool;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: isActive ? Colors.white : Colors.white70,
        onPressed: onPressed,
      ),
    );
  }
}
