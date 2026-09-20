import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vx_element.dart';
import '../../state/editor_notifier.dart';
import '../../state/history_manager.dart';
import '../../commands/update_element_command.dart';

class FillStrokeSection extends ConsumerWidget {
  final VxElement element;

  const FillStrokeSection({super.key, required this.element});

  VxElement _applyFill(VxFill newFill) {
    return element.map(
      rect: (e) => e.copyWith(fill: newFill),
      ellipse: (e) => e.copyWith(fill: newFill),
      path: (e) => e.copyWith(fill: newFill),
      compound: (e) => e.copyWith(fill: newFill),
      text: (e) => e,
      group: (e) => e,
      use: (e) => e,
      symbol: (e) => e,
    );
  }

  VxElement _applyStroke(VxStroke newStroke) {
    return element.map(
      rect: (e) => e.copyWith(stroke: newStroke),
      ellipse: (e) => e.copyWith(stroke: newStroke),
      path: (e) => e.copyWith(stroke: newStroke),
      compound: (e) => e.copyWith(stroke: newStroke),
      text: (e) => e,
      group: (e) => e,
      use: (e) => e,
      symbol: (e) => e,
    );
  }

  VxStroke _getCurrentStroke() {
    return element.map(
      rect: (e) => e.stroke,
      ellipse: (e) => e.stroke,
      path: (e) => e.stroke,
      compound: (e) => e.stroke,
      text: (e) => const VxStroke(color: Colors.black, width: 0, cap: StrokeCap.butt, join: StrokeJoin.miter),
      group: (e) => const VxStroke(color: Colors.black, width: 0, cap: StrokeCap.butt, join: StrokeJoin.miter),
      use: (e) => const VxStroke(color: Colors.black, width: 0, cap: StrokeCap.butt, join: StrokeJoin.miter),
      symbol: (e) => const VxStroke(color: Colors.black, width: 0, cap: StrokeCap.butt, join: StrokeJoin.miter),
    );
  }

