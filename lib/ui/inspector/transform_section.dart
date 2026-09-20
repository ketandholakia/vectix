import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vx_element.dart';
import '../../state/editor_notifier.dart';
import '../../state/history_manager.dart';
import '../../commands/update_element_command.dart';

class TransformSection extends ConsumerStatefulWidget {
  final VxElement element;

  const TransformSection({super.key, required this.element});

  @override
  ConsumerState<TransformSection> createState() => _TransformSectionState();
}

class _TransformSectionState extends ConsumerState<TransformSection> {
  late TextEditingController _xController;
  late TextEditingController _yController;
  late TextEditingController _wController;
  late TextEditingController _hController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(TransformSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      _syncControllers();
    }
  }

  void _initControllers() {
    _xController = TextEditingController();
    _yController = TextEditingController();
    _wController = TextEditingController();
    _hController = TextEditingController();
    _syncControllers();
  }

  void _syncControllers() {
    double x = 0, y = 0, w = 0, h = 0;
    
    widget.element.mapOrNull(
      rect: (e) { x = e.x; y = e.y; w = e.width; h = e.height; },
      ellipse: (e) { x = e.cx - e.rx; y = e.cy - e.ry; w = e.rx * 2; h = e.ry * 2; },
      text: (e) { x = e.x; y = e.y; },
    );

    if ((double.tryParse(_xController.text) ?? 0.0) != x) {
      _xController.text = x.toStringAsFixed(1);
    }
    if ((double.tryParse(_yController.text) ?? 0.0) != y) {
      _yController.text = y.toStringAsFixed(1);
    }
    if ((double.tryParse(_wController.text) ?? 0.0) != w) {
      _wController.text = w.toStringAsFixed(1);
    }
    if ((double.tryParse(_hController.text) ?? 0.0) != h) {
      _hController.text = h.toStringAsFixed(1);
    }
  }

  void _applyTransform() {
    final x = double.tryParse(_xController.text) ?? 0.0;
    final y = double.tryParse(_yController.text) ?? 0.0;
    final w = double.tryParse(_wController.text) ?? 0.0;
    final h = double.tryParse(_hController.text) ?? 0.0;

    final updated = widget.element.map(
      rect: (e) => e.copyWith(x: x, y: y, width: w, height: h),
      ellipse: (e) => e.copyWith(cx: x + w / 2, cy: y + h / 2, rx: w / 2, ry: h / 2),
      path: (e) => e,
      text: (e) => e.copyWith(x: x, y: y),
      group: (e) => e,
      compound: (e) => e,
      use: (e) => e,
      symbol: (e) => e,
    );
    
    ref.read(historyProvider).execute(UpdateElementCommand(
      oldElements: [widget.element],
      newElements: [updated],
      actionName: 'Change transform',
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.element is VxPath || widget.element is VxGroup || widget.element is VxCompound || widget.element is VxUse || widget.element is VxSymbol) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('POSITION & SIZE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, letterSpacing: 1.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildField('X', _xController),
              const SizedBox(height: 8),
              _buildField('Y', _yController),
              const SizedBox(height: 8),
              _buildField('W', _wController),
              const SizedBox(height: 8),
              _buildField('H', _hController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(
          child: SizedBox(
            height: 24,
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]'))],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: const Color(0xFF1E1E1E), // Darker input field
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _applyTransform(),
              onEditingComplete: _applyTransform,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _wController.dispose();
    _hController.dispose();
    super.dispose();
  }
}

