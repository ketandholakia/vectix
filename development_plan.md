# Vectix Development Roadmap

> App: Vectix
>
> Goal: evolve the current Flutter SVG editor into a reliable, production-ready design tool for designers, print shops, digital creators, and general SVG users.

## Current Product Position

Vectix already has a solid MVP foundation:

- Basic shapes: rectangle, ellipse, path, text
- Selection, move, resize, rotate
- Grouping, ungrouping, reorder
- Simple layers panel
- Basic SVG import/export
- Project save/load
- Undo/redo command stack
- Desktop and mobile layouts

The main gaps are:

- Undo/redo is not yet transactional for all interactive edits
- SVG fidelity is incomplete
- The document model is too small for serious SVG workflows
- Performance will not scale well for large documents
- UX is functional, but not yet editor-grade

## Development Strategy

Build in this order:

1. Make editing reliable
2. Expand the document model
3. Improve SVG fidelity
4. Reduce performance bottlenecks
5. Improve usability and professional workflows
6. Add differentiating commercial features

---

## Phase 1: MVP Hardening

### 1. Transactional Undo/Redo

Priority: Critical

Goal:

- Ensure every user gesture becomes one undoable action
- Remove history spam during drag, resize, rotate, and node editing
- Support cancel/revert for active interactions

Scope:

- Done: Add `BatchCommand`
- Done: Add `TransformCommand`
- Done: Add `TextEditCommand`
- Done: Refactor `SelectTool` to preview first, commit once
- Done: Add command tests for undo/redo behavior
- Done: Artboard-aware `VxElement` migration
- Done: Repaired `EditorNotifier` and `HitTester` after the artboardId model expansion

Success criteria:

- One drag = one history item
- One node edit = one history item
- Undo/redo remains stable after every common editor action

Status:

- Done

### 2. Document Model Expansion

Priority: Critical

Goal:

- Extend the model so it can represent more of real SVG and future editor features

Scope:

- Done: Add document versioning
- Done: Add opacity
- Done: Add lock/visible flags
- Done: Add clip path and mask references
- Done: Add stroke dash arrays
- Done: Add fill/stroke style completeness
- Done: Add richer text properties
- Done: Add artboard/page support placeholders
- Done: Add real artboard model and active artboard metadata
- Done: Propagate `artboardId` through element serialization and editing code paths

Success criteria:

- Old project files still open
- New fields serialize and deserialize cleanly
- The model can support pro SVG workflows without a rewrite

Status:

- Done

### 3. SVG Import/Export Fidelity

Priority: Critical

Goal:

- Preserve common authored SVGs more faithfully
- Reduce data loss during import/export

Scope:

- Done: Parse transform lists, not just `matrix(...)`
- Done: Parse inline `style=""` and presentation attributes
- Done: Preserve basic `defs` lookups for gradients
- Done: Improve `symbol` and `use` import/export paths
- Done: Export `viewBox`, opacity, stroke styles, and defs safely
- [x] **Hardening SVG Parsers**
  - *Goal*: Make malformed imports fail softly as a final step to prevent full crash risks.
  - *Status*: Done (wrapped imports in try/catch and added UI snackbars for errors).

Success criteria:

- Common SVG files import without crashing
- Exported SVG is valid XML
- Round-trip loss is reduced for shapes, groups, paths, text, gradients, and symbols

Status:

- Done

---

## Phase 2: Editor Reliability and Performance

### 4. Tool Interaction Cleanup

Priority: High

Goal:

- Separate preview state from committed document state
- Remove direct permanent mutation from tool move events
- Prevent preview state accumulation (Mid-gesture cancellation fixed)

Scope:

- Done: Mid-Gesture Cancellation (`onPointerCancel` explicitly called on keyboard and sidebar switches)

- Done: Refactor `SelectTool`
- Done: Refactor `NodeTool`
- Done: Make text commit explicit
- Done: Add live text preview plus commit/cancel shortcuts
- Add Escape/pointer cancel handling

- [x] **Smart Object Snapping** (IMPLEMENTATION)
  - *Goal*: Snap to centers, edges, and points of other objects during move/resize.
  - *Risk*: N^2 distance checks can cause jank on drag.
  - *Status*: Done (implemented in EditorNotifier, with UI snapping guides in SelectTool).

- [x] **Text Editing Depth** (IMPLEMENTATION)
  - *Goal*: Allow font family, style, and advanced text attributes editing.
  - *Risk*: Flutter text rendering vs SVG text baseline inconsistencies.
  - *Status*: Done (Added TextPropertiesSection with fontFamily).

