import 'package:flutter_test/flutter_test.dart';
import 'package:vectix/canvas/export_presets.dart';

void main() {
  test('serializes export profiles for future user editing', () {
    final png = pngExportProfiles.first;
    final pdf = pdfExportProfiles.last;

    expect(PngExportProfile.fromJson(png.toJson()).label, png.label);
    expect(PdfExportProfile.fromJson(pdf.toJson()).bleed, pdf.bleed);
  });
}
