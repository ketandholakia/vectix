# Vectix

A local-first vector / SVG editor built with Flutter. Desktop and tablet, no account, no network.

Drawing tools, boolean operations, masks and clip paths, gradients, multi-artboard documents, and
SVG / PNG / PDF import-export — all backed by an undoable command stack.

---

## Status

**Pre-release, under active hardening.** The editor works, but SVG fidelity and performance are not
yet trustworthy for production files. The full audit — findings with `file:line` evidence, what is
genuinely working versus only assumed to work, and the phased plan — lives in
[`docs/vectix-deep-analysis-and-plan.md`](docs/vectix-deep-analysis-and-plan.md).

Do not rely on SVG round-trips for archival work yet; see *Known gaps* below.

## Requirements

- Flutter **3.44.0** stable (Dart SDK 3.12)
- Platform toolchains for whichever target you build

## Getting started

```bash
flutter pub get

# regenerate freezed / json_serializable code after changing a model
dart run build_runner build --delete-conflicting-outputs

flutter run -d windows     # or: macos, linux, android
```

Supported targets: Windows, macOS, Linux, Android. There is no `ios/` or `web/` project yet, though
some code already branches on `Platform.isIOS`.

## Tests

```bash
flutter test
flutter analyze --no-pub
```

The PNG golden in `test/goldens/` is generated on Windows and is sensitive to the Flutter/Skia
version — regenerate it deliberately rather than on a whim:

```bash
flutter test --dart-define=GENERATE_EXPORT_GOLDEN=true test/export_fixture_test.dart
```

## Project layout

```
lib/
  models/     VxDocument, VxElement (rect · ellipse · path · text · group · compound · use · symbol),
              fills, strokes, path segments, JSON converters
  state/      EditorNotifier (Riverpod) + EditorState + HistoryManager (command stack)
  commands/   one undoable Command per edit operation
  tools/      select · rect · ellipse · line · polygon · star · freehand · pen · text · node · hand
  canvas/     ScenePainter (draw) · HitTester (spatial index) · SceneIndex · SceneExporter (PNG/PDF)
  svg/        SvgImporter / SvgExporter
  ui/         editor screen, inspector panels, layers panel, tool sidebar
  services/   shortcuts, clipboard
test/         unit, round-trip and pixel-level rendering tests
```

### How it fits together

```
pointer event ──► Tool.onPointer*  ──► EditorNotifier.preview/commit
                                          │
                                          ├─► HistoryManager.execute(Command)   ← undo/redo
                                          └─► EditorState (Riverpod) ──► widgets + painters
                                                                          │
                                              ScenePainter ──► canvas
                                              SvgExporter / SceneExporter ──► files
```

Element trees are immutable `freezed` value objects. Every edit goes through a `Command`, which is
what makes undo/redo coherent; commands are the only supported way to mutate a document.

`VxDocument.defs` holds non-painted definitions (`<mask>`, `<clipPath>`, `<symbol>`) that
`maskId` / `clipPathId` / `VxUse.href` resolve against.

## Known gaps

Current, verified limitations — details and severity in the analysis report:

- Gradient geometry authored in the model is ignored by the canvas renderer, so the editor and the
  exported SVG disagree about gradient direction.
- Presentation-attribute inheritance from `<g>` is not applied on import, and the SVG default fill
  (black) is not honoured, so some artwork imports invisible.
- Colour parsing covers 6-digit hex and five names; `rgb()`/`hsl()`, 8-digit hex and most names are
  not handled.
- Export loses alpha, stroke caps/joins and `stroke-opacity`; SVG export ignores artboards.
- Text properties that the inspector exposes (letter spacing, line height, weight, …) are stored but
  not rendered.
- Performance work has not started: the spatial index and path caches are invalidated on every
  pointer move.

## Contributing

The report's §9 contains the ordered plan. If you pick something up, work one finding at a time and
land a test with it — the project's main historical problem was capabilities being marked done
without a test proving them.
