import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vx_element.dart';
import '../../state/editor_notifier.dart';
import '../../state/history_manager.dart';
import '../../commands/update_element_command.dart';

class TextPropertiesSection extends ConsumerWidget {
  final VxText element;

  const TextPropertiesSection({super.key, required this.element});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontWeightOptions = <MapEntry<String, int?>>[
      const MapEntry('Normal', null),
      const MapEntry('W400', 400),
      const MapEntry('W500', 500),
      const MapEntry('Bold', 700),
      const MapEntry('W900', 900),
    ];

    final fontFamilyOptions = <String>[
      'Roboto',
      'Open Sans',
      'Lato',
      'Montserrat',
      'Oswald',
      'Source Sans Pro',
      'Slabo 27px',
      'Raleway',
      'PT Sans',
      'Merriweather',
      'Noto Sans',
      'Nunito',
      'Concert One',
      'Prompt',
      'Work Sans',
    ];

    TextAlign currentAlign = element.align;
    int? currentWeight = element.fontWeightValue;
    String currentFontFamily = element.style.fontFamily ?? 'Roboto';
    if (!fontFamilyOptions.contains(currentFontFamily)) {
      currentFontFamily = 'Roboto';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Text properties',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: DropdownButtonFormField<String>(
            value: currentFontFamily,
            dropdownColor: const Color(0xFF1E1E1E),
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Font Family',
            ),
            items: fontFamilyOptions
                .map(
                  (font) => DropdownMenuItem<String>(
                    value: font,
                    child: Text(font),
                  ),
                )
                .toList(),
            onChanged: (value) => _updateText(
              ref,
              style: element.style.copyWith(fontFamily: value),
            ),
          ),
        ),
        _numberField(
          label: 'Size',
          value: element.style.fontSize?.toString() ?? '24',
          onChanged: (val) => _updateText(
            ref,
            style: element.style.copyWith(
              fontSize: double.tryParse(val) ?? element.style.fontSize,
            ),
          ),
        ),
        _numberField(
          label: 'Letter spacing',
          value: element.letterSpacing?.toString() ?? '',
          onChanged: (val) =>
              _updateText(ref, letterSpacing: double.tryParse(val)),
        ),
        _numberField(
          label: 'Word spacing',
          value: element.wordSpacing?.toString() ?? '',
          onChanged: (val) =>
              _updateText(ref, wordSpacing: double.tryParse(val)),
        ),
        _numberField(
          label: 'Line height',
          value: element.lineHeight?.toString() ?? '',
          onChanged: (val) =>
              _updateText(ref, lineHeight: double.tryParse(val)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: DropdownButtonFormField<TextAlign>(
            value: currentAlign,
            dropdownColor: const Color(0xFF1E1E1E),
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Align',
            ),
            items: const [
              DropdownMenuItem(value: TextAlign.start, child: Text('Start')),
              DropdownMenuItem(value: TextAlign.center, child: Text('Center')),
              DropdownMenuItem(value: TextAlign.end, child: Text('End')),
              DropdownMenuItem(value: TextAlign.left, child: Text('Left')),
              DropdownMenuItem(value: TextAlign.right, child: Text('Right')),
              DropdownMenuItem(
                value: TextAlign.justify,
                child: Text('Justify'),
              ),
            ],
            onChanged: (value) {
              if (value != null) _updateText(ref, align: value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: DropdownButtonFormField<int?>(
            value: currentWeight,
            dropdownColor: const Color(0xFF1E1E1E),
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Weight',
            ),
            items: fontWeightOptions
                .map(
                  (entry) => DropdownMenuItem<int?>(
                    value: entry.value,
                    child: Text(entry.key),
                  ),
                )
                .toList(),
            onChanged: (value) => _updateText(ref, fontWeightValue: value),
          ),
        ),
        _numberField(
          label: 'Max lines',
          value: element.maxLines.toString(),
          onChanged: (val) => _updateText(
            ref,
            maxLines: int.tryParse(val) ?? element.maxLines,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(editorProvider.notifier).startTextEditing(element.id);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Text Content'),
          ),
        ),
      ],
    );
  }

  Widget _numberField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(),
              ),
              onSubmitted: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _updateText(
    WidgetRef ref, {
    TextStyle? style,
    TextAlign? align,
    double? letterSpacing,
    double? wordSpacing,
    double? lineHeight,
    int? fontWeightValue,
    FontStyle? fontStyle,
    int? maxLines,
  }) {
    final updated = element.copyWith(
      style: style ?? element.style,
      align: align ?? element.align,
      letterSpacing: letterSpacing ?? element.letterSpacing,
      wordSpacing: wordSpacing ?? element.wordSpacing,
      lineHeight: lineHeight ?? element.lineHeight,
      fontWeightValue: fontWeightValue ?? element.fontWeightValue,
      fontStyle: fontStyle ?? element.fontStyle,
      maxLines: maxLines ?? element.maxLines,
    );
    ref.read(historyProvider).execute(
          UpdateElementCommand(
            oldElements: [element],
            newElements: [updated],
            actionName: 'Update text properties',
          ),
        );
  }
}
