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
    if (document.artboards.isEmpty) return true;
    final index = document.activePageIndex.clamp(0, document.artboards.length - 1);
    final activeId = document.artboards[index].id;
    return element.artboardId == null || element.artboardId == activeId;
  }

  static String _activeArtboardKey(VxDocument document) {
    if (document.artboards.isEmpty) return 'none';
    final index = document.activePageIndex.clamp(0, document.artboards.length - 1);
    return document.artboards[index].id;
  }
}
