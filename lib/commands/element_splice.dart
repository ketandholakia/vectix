import '../models/vx_element.dart';

/// Helpers for structural commands that replace a set of elements with a single
/// container (group, compound) and must be able to reverse that exactly.
///
/// Element order in `VxDocument.elements` is z-order, so an undo that restores
/// the right elements in the wrong order is still a visible bug: layers jump.
/// GroupCommand, UngroupCommand and BooleanOperationCommand each used to append
/// the restored elements to the end of the list, so undoing a group reordered
/// the document (found by the C1 undo-fidelity test).
///
/// Kept as pure functions on lists so the ordering rule is explicit and unit
/// testable, instead of being re-derived inside each command.

/// Indices of [ids] within [elements], or -1 where absent.
List<int> indicesOf(List<VxElement> elements, Iterable<String> ids) {
  final order = {for (var i = 0; i < elements.length; i++) elements[i].id: i};
  return [for (final id in ids) order[id] ?? -1];
}

/// [elements] without the given ids, keeping the surviving order.
List<VxElement> withoutIds(List<VxElement> elements, Set<String> ids) =>
    elements.where((element) => !ids.contains(element.id)).toList();

/// Where a container that replaces [sourceIndices] should sit in the pruned
/// list so that it occupies the z-position of its topmost source.
int containerInsertIndex(List<int> sourceIndices, List<VxElement> elements) {
  final valid = sourceIndices.where((index) => index >= 0).toList();
  if (valid.isEmpty) return elements.length;
  final top = valid.reduce((a, b) => a > b ? a : b);
  final removed = valid.toSet();
  var keptBefore = 0;
  for (var i = 0; i < top; i++) {
    if (!removed.contains(i)) keptBefore++;
  }
  return keptBefore;
}

/// Removes [removedIds] and inserts [inserted] at [index] (clamped).
List<VxElement> spliceElements(
  List<VxElement> elements, {
  required Set<String> removedIds,
  required int index,
  required List<VxElement> inserted,
}) {
  final result = withoutIds(elements, removedIds);
  final at = index.clamp(0, result.length);
  result.insertAll(at, inserted);
  return result;
}

/// Puts [entries] back at their recorded indices.
///
/// Inserted in **ascending** index order: once every element with a lower index
/// is back in place, positions `0..k-1` match the original list, so inserting at
/// `k` restores that element exactly where it was. (Inserting in descending
/// order looks equivalent but is only accidentally right when the index clamps
/// to the end of the list.) Indices that no longer exist fall back to the end.
List<VxElement> reinsertElements(
  List<VxElement> elements,
  List<MapEntry<int, VxElement>> entries,
) {
  final ordered = [...entries]..sort((a, b) => a.key.compareTo(b.key));
  final result = [...elements];
  for (final entry in ordered) {
    if (entry.key >= 0 && entry.key <= result.length) {
      result.insert(entry.key, entry.value);
    } else {
      result.add(entry.value);
    }
  }
  return result;
}