Success criteria:

- Active gestures are cancellable
- Preview state does not corrupt the document
- History stays clean and predictable

Status:

- Done

### 5. Performance Pass

Priority: High

Goal:

- Keep the editor responsive on medium and large SVGs

Scope:

- Cache element bounds
- Done: Add coarse spatial index for hit testing
- Cache paths for stable path elements
- Add a document scene index for hit testing
- Reduce full-scene repaint churn
- Split rendering into stable layers where possible

Success criteria:

- Large documents remain usable
- Dragging and selection stay responsive
- Hit testing does not degrade sharply as document size grows

Status:

- Not started

### Phase 2 Day Plan

#### Day 1: Undo/Redo Integrity Audit

- Verify every interactive tool uses preview-first and commit-once behavior
- Audit drag, resize, rotate, node edit, text edit, and boolean operations
- Add or tighten tests for gesture cancel, undo, and redo boundaries
- Confirm history does not grow during pointer move previews

Done when:

- Every interaction commits exactly one command
- Cancel leaves the document unchanged
- Tests cover the common gesture paths

#### Day 2: Rendering and Hit-Test Budget

- Profile repaint boundaries in canvas painters
- Cache path generation for stable elements
- Remove unnecessary allocations in scene and selection painters
- Keep the spatial index warm across pointer moves

Done when:

- Large documents remain smooth during pan, zoom, and selection
- The canvas does not repaint unrelated layers on simple edits

#### Day 3: Document and Scene Indexing

- Add or refine a scene index for visible elements
- Reduce repeated bounds calculation
- Separate artboard-local indexing from global element lists
- Keep selection and hit testing aligned with active artboard state

Done when:

- Selection and hit testing scale with document size
- Artboard switching does not require full rebuilds where avoidable

#### Day 4: Interaction Polish

- Tighten selection feedback and handle affordances
- Make cancel and escape paths consistent across tools
- Normalize pointer semantics on desktop and touch
- Remove remaining brittle assumptions in tool state transitions

Done when:

- Tool behavior feels predictable across desktop and mobile
- No interaction path leaves stale preview state behind

#### Day 5: Verification and Regression Sweep

- Run the full test suite
- Review profiling hotspots
- Fix any remaining regressions from the performance work
- Update the roadmap with completed items

Done when:

- Tests pass
- The roadmap is current
- Remaining work is clearly separated into phase 3

---

## Phase 3: Professional Editor UX

### 6. Inspector and Layers Improvements

Priority: High

Goal:

- Make element properties easy to discover and edit

Scope:

- Selection-aware inspector
- Better fill/stroke controls
- Gradient editor
- Text controls
- Transform controls
- Layer rename, lock, hide, search
- Group collapse and isolation

Success criteria:

- Users can find and edit the most important properties without guessing
- Layers become a real workflow tool, not just a list

Status:

- In progress

### 7. Canvas Navigation and Selection UX

Priority: Medium

Goal:

- Make the canvas feel like a professional editor surface

Scope:

- Fit to screen
- Zoom reset
- Zoom percentage display
- Better handle affordances
- Better selection feedback
- Better mobile/tablet navigation behavior

Success criteria:

- Users can orient themselves quickly
- Canvas interaction is clearer and less brittle

Status:

- Not started

### Phase 3 Day Plan

#### Day 1: Layers and Inspector Clarity

- Add stronger element identity cues in the layers list
- Make the inspector header indicate the selected element type more clearly
- Keep selection and multi-selection actions obvious

Done when:

- Users can tell what they are editing without reading raw IDs
- Layers feel like a control surface, not a dump of objects

#### Day 2: Touch and Canvas Controls

- Verify fit-to-screen, zoom-to-selection, and zoom reset on mobile and desktop
- Tighten pinch/drag behavior on touch devices
- Validate handle sizes and selection affordances at low and high zoom

Done when:

- The canvas is usable on tablet-sized screens without guesswork
- Core navigation actions are easy to reach

#### Day 3: Interaction Consistency

- Make cancel and escape behavior consistent in all tools
- Done: Improve bounding box caching speed
- Done: Replace `Stack` layers with optimized native rendering for the canvas background (via `RepaintBoundary` isolation)
- Done: Hardware acceleration profiling
- Confirm layers, inspector, and canvas remain in sync after selection changes
- Remove any remaining confusing affordance mismatches

Done when:

- No common interaction path feels inconsistent across panels

#### Day 4: Regression Sweep

- Run the full test suite
- Check for layout regressions at desktop and narrow widths
- Update the roadmap with the completed UX polish work

