# Vectix — Deep Code Analysis & Next Development Plan

**Subject:** `vectix` Flutter vector/SVG editor — `D:\ketan\github\vectix`
**Analysis date:** 2026-09-20
**Toolchain used for verification:** Flutter 3.44.0 stable · Dart SDK 3.12.0 · Windows x64
**Scope:** full `lib/` (59 hand-written files / 10,864 lines + 5 generated files / 3,690 lines), `test/`, root tooling, build config.

---

## 0. Read this first — verification status

| Check | Command | Result |
|---|---|---|
| Static analysis | `flutter analyze --no-pub` | **508 issues: 3 errors, 66 warnings, 439 infos** — 0 errors in `lib/`, 3 errors in `test/` |
| Test suite | `flutter test` | **FAILS TO COMPILE** — 16 tests pass, but `test/export_fixture_test.dart` does not build, so the run exits with code 1 |
| App run / manual QA | not run in this session | **Not verified** — no runtime, interaction, or rendering check was performed |
| Version control | `git status` | **Not a git repository** (`.gitignore` exists, `.git` does not) |
| **P0-4 pixel proof** | `flutter test test/mask_defs_regression_test.dart` (probe, 2026-09-20) | **CONFIRMED** — imported tree holds 1 element (the group); mask source absent; centre pixel `rgba(255,107,107,255)` where a correct mask requires `alpha = 0` |
| Test suite after the 1-line fix in `test/export_fixture_test.dart` | `flutter test` | **17 passed, 1 skipped, exit 0** (was: does not compile) |

### 0.1 Progress log

| Commit | Change | Verified by |
|---|---|---|
| `162f432` | Baseline snapshot (`v0.9-pre-hardening`) — puts the project under version control for the first time | `git log`; 174 files, no build artifacts |
| `3e94022` | **P1-1** `matrix()` parsed with SVG column-major semantics | `test/svg_transform_test.dart` (rotation, skew, export→import) |
| `eacc6fa` | **P0-3** one owner per shortcut; Ctrl+S now saves the project | analyzer: 508 → 503 issues; single binding |
| `c7c46cd` | **P0-4** document definition registry; masks/clip-paths/symbols resolve; mask renderer switched to luminance→alpha | `test/mask_defs_regression_test.dart` (pixel assertions + pixel-identical round trip) |
| `843a241` | Regression tests enabled; masked golden regenerated (the old one encoded the unmasked render) | `flutter test`: **22 passed, 0 skipped** |
| `67db295` | Repo published publicly, app-only history (workspace files rewritten out) | remote refs = `refs/heads/master` only; CI green ×2 |
| _this batch_ | **P1-2 / P1-3 / P1-4** SVG defaults, presentation inheritance, colour grammar, rounded rects, stroke caps/joins/opacity/miter-limit, alpha-preserving export; painter now applies the text properties it was ignoring (**P1-5**, partial) | `test/svg_style_test.dart` (25 tests); `flutter test`: **47 passed** |
| _this batch_ | **P0-5** gradient geometry: `gradientUnits` modelled, canvas and PDF both render the authored direction, SVG export writes the real units | `test/gradient_geometry_test.dart` (14 tests incl. pixel direction); `flutter test`: **61 passed** |
| _this batch_ | **B6** fidelity corpus (27 SVG files, committed render hashes + a 100 % round-trip fidelity floor) — which immediately found and drove the fix for **P0-6** | corpus on first run: 4 files below floor → 27/27 at 100 % after the fix; `flutter test`: **64 passed** |

Still open from Phase A: lint ratchet (A4).
Still open from Phase B: B5 (artboard-aware SVG export).

The corpus is now the safety net for every remaining fidelity claim. Its first run paid for itself within minutes: it found a bug that made every straight line disappear from exported SVG files, which four batches of review and testing had missed.

**A new finding surfaced while fixing P0-4** — the mask renderer drew the mask geometry with `BlendMode.dstIn` and a white paint, i.e. *alpha* masking. The mask's colours were ignored, so a black shape inside a mask hid nothing even after the reference resolved. Real SVG `<mask>` is luminance-based. Fixed alongside the registry (`c7c46cd`); this is why the defect was invisible in code review and only appeared under pixel testing — reinforce B6 (corpus + render hashes) before trusting any other fidelity claim.

Everything below is either **read from source** (with `file:line` evidence) or **observed by running analyzer/tests**. Claims that need a running app are explicitly marked *needs runtime check* and are not asserted as fact.

---

## 1. Executive summary

Vectix is a **credible local-first vector editor MVP** with an unusually complete feature surface for its size: 11 tools, 8 element types (rect/ellipse/path/text/group/compound/use/symbol), artboards, boolean ops, masks & clip paths, gradients, dash arrays, SVG/PNG/PDF import-export, export presets, an inspector, a layers panel, and a real command-based undo stack. The model layer is the strongest part: `freezed` + `json_serializable` value objects, versioned documents, custom JSON converters for `Matrix4`/`Color`/`Offset`/`TextStyle`, and round-trip tests. That is genuinely good work.

The problem is not ambition or breadth. It is that **reliability was claimed rather than verified**. `development_plan.md` marks dozens of items "Done" (mask/clip import, symbol round-trip, PDF masks, performance pass) that either do not work, work only in one direction, or are unreachable from the UI. Running the analyzer and the test suite surfaces that immediately: the suite does not compile, and the one fidelity test that would have caught the mask bug has never actually run.

Four systemic issues account for most of the risk:

1. **Undo is not actually universal.** Roughly a dozen mutation paths write state directly and never touch `HistoryManager` (text creation, lock/hide toggles, all artboard operations, document resize, metadata). "One drag = one history item" holds; "every user action is undoable" does not.
2. **The element tree is traversed by hand ~40 times** through positional `freezed` `when()` lambdas with 9–19 wildcard parameters. This is the single biggest maintainability and correctness hazard in the codebase — it is why 292 of the 508 analyzer issues exist, and why adding one model field requires ~12 coordinated edits that the compiler cannot check.
3. **The performance architecture is inverted.** The spatial index and path caches are rebuilt or discarded on every pointer move, while repaint decisions run a *deep structural comparison of the entire document*. The caches currently cost more than they save. *(needs runtime profiling to quantify — this is a code-path reading, not a measured number.)*
4. **SVG fidelity has concrete, reproducible data-loss bugs** — transposed `matrix()` parsing, dropped `<defs>` content, wrong fill defaults, ignored gradient geometry, lost stroke caps/joins/alpha. Vectix cannot yet be trusted as an SVG round-trip tool.

**Verdict:** strong prototype, **not production-safe**. With a focused 4–6 week hardening effort the core is very salvageable — nothing found requires a rewrite of the model or the tool abstraction. The model is the asset; the traversal and mutation plumbing is the debt.

### Scorecard

| Dimension | Grade | One-line reason |
|---|---|---|
| Data model & serialization | **B+** | Freezed value objects, versioned docs, custom converters, round-trip tests. Missing `name`, `fill-rule`, defs registry. |
| Undo/redo integrity | **C** | Command stack is well designed; ~12 mutation paths bypass it entirely. |
| SVG import fidelity | **D+** | Transposed `matrix()`, `<defs>` dropped, wrong fill default, no CSS/presentation inheritance. |
| SVG export fidelity | **C** | Valid XML, but drops alpha, caps/joins, stroke-opacity, text attributes; exports all artboards merged. |
| Rendering correctness | **C** | Solid painter; gradients ignore model geometry, text ignores 6 model text fields, mask sources are drawn visibly. |
| Performance architecture | **D** | Cache thrash per frame, O(k·n) drag writes, deep-equality repaints, per-frame TexturePainter/JSON work. |
| Tool/UX completeness | **C+** | 11 tools, but pen unreachable, snapping logic wrong, no opacity UI, group children unselectable. |
| Test & CI | **D** | Suite does not compile; 16 tests, 384 lines; no widget/tool/round-trip/perf tests; no CI. |
| Project hygiene | **D** | No git repo, scratch `.py`/`test_serialize*.dart` files at root, template README, internal `pdf/src` imports. |

