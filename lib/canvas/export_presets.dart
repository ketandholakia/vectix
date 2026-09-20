enum ExportPreset { screen, print, production }

class PngExportProfile {
  const PngExportProfile({
    required this.label,
    required this.scale,
    required this.transparent,
  });

  final String label;
  final double scale;
  final bool transparent;

  Map<String, dynamic> toJson() => {
    'label': label,
    'scale': scale,
    'transparent': transparent,
  };

  factory PngExportProfile.fromJson(Map<String, dynamic> json) {
    return PngExportProfile(
      label: json['label'] as String,
      scale: (json['scale'] as num).toDouble(),
      transparent: json['transparent'] as bool,
    );
  }
}

class PdfExportProfile {
  const PdfExportProfile({
    required this.label,
    required this.bleed,
    required this.cropMarks,
  });

  final String label;
  final double bleed;
  final bool cropMarks;

  Map<String, dynamic> toJson() => {
    'label': label,
    'bleed': bleed,
    'cropMarks': cropMarks,
  };

  factory PdfExportProfile.fromJson(Map<String, dynamic> json) {
    return PdfExportProfile(
      label: json['label'] as String,
      bleed: (json['bleed'] as num).toDouble(),
      cropMarks: json['cropMarks'] as bool,
    );
  }
}

const List<PngExportProfile> pngExportProfiles = [
  PngExportProfile(label: 'Screen', scale: 1.0, transparent: false),
  PngExportProfile(label: 'Transparent', scale: 1.0, transparent: true),
  PngExportProfile(label: 'Print 3x', scale: 3.0, transparent: false),
];

const List<PdfExportProfile> pdfExportProfiles = [
  PdfExportProfile(label: 'Screen PDF', bleed: 0, cropMarks: false),
  PdfExportProfile(label: 'Print PDF', bleed: 3, cropMarks: true),
  PdfExportProfile(label: 'Production PDF', bleed: 6, cropMarks: true),
];