Done when:

- Tests pass
- The UI polish work is documented as completed

---

## Phase 4: Feature Expansion

### 8. Core Shape and Path Expansion

Priority: Medium

Goal:

- Expand beyond basic rectangles and ellipses

Scope:

- Done: Add layer lock/hide/search controls
- Done: Polygon tool
- Done: Star tool
- Done: Freehand tool
- Done: Live parameter controls for polygon sides, star spikes/inner ratio, and freehand smoothing
- Done: Line tool
- Done: Persistent shape tool settings in editor state
- Done: Basic path/node editing actions for selected paths
- Done: Native SVG line import/export support
- Done: Undoable path node insert/remove actions
- Done: Canvas midpoint node insertion for path editing
- Done: Node drag edits remain transactional on pointer up
- Done: Clip-path import/export wrappers
- Done: Canvas clipping for clip-path references
- Done: Symbol/use round-trip preservation improvements
- Done: Mask compositing pass in canvas rendering
- Done: Canvas delete-selected-node shortcut in node tool
- Done: Lightweight symbol insertion browser in inspector
- Done: Selection-driven mask assignment and removal
- Done: Symbol asset browser with quick insert cards
- Done: Symbol browser folder filtering and search
- Done: Transparent PNG export preset for masked artwork
- Done: Recursive element updates for nested groups
- Done: Order-independent mask source/target selection
- Done: High-resolution print PNG export preset
- Done: Export dialog with scale and transparency controls
- Done: Full-document tree mask picker
- Done: Symbol asset browser actions for asset management
- Done: PDF export preset for print workflow
- Done: Symbol asset browser card actions
- Done: Export dialog with PDF option
- Done: PDF export page selection controls
- Done: Separate PNG and PDF export dialogs
- Done: PDF soft-mask export support
- Done: Export preset profiles for PNG and PDF
- Done: Dedicated PDF export service wrapper
- Done: Serializable export presets for future editing
- Done: Fixture-based export regression coverage
- Done: Render-hash regression check for masked SVG export
- Done: Export preset manager dialog
- Done: PDF export service extraction seam
- Done: PNG golden regression file for masked SVG export
- Done: Document-metadata persistence for export presets
- Done: Symbol thumbnails in asset browser
- Done: Symbol rename action
- Done: Metadata-backed symbol categories
- Done: Cached symbol thumbnails
- Done: SVG-backed PDF export
- Done: Symbol category manager dialog
- Done: Thumbnail cache key invalidation on symbol edits
- Done: Direct PDF graphics export for core vector shapes
- Done: Recursive clip-path handling in PDF export
- Done: PDF text style fidelity for weight/italic/color
- Done: PDF stroke dash translation
- Done: PDF gradient fallback handling

Success criteria:

- App supports common logo and illustration workflows

Status:

- Done for the current shape slice

### 9. Text Editing Depth

Priority: Medium

Goal:

- Bring text handling closer to a real vector editor

Scope:

- Text on path
- Rich text controls
- Font library management
- Convert text to paths

Success criteria:

- Text workflows are usable for marketing, logos, and layout work

### 10. Production Output

Priority: Medium

Goal:

- Make exports suitable for real customer workflows

Scope:

- Print-ready PDF export
- Bleed and margin controls
- Multi-artboard export batches
- Asset packaging

Success criteria:

- Print and production users can rely on exported output

---

## Phase 4: Feature Expansion

### 8. Core Shape and Path Expansion

Priority: Medium

Goal:

- Expand beyond basic rectangles and ellipses

Scope:

- Line tool
- Polygon tool
- Star tool
- Freehand tool
- Better path/node editing

Success criteria:

- App supports common logo and illustration workflows

### 9. Text Editing Depth

Priority: Medium

Goal:

- Make text editing useful for design work

Scope:

- Font picker
- Weight/style controls
- Alignment
- Spacing
- Line height
- Convert text to path

Success criteria:

- Text behaves like a real design object, not a placeholder

### 10. Snapping and Layout Aids

Priority: Medium

Goal:

- Improve precision editing

Scope:

- Object snapping
- Guide snapping
- Grid snapping improvements
- Rulers
- Guides
- Artboard boundaries

Success criteria:

- Alignment is precise and predictable

---

## Phase 5: Commercial Differentiators

### 11. Reusable Assets and Symbols

Priority: Medium

Goal:

- Support reusable design components

Scope:

- Symbols/components
- Asset library
- Reuse browser
- Drag-in reusable items

Success criteria:

- Users can build consistent reusable design systems

### 12. Templates and Presets

