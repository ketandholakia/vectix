import '../models/vx_document.dart';
import '../models/vx_element.dart';

class SceneIndex {
  final VxDocument document;
  late final String activeArtboardKey;
  late final List<VxElement> activeElements;

  SceneIndex._(this.document, this.activeArtboardKey, this.activeElements);

  static final Map<String, SceneIndex> _cache = {};

  static SceneIndex of(VxDocument document) {
    final key = _activeArtboardKey(document);
    final cacheKey = '${document.hashCode}|$key|${document.activePageIndex}';
    return _cache.putIfAbsent(cacheKey, () {
      final activeElements = document.elements
          .where((element) => _belongsToActiveArtboard(element, document))
          .toList(growable: false);
      return SceneIndex._(document, key, activeElements);
    });
  }

  static bool _belongsToActiveArtboard(VxElement element, VxDocument document) {
    return belongsToArtboard(element, document, activeArtboard(document)?.id);
  }

  /// The artboard currently being edited, or null when the document has none.
  static VxArtboard? activeArtboard(VxDocument document) {
    if (document.artboards.isEmpty) return null;
    final index = document.activePageIndex.clamp(
      0,
      document.artboards.length - 1,
    );
    return document.artboards[index];
  }

  /// Whether [element] is drawn on the artboard with [artboardId].
  ///
  /// An element with a null `artboardId` belongs to every artboard; when the
  /// document has no artboards at all, everything belongs. This is the single
  /// source of truth for the rule — the canvas, PNG, PDF and SVG export paths
  /// each had their own copy, and SVG export was missing it entirely, which is
  /// how it ended up writing every artboard's artwork into one file (P1-9).
  static bool belongsToArtboard(
    VxElement element,
    VxDocument document,
    String? artboardId,
  ) {
    if (document.artboards.isEmpty) return true;
    if (artboardId == null) return element.artboardId == null;
    return element.artboardId == null || element.artboardId == artboardId;
  }

  /// The elements visible on [artboardId], in document order.
  static List<VxElement> elementsForArtboard(
    VxDocument document,
    String? artboardId,
  ) => document.elements
      .where((element) => belongsToArtboard(element, document, artboardId))
      .toList(growable: false);

  static String _activeArtboardKey(VxDocument document) {
    if (document.artboards.isEmpty) return 'none';
    final index = document.activePageIndex.clamp(0, document.artboards.length - 1);
    return document.artboards[index].id;
  }
}