---

## 2. Architecture map (as built)

```
main.dart                     → ProviderScope + MaterialApp (dark, M3)
  └ EditorScreen (ConsumerStatefulWidget, 1554 lines)
       ├ AppBar: page chip / size chip / zoom chip / Fit / Zoom-Sel / artboard menu
       │         save · undo · redo · overflow menu (open/save project, PNG/PDF/SVG in-out)
       ├ ShortcutHandler (services/shortcut_service.dart)  ── Ctrl+C/V/D/Z/S
       ├ Focus(onKeyEvent)                                 ── Ctrl+S/Z/Y, Delete, V R O P T N H, Esc
       ├ LayoutBuilder → desktop: [ToolSidebar | EditorCanvas | Inspector+Layers]
       │                 mobile : [ToolSidebar(horizontal) | canvas + bottom sheet]
       └ EditorCanvas (canvas/editor_canvas.dart)
            └ Stack: GridPainter | ScenePainter | SelectionPainter | ToolPreviewPainter
                     + Listener (pointer) + GestureDetector (pinch) + InlineTextEditor

State:      EditorNotifier (Notifier<EditorState>, 1069 lines)
            EditorState  = document + selection + activeTool + viewport + tool settings
            HistoryManager (ChangeNotifier, 100-entry Command stack)
Commands:   Command { execute(editor), undo(editor), description }  × 15 implementations
Model:      VxDocument ── VxArtboard[] + VxElement[] (rect|ellipse|path|text|group|compound|use|symbol)
            VxFill (solid|linear|radial|none) · VxStroke · PathSegment · ColorStop · Meta map
Tools:      11 classes implementing Tool (down/move/up/cancel/paint/cursor), held as global singletons
Canvas:     ScenePainter (draw) · HitTester (spatial cell index) · SceneIndex (artboard filter + cache)
Export:     SvgImporter/SvgExporter (xml pkg) · SceneExporter (PNG via PictureRecorder, PDF via pdf pkg)
```

### Data flow for a drag (the hot path)

```
Listener.onPointerMove (editor_canvas.dart)
  → Tool.onPointerMove
      → SelectTool: notifier.snap(scenePos)                 ← HitTester.getBounds over all elements
      → SelectTool: for each selected el: notifier.updateElement(el)
            → EditorNotifier.replaceElements                  ← full-list map (O(n))
            → EditorNotifier.state = copyWith(document: new)  ← NEW document instance
            → Riverpod notifies → EditorScreen rebuilds
                  → EditorCanvas rebuilds → new ScenePainter constructed (caches cold)
                  → ScenePainter.shouldRepaint does document != document (deep O(n) compare)
                  → ToolPreviewPainter.paint → tool.paint → tool.paint reads HitTester (cache miss,
                    HitTester._ensureCache sees a non-identical doc → clears index → rebuilds index O(n·paths))
```

Each step is fine in isolation; composed, a single pointer move does O(n) tree work several times over, plus a full widget rebuild. This is the core performance story and it explains everything under P2 in §5.

---

## 3. Measured code facts

| Metric | Value |
|---|---|
| Hand-written files / lines | 59 / **10,864** |
| Generated (freezed/g) files / lines | 5 / **3,690** |
| Tests | 6 files / **384 lines** / 16 passing tests + 1 non-compiling test |
| Largest files | `scene_exporter.dart` 1126 · `editor_notifier.dart` 1069 · `inspector_panel.dart` 971 · `hit_tester.dart` 660 · `svg_importer.dart` 544 · `scene_painter.dart` 526 · `editor_screen.dart` 1554 |
| Analyzer issues | **508** (3 errors, 66 warnings, 439 infos) |
| Top lint | `unnecessary_underscores` — **292** (wildcard-parameter style) |
| Hand-written `.when/.map/.whenOrNull/.mapOrNull` call sites | ~40 |
| `firstWhere` without `orElse` (throw-on-missing) | 19 |
| Platforms configured | android, linux, macos, windows — **no `ios/`, no `web/`** (yet code branches on `Platform.isIOS`) |
| Version control | none |

### Analyzer breakdown

| Count | Rule |
|---|---|
| 292 | `unnecessary_underscores` (`_`, `__`, `___`…) |
| 64 | `deprecated_member_use` (`Color.value`, `Matrix4.translate/scale`, `Share`/`shareXFiles`, `withOpacity`) |
| 27 | `unnecessary_import` |
| 26 | `curly_braces_in_flow_control_structures` |
| 19 | `invalid_use_of_protected_member` + 19 `invalid_use_of_visible_for_testing_member` |
| 16 | `unused_import` |
| 8 | `avoid_print` (scratch files) |
| 5 | `non_constant_identifier_names` (`__1`…`__5`) |
| 4 | `implementation_imports` (`package:pdf/src/...`) |
| 3 | **compile errors** (`test/export_fixture_test.dart`) |

The 38 `invalid_use_of_*_member` warnings are all `editor.state` accessed from `Command` implementations — i.e. **every command reaches into Riverpod's protected `state`**. It compiles today but is an unsupported API surface; `Command` should operate through the notifier's public methods only.

---

## 4. P0 — blocking today

### P0-1 · The test suite does not compile
`test/export_fixture_test.dart:12,13,16` treat `SvgImporter.import()` (which returns `VxDocument?`) as non-null:
```dart
final document = SvgImporter.import(svg);
expect(document.elements, isNotEmpty);          // ← error
final png = await SceneExporter.renderPng(document, ...);  // ← error
```
`flutter test` therefore exits 1 on a clean checkout. Consequence: **the only end-to-end fidelity test in the project has never executed.** Fix: `final document = SvgImporter.import(svg); expect(document, isNotNull);` then `document!`, or change the signature to throw on malformed input. Then re-baseline `test/goldens/masked_group.png` (see P0-5 — it will change).

### P0-2 · No version control at all  — **FIXED** in `162f432`
~~`git status` → *not a git repository*.~~ 10,864 lines of hand-written Dart had no history, no branch, no rollback, and a live `.gitignore` implying one was intended. Baseline commit `162f432` now exists; branch clean.

**First action of the plan:** `git init`, commit the current state as `v0.9-pre-hardening` (it will be the "before" reference for the fidelity corpus), then keep `/build/` and `.dart_tool/` ignored.

### P0-3 · Ctrl+S silently exports an SVG instead of saving the project  — **FIXED** in `eacc6fa`

*(Diagnosis preserved below. The duplicated Ctrl+S / Ctrl+Z / Ctrl+Y branches were removed from the inner `Focus`; `ShortcutHandler` is now the single owner of Ctrl/Cmd+S, +Z, +Shift+Z, +Y, +C, +V, +D. Delete/Backspace and tool switching stay in the inner handler.)*
Two `Focus` widgets both claim `autofocus` and both bind Ctrl+S:
- `lib/services/shortcut_service.dart:47-48` → `onSave` → `_saveProject()` (`.vxp`) — the *intended* behaviour, matching the AppBar tooltip `'Save Project (Ctrl+S)'` at `editor_screen.dart:191`.
- `editor_screen.dart:353-379` → builds `SvgExporter.export(document)` and opens a **Save-SVG** dialog.

The wiring is `ShortcutHandler` (line 345) wrapping `Focus` (line 347); both are `autofocus`, and the **inner** `Focus` is closer to the primary focus, so it handles the key first and returns `handled` — the outer `onSave` never fires. Ctrl+Z is bound in both places too. **Net effect: the keyboard "save" is not the save the UI advertises.** Fix: one shortcut registry, one `Focus`, no duplicated bindings.

### P0-4 · Everything inside `<defs>` is dropped on import — masks, clip paths and symbols never render  — **FIXED** in `c7c46cd` + `843a241`

