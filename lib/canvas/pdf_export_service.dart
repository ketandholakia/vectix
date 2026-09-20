import '../models/vx_document.dart';
import 'scene_exporter.dart';

class PdfExportRequest {
  const PdfExportRequest({
    this.artboardIds,
    this.bleed = 0,
    this.cropMarks = false,
  });

  final List<String>? artboardIds;
  final double bleed;
  final bool cropMarks;
}

class PdfExportService {
  const PdfExportService();

  Future<void> export(
    VxDocument document, {
    List<String>? artboardIds,
    double bleed = 0,
    bool cropMarks = false,
  }) {
    return SceneExporter.exportToPdf(
      document,
      artboardIds: artboardIds,
      bleed: bleed,
      cropMarks: cropMarks,
    );
  }
}