Priority: Medium

Goal:

- Make common creation workflows faster

Scope:

- Templates
- Preset artboards
- Export presets
- Common print/social/web sizes

Success criteria:

- New users can start from sensible defaults

### 13. Print-Ready Export

Priority: Medium

Goal:

- Make the app useful for print shops and production output

Scope:

- PDF export
- Print-safe SVG export
- Page/artboard presets
- Bleed/safe-area support
- Convert text to path workflow

Success criteria:

- Print workflows are possible without external cleanup tools

---

## Recommended 2-Week Sprint

### Week 1

- Transactional undo/redo
- Preview vs commit cleanup for tools
- Model expansion

### Week 2

- SVG import/export fidelity
- Performance pass
- Inspector and layers UX cleanup

---

## File Areas To Change First

### Core Model

- [`lib/models/vx_element.dart`](D:/ketan/github/vectix/lib/models/vx_element.dart)
- [`lib/models/vx_document.dart`](D:/ketan/github/vectix/lib/models/vx_document.dart)
- [`lib/models/converters.dart`](D:/ketan/github/vectix/lib/models/converters.dart)

### State and History

- [`lib/state/editor_state.dart`](D:/ketan/github/vectix/lib/state/editor_state.dart)
- [`lib/state/editor_notifier.dart`](D:/ketan/github/vectix/lib/state/editor_notifier.dart)
- [`lib/state/history_manager.dart`](D:/ketan/github/vectix/lib/state/history_manager.dart)

### Commands

- [`lib/commands/command.dart`](D:/ketan/github/vectix/lib/commands/command.dart)
- [`lib/commands/add_element_command.dart`](D:/ketan/github/vectix/lib/commands/add_element_command.dart)
- [`lib/commands/delete_element_command.dart`](D:/ketan/github/vectix/lib/commands/delete_element_command.dart)
- [`lib/commands/update_element_command.dart`](D:/ketan/github/vectix/lib/commands/update_element_command.dart)
- [`lib/commands/reorder_element_command.dart`](D:/ketan/github/vectix/lib/commands/reorder_element_command.dart)

### Tools

- [`lib/tools/select_tool.dart`](D:/ketan/github/vectix/lib/tools/select_tool.dart)
- [`lib/tools/node_tool.dart`](D:/ketan/github/vectix/lib/tools/node_tool.dart)
- [`lib/tools/text_tool.dart`](D:/ketan/github/vectix/lib/tools/text_tool.dart)
- [`lib/tools/rect_tool.dart`](D:/ketan/github/vectix/lib/tools/rect_tool.dart)
- [`lib/tools/ellipse_tool.dart`](D:/ketan/github/vectix/lib/tools/ellipse_tool.dart)
- [`lib/tools/pen_tool.dart`](D:/ketan/github/vectix/lib/tools/pen_tool.dart)

### Canvas

- [`lib/canvas/editor_canvas.dart`](D:/ketan/github/vectix/lib/canvas/editor_canvas.dart)
- [`lib/canvas/scene_painter.dart`](D:/ketan/github/vectix/lib/canvas/scene_painter.dart)
- [`lib/canvas/hit_tester.dart`](D:/ketan/github/vectix/lib/canvas/hit_tester.dart)

### SVG

- [`lib/svg/svg_importer.dart`](D:/ketan/github/vectix/lib/svg/svg_importer.dart)
- [`lib/svg/svg_exporter.dart`](D:/ketan/github/vectix/lib/svg/svg_exporter.dart)

### UI

- [`lib/ui/editor_screen.dart`](D:/ketan/github/vectix/lib/ui/editor_screen.dart)
- [`lib/ui/inspector/inspector_panel.dart`](D:/ketan/github/vectix/lib/ui/inspector/inspector_panel.dart)
- [`lib/ui/layers/layers_panel.dart`](D:/ketan/github/vectix/lib/ui/layers/layers_panel.dart)
- [`lib/ui/toolbar/tool_sidebar.dart`](D:/ketan/github/vectix/lib/ui/toolbar/tool_sidebar.dart)

---

## Testing Plan

- Model serialization round-trip tests
- Command undo/redo tests
- Transactional gesture tests
- SVG import/export round-trip tests
- Malformed SVG resilience tests
- Large document performance smoke tests
- Canvas interaction widget tests

---

## Definition Of Done For MVP Hardening

- Undo/redo is reliable for all common edits
- SVG import/export is meaningfully less lossy
- The model is ready for advanced SVG features
- The app remains responsive on moderate-size documents
- The editor UX is clear enough for professional use