*(Diagnosis preserved below; the measured-before figures are the baseline the fix was verified against. Fix: `VxDocument.defs` registry, three-pass import, definition-first resolution in painter/hit-test/PDF/SVG export, and a luminance→alpha mask renderer — the previous renderer applied alpha masking, so a black shape inside a mask hid nothing even once it resolved.)*
`svg_importer.dart:44-56`: children of `<defs>` are copied into a **static map `_defs`** and never inserted into the document element tree. `_defs` is only consulted for gradient fills (`svg_importer.dart:378`).

Meanwhile `ScenePainter._resolveReference(id)` and `HitTester._findElementById` search **only `document.elements`**. So for any real-world SVG:
- `<mask id="...">` in defs → the element gets `maskId`, but the mask is never found → **renders unmasked**.
- `<clipPath id="...">` in defs → **renders unclipped**.
- `<symbol id="...">` in defs + `<use href="#...">` → the symbol geometry is absent → **`use` renders nothing**.

The repo's own fixture proves the shape of the problem — `test/fixtures/masked_group.svg` puts `<mask id="mask_1">` inside `<defs>`, and the fixture test asserts `document.elements.first.maskId == 'mask_1'`. **Measured proof (2026-09-20):** a pixel probe over the same fixture reports `total elements in tree: 1` (the `<g>` only, mask source missing) and centre pixel `rgba(255,107,107,255)` — opaque red where the mask's black circle (r=60, centred at 100,100) must yield `alpha = 0`. So the roadmap's "**Done:** Clip-path import/export wrappers", "**Done:** Symbol/use round-trip preservation improvements" and "**Done:** PNG golden regression file for masked SVG export" are **false for import**.

The deeper problem this exposes: `test/goldens/masked_group.png` was generated from a build that already had this bug, so the golden **encodes the unmasked render** and passes happily. The project has a regression test that locks in incorrect output. After fixing the one-line compile error, the suite is green `17 passed / 1 skipped` — and the skip is `test/mask_defs_regression_test.dart`, which is the acceptance test for B1 (a real pixel assertion, skipped with the reason recorded until the fix lands).

Fix: give the document a real **defs registry** (`Map<String, VxElement> defs`) in `VxDocument`, resolve `<defs>` into it on import, write it back out on export, and have `_resolveReference` consult it. Add a 20-file SVG corpus with per-file expected render hashes in CI.

### P0-5 · Gradients render wrong in the editor while exporting different geometry  — **FIXED** in the B4 batch

*(Diagnosis preserved. `GradientUnits` is now modelled on the gradient variants, `GradientGeometry` resolves the model's geometry against the element bounds for canvas *and* PDF (which also gained the missing y-flip), and the painter builds the shader from `ui.Gradient.linear/radial` with the authored coordinates instead of a hard-coded horizontal sweep. The inspector's gradient presets are now `objectBoundingBox`, so they behave like a design tool's fill. **Known approximation:** `objectBoundingBox` linear gradients map their endpoints into the bounds, which is exact for axis-aligned gradients but not for the exact projective map under non-uniform scaling; radial uses SVG's normalized-diagonal radius. `gradientTransform` is not modelled.)*
`scene_painter.dart._applyFill`:
```dart
linear: (start, end, stops) { paint.shader = LinearGradient(colors: ..., stops: ...).createShader(bounds); },
radial: (center, radius, stops) { paint.shader = RadialGradient(colors: ..., stops: ...).createShader(bounds); },
```
`start`, `end`, `center`, `radius` are **never used**. Default `LinearGradient` alignment is centre-left → centre-right, and default `RadialGradient` is centred — so every gradient in Vectix paints as a horizontal sweep (or centred blob) across the element's bounding box, regardless of the authored direction/position.

The exporter, by contrast, writes the real geometry (`svg_exporter.dart._writeFillDef` → `x1,y1,x2,y2` with `gradientUnits="userSpaceOnUse"`). **The editor and the export disagree**, so a gradient authored in Vectix and exported looks different from what the user saw, and an imported gradient renders with the wrong direction. Fix: build the shader from `start`/`end` mapped into element-local space (`LinearGradient(begin: …, end: …)` from normalised coordinates, or a `ui.Gradient.linear(start, end, colors, stops)` in local space), and use `ui.Gradient.radial(center, radius, …)`.

### P0-6 · The SVG exporter wrote straight lines as `<path>` elements with no `d` — they vanished on export  — **FIXED** in the B6 batch

*Found by the new fidelity corpus on its first run, not by review.*

`SvgExporter._writeElement` had a branch for two-point paths intended to emit a
`<line>`, but the element name had been changed to `'path'` while the attributes
were left as `x1/y1/x2/y2`. The result was `<path x1="5" y1="15" x2="95" y2="15"/>`
— valid XML, **invalid SVG**, since a `<path>` without a `d` attribute renders
nothing. Every straight line in every exported drawing was silently dropped, and
the roadmap listed "Native SVG line import/export support" as done.

Caught as a round-trip fidelity drop in four corpus files (`shapes_basic`,
`stroke_features`, `style_attribute`, `clip_path_multi`); fixing the element name
brought all four to exactly 100 %, which confirmed the single root cause.

---

## 5. P1 — correctness & data loss

### P1-1 · `matrix(...)` transform import is transposed  — **FIXED** in `3e94022`