  /// Show color picker. Live-previews changes, but only commits to undo history on dialog close.
  void _showColorPicker(BuildContext context, WidgetRef ref, Color initialColor, VxElement Function(Color color) applyColor, String actionName) {
    final originalElement = element; // Snapshot before any changes
    Color lastColor = initialColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (color) {
                lastColor = color;
                // Live preview — direct update without undo
                final updated = applyColor(color);
                ref.read(editorProvider.notifier).updateElement(updated);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                // Commit to undo history on close
                final finalElement = applyColor(lastColor);
                // Revert to original first, then execute command
                ref.read(editorProvider.notifier).updateElement(originalElement);
                ref.read(historyProvider).execute(UpdateElementCommand(
                  oldElements: [originalElement],
                  newElements: [finalElement],
                  actionName: actionName,
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (element is VxText || element is VxGroup) return const SizedBox.shrink();

    VxFill currentFill = const VxFill.none();
    Color strokeColor = Colors.transparent;
    double strokeWidth = 1.0;

    element.mapOrNull(
      rect: (e) {
        currentFill = e.fill;
        strokeColor = e.stroke.color;
        strokeWidth = e.stroke.width;
      },
      ellipse: (e) {
        currentFill = e.fill;
        strokeColor = e.stroke.color;
        strokeWidth = e.stroke.width;
      },
      path: (e) {
        currentFill = e.fill;
        strokeColor = e.stroke.color;
        strokeWidth = e.stroke.width;
      },
      compound: (e) {
        currentFill = e.fill;
        strokeColor = e.stroke.color;
        strokeWidth = e.stroke.width;
      },
    );

    String fillType = currentFill.when(
      solid: (_) => 'Solid',
      linear: (_, __, ___, ____) => 'Linear',
      radial: (_, __, ___, ____) => 'Radial',
      none: () => 'None',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('FILL & STROKE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, letterSpacing: 1.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fill Type', style: TextStyle(color: Colors.white70, fontSize: 12)),
              DropdownButton<String>(
                value: fillType,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                underline: const SizedBox(),
                items: ['Solid', 'Linear', 'Radial', 'None'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  VxFill newFill;
                  if (val == 'None') newFill = const VxFill.none();
                  else if (val == 'Solid') newFill = const VxFill.solid(color: Colors.grey);
                  else if (val == 'Linear') {
                    // Gradients default to objectBoundingBox so the direction
                    // looks the same on any shape, whatever its size.
                    newFill = const VxFill.linear(
                      units: GradientUnits.objectBoundingBox,
                      start: Offset(0, 0),
                      end: Offset(1, 1),
                      stops: [ColorStop(offset: 0, color: Colors.blue), ColorStop(offset: 1, color: Colors.red)]
                    );
                  } else {
                    newFill = const VxFill.radial(
                      units: GradientUnits.objectBoundingBox,
                      center: Offset(0.5, 0.5),
                      radius: 0.5,
                      stops: [ColorStop(offset: 0, color: Colors.blue), ColorStop(offset: 1, color: Colors.red)]
                    );
                  }
                  final updated = _applyFill(newFill);
                  ref.read(historyProvider).execute(UpdateElementCommand(
                    oldElements: [element],
                    newElements: [updated],
                    actionName: 'Change fill type',
                  ));
                },
              ),
            ],
          ),
        ),
        if (currentFill is SolidFill)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fill', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Row(
                  children: [
                    Text('#${(currentFill as SolidFill).color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showColorPicker(
                        context, ref, (currentFill as SolidFill).color,
                        (color) => _applyFill(VxFill.solid(color: color)),
                        'Change fill color',
                      ),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: (currentFill as SolidFill).color,
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (currentFill is LinearFill || currentFill is RadialFill)
          ..._buildGradientStops(context, ref, currentFill),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stroke', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Row(
                children: [
                  Text(strokeColor.value == 0 ? 'None' : strokeWidth.toStringAsFixed(1), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showColorPicker(
                      context, ref, strokeColor.value == 0 ? Colors.white : strokeColor,
                      (color) => _applyStroke(_getCurrentStroke().copyWith(color: color)),
                      'Change stroke color',
                    ),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: strokeColor.value == 0 ? Colors.transparent : strokeColor,
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: strokeColor.value == 0 ? const Icon(Icons.add, size: 14, color: Colors.white54) : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Stroke width input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Width', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(
                width: 60,
                height: 24,
                child: TextField(
                  controller: TextEditingController(text: strokeWidth.toStringAsFixed(1)),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) {
                    final w = double.tryParse(val);
                    if (w != null) {
                      final updated = _applyStroke(_getCurrentStroke().copyWith(width: w));
                      ref.read(historyProvider).execute(UpdateElementCommand(
                        oldElements: [element],
                        newElements: [updated],
                        actionName: 'Change stroke width',
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGradientStops(BuildContext context, WidgetRef ref, VxFill fill) {
    List<ColorStop> stops = [];
    if (fill is LinearFill) stops = fill.stops;
    if (fill is RadialFill) stops = fill.stops;

    return [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Text('Gradient Stops', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ),
      for (int i = 0; i < stops.length; i++)
        ListTile(
          dense: true,
          title: Text('Stop ${i + 1} (${(stops[i].offset * 100).toInt()}%)', style: const TextStyle(color: Colors.white, fontSize: 12)),
          trailing: GestureDetector(
            onTap: () {
              final capturedI = i;
              _showColorPicker(
                context, ref, stops[capturedI].color,
                (color) {
                  final newStops = List<ColorStop>.from(stops);
                  newStops[capturedI] = newStops[capturedI].copyWith(color: color);
                  VxFill newFill;
                  if (fill is LinearFill) newFill = fill.copyWith(stops: newStops);
                  else newFill = (fill as RadialFill).copyWith(stops: newStops);
                  return _applyFill(newFill);
                },
                'Change gradient stop color',
              );
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: stops[i].color,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
    ];
  }
}