*(Kept for reference: `Matrix4`'s unnamed constructor takes row-major arguments while SVG `matrix(a,b,c,d,e,f)` is column-major. Now built via `setEntry`.)*
`svg_importer.dart._parseTransform`, `case 'matrix'`:
```dart
final m = Matrix4(parts[0], parts[1], 0, 0,  parts[2], parts[3], 0, 0, ...);
//             m00       m01            m10       m11
```
`Matrix4`'s constructor takes **row-major** arguments, so this sets `m01 = b`, `m10 = c`. SVG defines `matrix(a,b,c,d,e,f)` as `x' = a·x + c·y + e`, i.e. `m10 = b`, `m01 = c`. The two are transposed. `matrix()` is what Illustrator/Figma/Inkscape emit for rotated or skewed objects, so **rotated SVG artwork imports mirrored/sheared**. (The exporter's `_matrixToSvg` reads `storage[0],[1],[4],[5],[12],[13]` — that one is correct, so the bug is import-only.)
Fix: `Matrix4.identity()..setEntry(0,0,a)..setEntry(1,0,b)..setEntry(0,1,c)..setEntry(1,1,d)..setEntry(0,3,e)..setEntry(1,3,f)`.

### P1-2 · Wrong default fill, no presentation inheritance  — **FIXED** in the B2 batch

*(Diagnosis preserved. `SvgImporter` now walks the tree with an inheritable `_SvgStyle` context, so `fill`/`stroke`/`stroke-*`/`fill-opacity`/`font-*`/`text-anchor`/`letter-spacing`/`color` inherit down `<g>` and from `<svg>`, the initial fill is black per spec, and `rx`/`ry` import as an equivalent rounded path. Still not imported: `<image>`, `<style>`/CSS classes, `<tspan>`, `fill-rule`, `pattern`, `filter`, `marker`.)*
- `_parseFill(null)` returns `VxFill.none()`. Per SVG the initial `fill` is **black**, so `<path d="…"/>` with no fill attribute imports **invisible**.
- Presentation attributes are read per-element only (`_parseStyleAttributes`) — there is **no inheritance from ancestor `<g>`**. A `<g fill="red" stroke="black">` with plain children imports as `fill: none` children: the artwork disappears.
- `<rect rx/ry>` (rounded corners) is parsed but `rx`/`ry` are ignored → **rounded rectangles lose their corners**.
- Not imported at all: `<polygon>`, `<polyline>`, `<style>`/CSS classes, `<tspan>`, `<image>`, `<svg>` nesting, `marker`, `pattern`, `filter`, `fill-rule`/`clip-rule`, `stop-opacity`, `text-anchor` (collected then ignored).
Fix order: inheritance + default fill first (they cause silent invisible geometry), then rounded rect, then polygon/polyline, then `fill-rule`.

### P1-3 · Color parsing is not colour parsing  — **FIXED** in the B2 batch

*(Now handles `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa` — with the byte order corrected — `rgb()`/`rgba()` with numbers or percentages, modern space/slash syntax, `hsl()`/`hsla()`, `transparent`, `currentColor` and the full CSS named-colour table. 25 tests cover the grammar.)*
`svg_importer.dart._parseColor` supports 6-digit hex plus exactly five names (`black/white/red/green/blue`).
Broken/missing: `#RGB` works, `#RGBA` fails, `#RRGGBBAA` is parsed by `Color(int)` as if it were `#AARRGGBB` → **wrong colour and wrong alpha**; `rgb()/rgba()/hsl()`, `transparent`, `currentColor`, `inherit`, and the other ~140 CSS names all return `null` → silently become black or transparent depending on the call site.
Fix: use a proper SVG colour parser (`package:csslib` or a small dedicated parser) and unit-test the full grammar.

### P1-4 · Export loses alpha, caps, joins and stroke opacity  — **FIXED** in the B3 batch

*(Colour alpha now round-trips as `fill-opacity`/`stroke-opacity` over 6-digit hex; `stroke-linecap`, `stroke-linejoin` and `stroke-miterlimit` are imported and exported; `stroke-opacity` is applied by the painter, which also now honours `strokeMiterLimit`. `VxStroke.miterLimit`'s default moved from 1.0 to 4.0 (SVG/Skia default) — documents saved before this change keep 1.0, which would bevel off sharp miters; only relevant to pre-existing `.vxp` files. `VxStroke.opacity` is now applied and then folded into the colour on import, so it is effectively deprecated.)*
- `svg_exporter.dart._colorToHex` writes `#rrggbb` and returns `'none'` when `alpha == 0` → **semi-transparent colours are exported fully opaque** (only fully transparent is handled).
- `VxStroke.opacity` and `VxStroke.miterLimit` exist in the model but are **never read anywhere** (`_applyStroke` in `scene_painter.dart` ignores them; the exporter never writes `stroke-opacity`). Dead model fields.
- `stroke-linecap` / `stroke-linejoin` are neither imported (`stroke-linecap` isn't even in the `presentationAttrs` list) nor exported, although the model carries `cap`/`join` and the canvas honours them. **Round-trip loses caps and joins.**
- Layers panel `strokeCap`/`strokeJoin` are hardcoded `butt`/`miter` on import, so every imported stroke is squared off.

### P1-5 · Text: 6 inspector controls do nothing visually  — **PARTIALLY FIXED** in the B3 batch

*(The painter now builds its `TextStyle` from `fontWeightValue`, `fontStyle`, `letterSpacing`, `wordSpacing` and `lineHeight`, and passes `textAlign`/`maxLines`; the importer populates all of them (including inherited `font-weight`/`font-style`/`text-anchor`) and the exporter writes them. **Still open:** wrapping needs a text-box width the model does not have, SVG `x,y` is a baseline while Flutter paints from the top-left, so vertical position still drifts across a round trip, and `<tspan>` is not parsed.)*
`VxText` carries `letterSpacing`, `wordSpacing`, `lineHeight`, `fontWeightValue`, `fontStyle`, `maxLines`, `align`, and `text_properties_section.dart` edits all of them through `UpdateElementCommand`. But:
- `scene_painter.dart` paints text with `TextSpan(text: content, style: style)` only → **the six extra fields are ignored on canvas**, so the user moves sliders/fields and sees nothing change.
- `svg_exporter.dart` writes only `id/x/y/fill/font-size/font-family` → weight, style, spacing and line height are lost on export.
- `svg_importer.dart` reads `font-size`/`font-family`/fill only, ignores `text-anchor`/`font-weight`/`font-style`/`tspan`, and forces `align: start`, `maxLines: 1` → **multi-line SVG text is flattened**.
- Coordinate semantics differ: SVG `x,y` is the **baseline**, Flutter paints from the top-left. Text will drift vertically on every SVG round-trip.

### P1-6 · Nine operations bypass undo
Verified call sites that mutate the document without `HistoryManager`:
| Location | Operation |
|---|---|
| `tools/text_tool.dart:27` | **creating a text element** — cannot be undone at all |
| `ui/layers/layers_panel.dart:113,119` | lock / hide toggles |
| `ui/editor_screen.dart:128,140,142,144,146,148` | rename / duplicate / move / add / remove artboard |
| `ui/editor_screen.dart:1041-1045` | document size presets (A4 / 1920×1080 / 1024²) |
| `ui/inspector/inspector_panel.dart:912` + symbol category manager | symbol metadata |
| `state/editor_notifier.dart:423,662,671,706` | `updateElementFlags`, `updatePathSegments`, `insertPathNode`, `deleteLastPathNode` are **unused public API** that bypasses history |
| `tools/select_tool.dart:190`, `tools/node_tool.dart:86` | drag preview writes (legitimate preview, see P1-11) |

The pattern is clear: any path that reaches `notifier.*` directly instead of `historyProvider.execute(...)` is not undoable. Fix: make `HistoryManager` the **only** public mutation entry point — move `addElement/removeElement/updateElement/replaceElements/...` to library-private and expose `execute(Command)`; then nothing *can* bypass it.

### P1-7 · Snapping compares the pointer, not the dragged geometry
`editor_notifier.snap(point)` compares `point` (the raw cursor position) against other elements' `left/centre/right` and `top/centre/bottom`. In `SelectTool` the point passed is the pointer position, not the dragged element's bounds. So "snap to centre/edge" only triggers if the user happens to grab the element **exactly at its centre point** — i.e. it mostly does nothing, or snaps at seemingly random moments. The threshold is also hardcoded:
```dart
const snapThreshold = 5.0 / 1.0; // Assume zoom 1 for now, or could pass zoom
```
→ at 400 % zoom the magnet feels dead, at 25 % it is unusable. And `snapToGrid`/`showGrid` have **no UI control anywhere** (only `EditorNotifier.toggleSnapToGrid`, which no widget calls), so grid snapping cannot be enabled and the grid cannot be hidden.
Fix: snap the candidate rect (element bounds offset by delta) against targets, scale the threshold by `1/zoom`, expose snap/grid toggles in the UI, and add guide-line feedback (already partly painted in `SelectTool.paint`).

### P1-8 · Mask/clip source elements are drawn visibly
A mask source is stored as an ordinary element in `document.elements` **and** referenced by `maskId`. `ScenePainter` paints every active element, so the mask source is visible artwork; `SvgExporter._writeReferencedDef` additionally duplicates it inside `<defs><mask>`, producing an SVG that contains it twice. Fix: mark mask/clip sources (`role: defs` flag or a `defs` collection) and exclude them from both the canvas paint loop and the main export loop.

### P1-9 · SVG export ignores artboards; PNG/PDF do not
`SvgExporter.export` loops over **all** `doc.elements` and uses the active artboard's size as `viewBox`. PNG (`SceneExporter.renderPng`) and PDF (`_selectedArtboards`) both filter by artboard. So exporting SVG from a multi-artboard document produces one flat file with **every artboard's artwork overlapping in a single viewBox**. Also `VxArtboard.x/y` is **never read anywhere in `lib/`**, so artboards cannot be laid out on the canvas at all — "multi-artboard" is currently "one artboard at a time, always at the origin".

### P1-10 · New elements get inconsistent `artboardId`
| Tool | sets `artboardId`? |
|---|---|
| rect, ellipse, polygon, star, line | **no** → `null` |
| text, freehand, pen | yes → active artboard |

`null` means *"belongs to every artboard"* in `SceneIndex._belongsToActiveArtboard` and `HitTester._belongsToActiveArtboard`, and `removePage()` only deletes elements whose `artboardId` matches the removed artboard. Result: **shapes created with the rect/ellipse/star tools leak across artboards and survive artboard deletion**, while text and freehand paths do not. One-line fix in each tool, but it also argues for making `artboardId` non-nullable with an explicit `global` sentinel.

### P1-11 · Preview writes bypass history and can be orphaned
`SelectTool.onPointerMove` writes each preview frame straight into the document (`select_tool.dart:190`, `node_tool.dart:86`) and `onPointerUp` retroactively wraps the result in an `UpdateElementCommand(old, new)`. It works, but it means: (a) the document is genuinely dirty mid-gesture with nothing on the undo stack — a crash, hot-reload, or lost pointer-up leaves the preview applied and unrecoverable; (b) `FillStrokeSection._showColorPicker` documents the same workaround ("revert to original first, then execute command", `fill_stroke_section.dart:81`). Fix: introduce a first-class `preview`/`commit`/`cancel` trio in `EditorState` (a separate `previewElements` overlay that the painter draws) so the committed document is never touched until commit.

### P1-12 · Assorted correctness defects
- **Delete key is swallowed in node mode.** `editor_screen.dart:404-407`: `if (activeTool is NodeTool …) return KeyEventResult.handled;` with the actual call commented out (`// activeTool.deleteSelectedNode(ref);` at line 406). Pressing Delete in the node tool does nothing and prevents anything else from seeing the key. `NodeTool` has no node-delete action at all.
- **The pen tool is unreachable.** `ActiveTool.pen`, `PenTool`, `tool_provider.dart:42` all exist; there is **no sidebar button and no keyboard shortcut** for it, and `PenTool.commitOpenPath` has **zero callers** (so an open path can only be finished by clicking back on its start point). Worse, `tool_sidebar.dart` contains **two consecutive buttons that both set `ActiveTool.freehand`** (icons `gesture` and `edit`) — almost certainly one was meant to be the pen.
- **Freehand smoothing slider is a no-op.** `freehandSmoothing` is never read by `freehand_tool.dart` (`_updatePreview` appends raw points); the tool's actual width comes from `lineStrokeWidth`, which its settings bar does not show. The visible control does not control the visible behaviour.
- **`TextEditingController` allocated in `build()`** — `fill_stroke_section.dart` stroke-width field: `controller: TextEditingController(text: …)`. A fresh controller on every rebuild resets the caret/text mid-typing and leaks. Same pattern in `text_properties_section.dart._numberField`.
- **Import/open destroys unsaved work silently** — `import_svg` and `open_project` call `loadDocument`, which replaces the document and clears the selection, with no "unsaved changes" guard and no undo entry (*needs runtime check: whether the app has any draft persistence; none was found in source*).
- **19 `firstWhere` calls without `orElse`** will throw `StateError` if the selection goes stale (e.g. an element is removed while a panel that captured it is still mounted). Low frequency, high blast radius; wrap in a safe lookup helper.

---

## 6. P2 — performance & architecture

### P2-1 · `SceneIndex` static cache: unbounded growth + deep-hash per call
```dart
static final Map<String, SceneIndex> _cache = {};
final cacheKey = '${document.hashCode}|$key|${document.activePageIndex}';
return _cache.putIfAbsent(cacheKey, () { … });
```
- The map is **never evicted** → one entry per document version, retained for the process lifetime.
- `document.hashCode` for a `freezed` object is a **deep hash over the entire element tree**, computed on every call, as the map key. So the "cache" costs a full tree hash before it can hit — and it holds the strong reference that prevents the old documents from being collected.

Fix: key on a monotonically increasing `documentRevision` int carried in `EditorState`, hold at most one entry (or a small LRU), and compute the index lazily with invalidation hooks.

### P2-2 · `HitTester` rebuilds its spatial index on every pointer move
```dart
static void _ensureCache(VxDocument doc) {
  if (!identical(_cachedDoc, doc)) { … _cellIndex.clear(); _textPainterCache.clear(); _buildIndex(doc); }
}
```
Every edit produces a **new** document instance (`copyWith`), so `identical` is always false during a drag → the cell index is cleared and `_buildIndex` walks every element and calls `getBounds` (which builds a `Path` for every path element) — **O(n) path construction per pointer move**. The index is smaller than the cost it adds. Same for `_localBoundsCache`/`_sceneBoundsCache` keyed by `element.hashCode` (deep hash per element per frame).

Fix: replace the "identical document" heuristic with revision-based invalidation; cache in **element-local space keyed by element id + revision**, keep the cell index across moves and only patch the moved elements' cells; cache `Path` objects on the element (or in a revision-keyed map) instead of rebuilding from `List<PathSegment>`.

### P2-3 · Drag writes are O(k·n) per pointer move with a full UI rebuild each time
`SelectTool.onPointerMove` → for each selected element `notifier.updateElement(el)` → `replaceElements` (full-list `map`) → `state = copyWith(document: …)` → Riverpod notifies → `EditorScreen` (which `ref.watch(editorProvider)` unconditionally) rebuilds the whole tree — AppBar, chips, ToolSidebar, canvas, inspector, layers. For a 5-element selection that is 5 full-document rebuilds and 5 full-widget rebuilds **per pointer move**.
Fix: single batched `previewSelection` update per frame; `select()` on sub-trees in widgets that only need part of the state (the screen already does this for `viewport`, then immediately watches the whole state anyway); and a dedicated preview overlay so the document identity doesn't change mid-drag (which also fixes P2-2).

### P2-4 · Repaint decisions do deep structural comparisons
```dart
bool shouldRepaint(old) => old.document != document || old.viewport != viewport;   // ScenePainter
bool shouldRepaint(old) => old.state != state;                                     // SelectionPainter
```
`freezed` `==` is a recursive deep comparison — comparing two versions of a 1,000-element document on every repaint. Fix: compare a `revision` int (and cheap value objects for viewport).

### P2-5 · Painter caches are per-frame, therefore useless
`ScenePainter._pathCache` and `._elementPathCache` are **instance** fields, but `EditorCanvas` constructs `ScenePainter(state.document, state.viewport)` inside `build()`, and `build()` runs on every state change. So a fresh painter — with empty caches — is created each frame. The 5000-entry eviction guards never trigger. Fix: hoist caches to a provider/repository object whose lifetime spans frames, keyed by element id + revision.

### P2-6 · Per-frame incidental work
- `HitTester._measureTextBounds` mutates the cached `TextPainter` and calls `layout()` on every call even though the cache key already includes the content (`hit_tester.dart`). It also ignores rotation for text bounds.
- `SceneExporter._thumbnailKey(symbol) => symbol.toJson().toString()` — **full JSON serialisation** to compute a cache key, executed inside a `FutureBuilder` in `inspector_panel.dart`'s build. Cached thumbnails are never evicted.
- `SelectTool._updateCursor` runs `getCursorForPosition` (combined bounds + handle hit-tests + per-selected-element bounds) and may `setState` on **every hover event**; the move path calls it again on every move.
- Shape tools generate a **new `Uuid().v4()` on every pointer move** (rect/line/star/ellipse/polygon/pen/freehand) — a fresh UUID per frame per preview.
- `GridPainter` draws one line per grid step with no viewport culling; at 10 % zoom on an A4 artboard that is thousands of lines per frame. (*needs profiling to quantify.*)

### P2-7 · The element-tree traversal problem (the big one)
Adding a field to `VxElement` requires coordinated edits at ~12 sites, all written as positional `freezed` lambdas with 9–19 wildcard parameters:

| # | Location | Purpose |
|---|---|---|
| 1 | `state/editor_notifier.dart` `_removeElementInList` | recursive delete |
| 2 | `state/editor_notifier.dart` `_updateElementInList` | recursive update |
| 3 | `state/editor_notifier.dart` `updateElementFlags` | flag set |
| 4 | `commands/update_element_command.dart` `_replace` | command apply |
| 5 | `commands/transform_command.dart` `_replace` | command apply |
| 6 | `services/shortcut_service.dart` `_paste` | duplicate |
| 7 | `ui/editor_screen.dart` `_pasteFromClipboard` | duplicate (duplicate of #6) |
| 8 | `canvas/hit_tester.dart` `_elementContains` | hit test |
| 9 | `canvas/hit_tester.dart` `_getLocalBounds` | bounds |
| 10 | `canvas/hit_tester.dart` `getBounds` | transform extraction |
| 11 | `canvas/scene_painter.dart` `_paintElement` | draw |
| 12 | `canvas/scene_painter.dart` `_getElementAsPath` | path conversion |
| 13 | `canvas/scene_exporter.dart` `_drawPdfElementWithoutMask` | PDF draw |
| 14 | `svg/svg_exporter.dart` `_writeElement` | SVG write |
| 15 | `svg/svg_exporter.dart` `_findElementById` | lookup |
| 16 | `ui/inspector/*` | filter helpers |

Everything is positional and wildcard-named, so **the compiler cannot tell you that you missed a field** — it will only tell you that an arity changed. That is how `VxText` grew six fields that nothing reads (P1-5) and how `strokeCap` got hardcoded to `butt` on import (P1-4).

Fix (highest-leverage refactor in the project):
1. Replace positional `when()` with **Dart 3 pattern-matching switches** — `switch (element) { case VxRect(:final fill, :final stroke): … }` — named fields, compiler-checked, exhaustiveness-checked.
2. Add **shared extensions**: `VxElement.transform`, `.nodeId`, `.children`, `.withTransform()`, `.withFlags()`, `.mapChildren()`, `.resolveBounds()`, `.toPath()`. Each of the 16 sites above then collapses to a few lines of shared, tested code.
3. Add a golden test that enumerates the model's fields via `toJson()` keys and asserts every one is either read by the painter/exporter or explicitly listed as "not yet supported". That makes unsupported fields a **decision**, not an accident.

Expected effect: removes the 292 `unnecessary_underscores` lints and a large share of the remaining 216, and shrinks roughly 1,500–2,000 lines of boilerplate.

### P2-8 · Other architectural issues
- **Reaching into Riverpod internals**: all 15 commands call `editor.state`, producing 38 `invalid_use_of_protected_member` / `invalid_use_of_visible_for_testing_member` warnings. Commands should use public notifier methods.
- **Internal package imports**: `scene_exporter.dart:9-12` imports `package:pdf/src/pdf/obj/{smask,function,pattern,shading}.dart` (4 × `implementation_imports`). Any minor `pdf` upgrade can break PDF export. Wrap them behind a small adapter and pin the version, or drop soft-mask PDF support until a public API exists.
- **`EditorScreen` is a 1,554-line god-widget** doing file IO, export orchestration, preset persistence, keyboard handling, clipboard, layout and dialogs. Extract: `ProjectIoService`, `ExportController`, `PresetStore`, `ShortcutRegistry`, `EditorLayout`.
- **Duplicated implementations**: paste/duplicate ×2, `_findElementById` ×6, `_buildPath` ×4, `_belongsToActiveArtboard` ×3 (and 2 of those are **unused** — `scene_painter.dart:28`, `scene_exporter.dart:1115`), key handling ×2.
- **Model redundancy**: `pageCount` + `artboards.length` + `activePageIndex` + `artboardMode` all express the same thing and can drift; `EditorState.initial()` ships a document with `artboards: []` while `loadDocument` normalises to one artboard, so two document shapes exist in practice (`SceneIndex` even has a special `'none'` artboard key).
- **`EditorState` mixes document state with UI/transient state**, which is why every tool move invalidates every widget.
- **No service layer**: there is no `ProjectRepository`, no autosave, no recent-files list, no crash recovery, no current-file tracking (so a real quick-save is impossible today — see P0-3).

---

## 7. P3 — product, quality & hygiene

- **README.md is still the Flutter template**; `pubspec.yaml` says `description: "A new Flutter project."`. There are no run instructions, no architecture notes, no contribution guide.
- **Scratch files committed at the root**: `fix2.py`, `fix3.py`, `fix4.py`, `scratch_recovery.txt`, `test_serialize.dart`, `test_serialize2/3/4.dart` — with compile warnings and `print()` calls. Delete all of them (they are the source of the 8 `avoid_print` infos).
- **No CI**. No `.github/workflows`, no `flutter analyze` gate, no test gate, no golden-image gate, no coverage. Nothing prevents P0-1 from recurring.
- **Test coverage is thin and uneven**: 384 lines / 16 tests over commands, notifier, model serialization and export presets. Missing entirely: widget tests, tool-interaction tests (the transactionality that the roadmap claims as "Done"), SVG round-trip corpus tests, hit-test tests, export golden tests that actually run, performance budget tests.
- **No accessibility work**: no `Semantics`, no focus management, no keyboard-only paths, dark-only theme, small (16–18 px) hit targets.
- **Mobile is partial**: the pinch handler exists but `_touchStartPan` is **unused** (no two-finger pan), handle sizes are zoom-scaled, and the bottom sheet + floating action bar have no overlap guard.
- **`analysis_options.yaml` is the untouched template** — no `strict-casts`/`strict-raw-types`, no `prefer_single_quotes`, no `public_member_api_docs`, no `errors:` promotion for `deprecated_member_use`.
- **Feature-completeness gaps** vs. what a design tool needs: layer rename (no `name` field in `VxElement`), group expand/isolate in the layers panel (flat, top-level only), "enter group" sub-selection (children are unpickable), opacity control, numeric transform for paths/groups, z-order buttons, alignment to artboard, rulers/guides, text-on-path, text-to-path, fill-rule, image import, font management, templates.

---

## 8. Where `development_plan.md` diverges from reality

The roadmap is well written but its **status column is unreliable**. Items marked Done that this analysis contradicts:

| Roadmap claim | Reality |
|---|---|
| "**Done:** Clip-path import/export wrappers" | `<clipPath>` in `<defs>` is dropped on import; never renders (P0-4). |
| "**Done:** Symbol/use round-trip preservation improvements" | `<symbol>` lives in `<defs>` → dropped on import → `use` renders nothing (P0-4). |
| "**Done:** PNG golden regression file for masked SVG export" | The test file does not compile; it has never run (P0-1). |
| "**Done:** Mask compositing pass in canvas rendering" | The painter code exists, but mask sources are also drawn as normal artwork (P1-8) and imported masks never resolve (P0-4). |
| "**Done:** Cache element bounds / coarse spatial index" (listed under *not started*, but implemented) | Implemented — and it is **slower** than no index in its current form (P2-2). |
| "**Done:** Export `viewBox`, opacity, stroke styles, and defs safely" | Exports all artboards merged; drops alpha, stroke-opacity, caps, joins (P1-4, P1-9). |
| "**Done:** Parse transform lists" | `matrix()` is transposed (P1-1). |
| "**Done:** Parse inline `style=""` and presentation attributes" | Parsed per element with no inheritance; default fill wrong; rounded-rect corners dropped (P1-2). |
| "**Done:** Live parameter controls for polygon sides, star spikes/inner ratio, and freehand smoothing" | Polygon and star work; **freehand smoothing is never read** (P1-12). |
| "**Done:** Layer lock/hide/search controls" | Present, but not undoable (P1-6) and the layers list has no nesting or rename (P3). |
| "One drag = one history item / One node edit = one history item" | True for drags and node drags — **false** for text creation, lock/hide, artboards, document size, metadata (P1-6). |
| "Multi-artboard" / `artboardMode: 'multi'` | Only the active artboard is rendered; `artboard.x/y` is never read; no multi-artboard layout (P1-9). |

**Recommendation:** treat `development_plan.md` as a *wish list*, not a status report. Replace its status column with CI-verified checkboxes, and move every unverified "Done" back to *in progress* until a test proves it. That single change fixes the project's biggest process risk: decisions being made on top of capabilities that do not exist yet.

---

## 9. Next development plan

**Guiding principle:** *make what exists true before adding anything new.* Do not start new features until Phase A closes — the P0/P1 items are the difference between "demo" and "tool people can trust with their files".

Sequencing rationale: (1) restore the safety net (git + CI + tests) so every later change is verifiable; (2) fix data-loss (import/export) because it is what makes users leave; (3) fix undo and preview so editing is trustworthy; (4) fix performance so large documents are usable; (5) pay down the traversal boilerplate so the next 20 features are cheap; (6) only then expand features.

Estimates assume one competent Flutter developer, full-time. Halve them if two work in parallel on disjoint areas (A and the model/traversal work in C can run concurrently).

### Phase A — Safety net & truth (Days 1–3)

| # | Task | Files | Acceptance criteria |
|---|---|---|---|
| A1 | `git init`; commit current state as `v0.9-pre-hardening`; delete `fix*.py`, `scratch_recovery.txt`, `test_serialize*.dart` | repo root | `git log` shows the baseline; `flutter analyze` no longer reports `avoid_print` |
| A2 | Fix `test/export_fixture_test.dart` null-handling (done); keep `test/mask_defs_regression_test.dart` skipped as the B1 acceptance test; **expect the golden to be a bug-locked snapshot** and regenerate it in B1 | `test/export_fixture_test.dart`, `test/goldens/` | `flutter test` exits 0 (17 passed / 1 skipped baseline) |
| A3 | GitHub Actions: analyze (fail on error+warning) + test + golden on push/PR | `.github/workflows/ci.yml` | CI red on a deliberately broken commit, green on `main` |
| A4 | Enable stricter lints (`strict-casts`, `strict-raw-types`, promote `deprecated_member_use` to warning) as a *warning-only* ratchet with a tracked baseline count | `analysis_options.yaml` | lint count recorded and monotonically decreasing |
| A5 | Rewrite `README.md` (what it is, run instructions, architecture map, how to export/import) and the pubspec description | `README.md`, `pubspec.yaml` | A new dev can build and run from the README alone |

**Exit criterion for Phase A:** `flutter test` green in CI, baseline commit exists, README is real.

### Phase B — Data-loss triage: SVG in/out (Days 4–9)

| # | Task | Acceptance criteria |
|---|---|---|
| B1 | **Defs registry**: add `Map<String, VxElement> defs` to `VxDocument`; import `<defs>` into it; `_resolveReference` consults it; export writes it back once | Fixture with a defs-mask renders masked; `<symbol>`+`<use>` round-trips; new golden matches |
| B2 | **`matrix()` transpose fix** + round-trip test with rotate/skew matrices | `matrix(0,1,-1,0,…)` imports as a 90° rotation; export→import→export is byte-stable for a 10-file corpus |
| B3 | **Fill/stroke semantics**: default fill = black; presentation-attribute **inheritance** down `<g>`; `#RRGGBBAA`/`#RGBA`/`rgb()/rgba()/hsl()`/named colours; rounded-rect `rx/ry`; `stroke-linecap`/`linejoin`; `stroke-opacity` honoured by painter + exporter; alpha preserved on export | Colour/attribute unit tests + corpus renders match expectations |
| B4 | **Gradient geometry**: shader built from model `start`/`end`/`center`/`radius`; export matches canvas | Authored vertical/diagonal/offset gradients look identical in canvas and exported SVG |
| B5 | **Artboard-aware export**: SVG export filters by artboard like PNG/PDF; mask/clip sources excluded from both paint and export | Multi-artboard doc exports 1 artboard; no mask source visible in exported SVG |
| B6 | **SVG corpus harness**: 25–40 real-world SVGs (Inkscape/Illustrator/Figma/browser exports) with committed expected render hashes + a fidelity score printed per run | Score visible in CI; regressions fail the build |

**Exit criterion for Phase B:** the corpus round-trips with a documented, tracked loss budget; no silent geometry loss.

### Phase C — Editing integrity (Days 10–15)

| # | Task | Acceptance criteria |
|---|---|---|
| C1 | **Single mutation entry point**: commands are the only public document mutators; retire direct `notifier.*` writes; command-ify text creation, lock/hide, artboards, document size, metadata, node insert/delete | A "every action is undoable" widget test: perform 20 operations, undo 20 times, document equals the original snapshot exactly |
| C2 | **Preview/commit/cancel**: `EditorState.preview` overlay drawn by the painter; the committed document is untouched mid-gesture | Cancel mid-gesture leaves the document pointer-identical; crash mid-drag loses nothing |
| C3 | **Snapping rewrite**: snap the dragged bounds against other bounds + artboard edges/centres, threshold `5/zoom`, grid snap; expose grid + snap toggles | Snap works when grabbing anywhere on the shape; toggles present in UI |
| C4 | **Selection & groups**: enter/exit group (double-click), select children, group-aware layers tree with expand/collapse, layer rename (`VxElement.name`), z-order buttons | Children of a group are selectable and editable; layers tree mirrors nesting |
| C5 | **Safe IO**: unsaved-changes guard on import/open/close, current-file tracking with real quick-save, recent files, autosave + crash recovery | Kill the app mid-edit, relaunch, work is recovered |
| C6 | **Inspector completion**: opacity slider, numeric transform for all types, gradient stop add/remove/offset, text fields that actually affect the canvas | Every inspector control changes the canvas and is undoable |

**Exit criterion for Phase C:** one drag/node-edit/text-create = one history item; group editing works; nothing silently destroys work.

### Phase D — Performance (Days 16–21)

| # | Task | Acceptance criteria |
|---|---|---|
| D1 | **Revision-keyed invalidation** replaces `identical`/`hashCode` caching in `SceneIndex` + `HitTester`; bounded caches | No unbounded growth (measure RSS over 1,000 edits); index persists across pointer moves |
| D2 | **Batched preview writes**; `select()`ed providers in `EditorScreen`; kill the full-screen rebuild per move | Instrumented frame count per drag reduced by ≥5× |
| D3 | **Cheap repaint decisions**: revision ints, not deep `==` | No deep comparison in any `shouldRepaint` |
| D4 | **Painter/render cache hoisted** out of `build()`, keyed by id+revision; text layout cached | Path/text layout work per frame ≈ 0 for untouched elements |
| D5 | Incidental: cursor recomputation throttled, preview UUIDs generated once per gesture, grid culled to viewport, thumbnail key = id+revision | Profiler: no per-frame JSON serialisation |
| D6 | **Perf budget test**: 500 / 2,000-element documents — drag, pan, zoom, select | 60 fps target on 500 elements, ≥30 fps at 2,000 on the reference machine; budget asserted in CI (headless frame-time proxy) |

**Exit criterion for Phase D:** large documents stop being a cliff; the budgets are enforced automatically.

### Phase E — Pay down the traversal debt (Days 22–27)

| # | Task | Acceptance criteria |
|---|---|---|
| E1 | Dart 3 **pattern-matching switches** replace positional `when()` in the top 4 hot sites (hit test, painter, PDF, SVG export) | Analyzer issue count drops by ≥180 |
| E2 | **Shared extensions**: `VxElement.transform/children/nodeId/bounds/toPath/withTransform/mapChildren`; delete the 6 duplicated `_findElementById`, 4 `_buildPath`, 2 `_belongsToActiveArtboard`, 2 paste implementations | Each concept exists once |
| E3 | **Field-coverage guard test**: every `toJson()` key is either consumed by paint+export or listed as "unsupported by design" | `VxText`'s six dead fields cannot recur |
| E4 | Split `EditorScreen` into `ProjectIoService`, `ExportController`, `PresetStore`, `ShortcutRegistry`, layout | No file > 500 lines; no duplicated shortcut handling (fixes P0-3) |
| E5 | Commands use public notifier APIs only; wrap `pdf/src` internals behind an adapter | 38 `invalid_use_*` warnings and 4 `implementation_imports` gone |

**Exit criterion for Phase E:** `flutter analyze` reports **0 errors / 0 warnings**; adding a model field is a ≤3-site change.

### Phase F — Feature expansion (only after A–E)

Ranked by user value per unit of risk:

1. **SVG as a first-class citizen** — `<polygon>/<polyline>`, `fill-rule`, `<tspan>`/multi-line text, text-anchor, CSS class support, `<image>` (embedded), `marker`, `pattern`, filters as pass-through-only.
2. **Text that behaves** — text-on-path, convert text to outlines, real font picker (system + bundled), baseline-correct SVG text, line-height/spacing applied on canvas.
3. **Layer/asset systems** — persistent symbol library, reusable components with overrides, templates and preset artboards (social/print/web sizes), asset packaging.
4. **Production output** — bleed/crop marks already exist; add multi-artboard batch export, print-safe PDF profiles, CMYK-aware colour warnings, export of a full project as an asset bundle.
5. **Precision tooling** — rulers, draggable guides, guide snapping, numeric scale/rotation, transform origin, alignment/distribution against artboard, path simplification.
6. **Platform & polish** — iOS target (code already branches on `Platform.isIOS` but `ios/` does not exist), two-finger pan, tablet layout pass, accessibility labels, light theme, onboarding.

### Two-week sprint view

| Sprint | Focus | Ships |
|---|---|---|
| **S1 (wk 1)** | Phase A + B1–B3 | CI green; defs/masks/clip/symbol import works; matrix/colour/inheritance fixed |
| **S2 (wk 2)** | Phase B4–B6 + Phase C1 | Gradient WYSIWYG; artboard-aware export; SVG corpus + fidelity score; undo covers everything |
| **S3 (wk 3)** | Phase C2–C6 | Preview/commit; snapping; groups & layers tree; safe IO + autosave; inspector complete |
| **S4 (wk 4)** | Phase D | Cache architecture, batched writes, perf budgets met |
| **S5 (wk 5)** | Phase E | Pattern matching, shared extensions, 0 warnings, `EditorScreen` split |
| **S6 (wk 6)** | Phase F1–F2 | SVG breadth + text depth |

### KPIs to hold the plan honest

| KPI | Today | Target |
|---|---|---|
| `flutter analyze` errors / warnings | 3 / 66 | **0 / 0** |
| Test suite | does not compile; 16 tests / 384 lines | green in CI; ≥80 tests; ≥1 test per P1 finding above |
| SVG corpus fidelity (25+ real files, round-trip) | not measured | measured, ≥95 % pixel-match, loss budget documented |
| Undo coverage (operations undoable / operations available) | ~70 % (est.) | 100 %, enforced by a widget test |
| Drag with 500 elements | not measured | 60 fps; asserted by a budget test |
| `SceneIndex` cache growth after 1,000 edits | unbounded | bounded (≤1 live entry) |
| Files > 500 lines | 7 | 0 |
| Duplicated traversals of the element tree | ~16 | ≤2 (shared extensions) |

### Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Traversal refactor (E1/E2) breaks rendering subtly | High | High | Golden-render corpus **first** (B6); land E behind that net; refactor one site per commit |
| Pattern-matching migration touches the biggest files | High | Medium | Do it file-by-file with goldens after each file; never mix with feature work |
| No git → irreversible loss | High | Critical | **A1 before anything else** |
| `pdf/src` internals break on upgrade | Medium | Medium | Adapter + version pin; pin recorded in README |
| Fidelity corpus work ballooning | Medium | Medium | Cap at 40 files; store expected hashes, not pixel-perfect expectations for exotic features |
| Feature pressure re-opens "mark done without proof" | Medium | High | Every roadmap checkbox must link to a passing test or CI run |

---

## 10. The first 48 hours (concrete, ordered)

1. `git init` → commit → push (A1). *Nothing else matters until this exists.*
2. Delete `fix2.py`, `fix3.py`, `fix4.py`, `scratch_recovery.txt`, `test_serialize*.dart`.
3. Fix `test/export_fixture_test.dart` null handling; run `flutter test`; watch the golden fail — that failure **is** P0-4, confirmed in 10 minutes.
4. Add the `defs` registry to `VxDocument`, resolve it on import, and make `_resolveReference` consult it (B1). Watch the fixture render masked and the golden pass.
5. Fix the `matrix()` transpose (B1-line change) and add a rotate-matrix round-trip test.
6. Fix the Ctrl+S double binding (delete the SVG-export branch from the keyboard handler; route all shortcuts through one registry entry point).
7. Fix the freehand/smoothing mismatch and add the missing pen button to the sidebar (or delete `PenTool` until it is finished — half-shipped tools are worse than absent ones).
8. Commit each step separately with a message naming the finding ID (`P0-4`, `P1-1`, …). That gives the project a decision trail tied to this report.

---

## Appendix A — How to reproduce this analysis

```powershell
cd D:\ketan\github\vectix
flutter --version                     # Flutter 3.44.0 / Dart 3.12.0
flutter analyze --no-pub              # 508 issues (3 errors, 66 warnings, 439 infos)
flutter test                          # BASELINE AFTER FIX: 17 passed, 1 skipped, exit 0
                                      # (before the export_fixture_test.dart fix: 1 file failed to COMPILE, exit 1)
git status                            # fatal: not a git repository
```

Line counts used above:
```powershell
Get-ChildItem -Recurse lib -Filter *.dart   # 59 handwritten (10,864 lines) + 5 generated (3,690 lines)
Get-ChildItem -Recurse test -Filter *.dart  # 384 lines
```

## Appendix B — Highest-value single fix per file

| File | Issue | Fix |
|---|---|---|
| `lib/svg/svg_importer.dart` | `<defs>` dropped, `matrix()` transposed, fill default, no inheritance, colour gaps, rounded rect | Defs registry + inheritance resolution + proper colour/matrix parsing (P0-4, P1-1, P1-2, P1-3) |
| `lib/svg/svg_exporter.dart` | Artboards merged, alpha/caps/joins/stroke-opacity lost | Artboard filter + complete attribute emission (P1-4, P1-9) |
| `lib/canvas/scene_painter.dart` | Gradient geometry ignored, text extras ignored, mask sources drawn, instance caches never reused | Shader from model geometry; text config from model; skip defs-role elements; hoist caches (P0-5, P1-5, P1-8, P2-5) |
| `lib/canvas/hit_tester.dart` | Index rebuilt per pointer move; deep-hash keys; text layout per call | Revision-keyed invalidation; incremental cell patching (P2-2) |
| `lib/state/editor_notifier.dart` | 2 recursive traversals + flag setter with positional lambdas; undo-bypassing mutators | Pattern-matching visitors; retire direct mutators (P1-6, P2-7) |
| `lib/state/history_manager.dart` | Trimming logic is correct but opaque; not the sole entry point | Make it the only public mutation path (P1-6) |
| `lib/canvas/scene_index.dart` | Static unbounded cache keyed by a deep hash | Revision key + bounded cache (P2-1) |
| `lib/ui/editor_screen.dart` | 1,554-line god-widget; duplicate Ctrl+S and paste | Split into services + one shortcut registry (P0-3, P2-8) |
| `lib/tools/select_tool.dart` | Preview writes into the document; pointer-based snapping | Preview overlay + geometry-based snapping (P1-7, P1-11) |
| `lib/tools/freehand_tool.dart` | Smoothing setting unused; preview style mismatched | Apply smoothing; share the style builder with the canvas (P1-12) |
| `lib/tools/text_tool.dart` | Creation bypasses history | Route through `AddElementCommand` (P1-6) |
| `lib/tools/tool_sidebar.dart` | Pen unreachable; duplicate freehand button | Add pen (or remove it); de-duplicate (P1-12) |
| `lib/models/vx_element.dart` | No `name`, `fill-rule`; dead fields (`miterLimit`, `opacity`) | Add fields with UI+writer support, or drop them (P2-7, E3) |
| `lib/models/vx_document.dart` | No defs registry; redundant `pageCount`/`artboardMode` | Add `defs`; collapse redundant counters (P0-4, P2-8) |
| `lib/canvas/scene_exporter.dart` | Internal `pdf/src` imports; per-lookup JSON thumbnail key | Adapter + version pin; cheap key (P2-6, P2-8) |
| `test/export_fixture_test.dart` | Does not compile | Null-safe (P0-1) |
