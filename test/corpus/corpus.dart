/// The SVG fidelity corpus.
///
/// Each entry is a small, self-contained SVG exercising one area of the format
/// that Vectix claims to support. The corpus exists because every fidelity
/// claim in this project that was not backed by a rendered test turned out to
/// be optimistic: `<defs>` masks being dropped, transposed `matrix()`
/// transforms, missing fill defaults, ignored gradient geometry — all of them
/// survived code review and only showed up when pixels were compared.
///
/// **The corpus is a regression baseline, not a conformance oracle.** The
/// committed render hashes record what Vectix produced when they were last
/// reviewed; they cannot prove the output is correct. Correctness lives in the
/// targeted tests (`svg_style_test.dart`, `svg_transform_test.dart`,
/// `mask_defs_regression_test.dart`, `gradient_geometry_test.dart`) and in
/// reading the spec. What the corpus does prove is that none of it *changes*
/// without somebody noticing.
///
/// Text is deliberately absent: glyph rendering depends on the fonts installed
/// on the machine, so a text file cannot produce a stable hash across the dev
/// machine and CI. Text properties are covered structurally instead.
///
/// To extend the corpus, drop real exported `.svg` files into `test/corpus/`
/// (they are picked up automatically) or add an entry here.
library;

import 'dart:io';

/// Built-in corpus, keyed by a stable name.
///
/// Names appear in the committed hash manifest, so renaming an entry means
/// regenerating it.
const Map<String, String> inlineCorpus = {
  'shapes_basic': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <rect x="2" y="2" width="20" height="14" fill="#3366cc"/>
  <circle cx="40" cy="9" r="7" fill="#cc3366"/>
  <ellipse cx="70" cy="9" rx="12" ry="6" fill="#33cc66"/>
  <line x1="2" y1="26" x2="30" y2="26" stroke="#000000" stroke-width="2"/>
  <polygon points="40,20 60,20 50,34" fill="#ff9900"/>
  <polyline points="66,34 72,22 78,34 84,22" fill="none" stroke="#6633cc" stroke-width="2"/>
  <path d="M2 40 L20 40 L20 56 L2 56 Z" fill="#999999"/>
</svg>''',

  'path_curves': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <path d="M10 10 C 30 0, 50 30, 70 10" fill="none" stroke="#000000" stroke-width="3"/>
  <path d="M10 40 Q 40 20, 70 40 T 90 40" fill="none" stroke="#cc0000" stroke-width="3"/>
  <path d="M20 60 A 20 20 0 0 1 60 60 Z" fill="#00aa88"/>
  <path d="M10 80 L10 90 L40 90 L40 80 Z M 15 82 L15 88 L35 88 L35 82 Z" fill="#555555"/>
</svg>''',

  'group_inheritance': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <g fill="#1f77b4" stroke="#333333" stroke-width="2">
    <rect x="4" y="4" width="30" height="30"/>
    <g>
      <circle cx="60" cy="19" r="15"/>
      <rect x="4" y="50" width="30" height="30" fill="#ff7f0e"/>
    </g>
  </g>
</svg>''',

  'icon_set': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" fill="none"
     stroke="#222222" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M10 50 L50 10 L90 50"/>
  <path d="M20 50 L20 90 L80 90 L80 50"/>
  <circle cx="50" cy="70" r="8"/>
</svg>''',

  'transform_translate_scale': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <g transform="translate(10 10)">
    <rect x="0" y="0" width="20" height="20" fill="#2266aa"/>
    <g transform="scale(2)">
      <rect x="20" y="0" width="10" height="10" fill="#aa2266"/>
    </g>
  </g>
</svg>''',

  'transform_rotate': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <rect x="30" y="30" width="40" height="20" fill="#0088cc"
        transform="rotate(30 50 40)"/>
  <rect x="10" y="70" width="20" height="20" fill="#88cc00"
        transform="rotate(45)"/>
</svg>''',

  // A rotation+skew pair written as matrix(), which is what design tools emit.
  // Guards the column-major parsing bug (P1-1).
  'transform_matrix': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <rect x="0" y="0" width="20" height="10" fill="#dd3333"
        transform="matrix(0.866,0.5,-0.5,0.866,20,20)"/>
  <rect x="0" y="0" width="20" height="10" fill="#3333dd"
        transform="matrix(1,0,0.5,1,20,60)"/>
</svg>''',

  'transform_nested': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <g transform="translate(50 50)">
    <g transform="rotate(20)">
      <g transform="scale(1.5)">
        <rect x="-20" y="-10" width="40" height="20" fill="#66aa22"/>
      </g>
    </g>
  </g>
</svg>''',

  'gradient_linear_horizontal': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="g">
      <stop offset="0" stop-color="#ff0000"/>
      <stop offset="1" stop-color="#0000ff"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="100" height="100" fill="url(#g)"/>
</svg>''',

  'gradient_linear_vertical': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#00ff00"/>
      <stop offset="1" stop-color="#000000"/>
    </linearGradient>
  </defs>
  <rect x="10" y="10" width="80" height="80" fill="url(#g)"/>
</svg>''',

  'gradient_linear_userspace': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="g" gradientUnits="userSpaceOnUse"
                    x1="0" y1="0" x2="100" y2="100">
      <stop offset="0" stop-color="#ffcc00"/>
      <stop offset="0.5" stop-color="#ff0000"/>
      <stop offset="1" stop-color="#660099"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="100" height="100" fill="url(#g)"/>
</svg>''',

  'gradient_linear_percent': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="100%" stop-color="#003366"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="100" height="100" fill="url(#g)"/>
</svg>''',

  'gradient_radial': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <radialGradient id="g">
      <stop offset="0" stop-color="#ffffff"/>
      <stop offset="1" stop-color="#cc0000"/>
    </radialGradient>
  </defs>
  <circle cx="50" cy="50" r="45" fill="url(#g)"/>
</svg>''',

  'gradient_stop_opacity': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#000000" stop-opacity="0.1"/>
      <stop offset="0.5" stop-color="#0066ff" stop-opacity="0.8"/>
      <stop offset="1" stop-color="#00ff66" stop-opacity="1"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="100" height="100" fill="url(#g)"/>
</svg>''',

  'gradient_on_group': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#ff9900"/>
      <stop offset="1" stop-color="#006699"/>
    </linearGradient>
  </defs>
  <g fill="url(#g)">
    <rect x="5" y="5" width="40" height="40"/>
    <rect x="55" y="55" width="40" height="40"/>
  </g>
</svg>''',

  'mask_luminance': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <mask id="m">
      <rect x="0" y="0" width="100" height="100" fill="white"/>
      <circle cx="50" cy="50" r="25" fill="black"/>
      <rect x="0" y="0" width="20" height="100" fill="#808080"/>
    </mask>
  </defs>
  <g mask="url(#m)">
    <rect x="0" y="0" width="100" height="100" fill="#0099cc"/>
    <circle cx="50" cy="50" r="40" fill="#ff6600"/>
  </g>
</svg>''',

  'clip_path_single': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <clipPath id="c">
      <circle cx="50" cy="50" r="35"/>
    </clipPath>
  </defs>
  <rect x="0" y="0" width="100" height="100" fill="#333366" clip-path="url(#c)"/>
</svg>''',

  'clip_path_multi': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <clipPath id="c">
      <rect x="0" y="0" width="50" height="100"/>
      <rect x="60" y="0" width="40" height="50"/>
    </clipPath>
  </defs>
  <g clip-path="url(#c)">
    <rect x="0" y="0" width="100" height="100" fill="#99cc00"/>
    <path d="M0 100 L100 0" stroke="#000000" stroke-width="6"/>
  </g>
</svg>''',

  'symbol_and_use': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <symbol id="tile">
      <rect x="0" y="0" width="20" height="20" fill="#cc0066"/>
      <circle cx="10" cy="10" r="5" fill="#ffffff"/>
    </symbol>
  </defs>
  <use href="#tile"/>
  <use href="#tile" transform="translate(30 0)"/>
  <use href="#tile" transform="translate(65 0)"/>
</svg>''',

  'rounded_rect': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <rect x="5" y="5" width="90" height="40" rx="12" fill="#4477aa"/>
  <rect x="5" y="55" width="90" height="40" ry="10" fill="#aa7744"/>
</svg>''',

  'stroke_features': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <path d="M5 15 L95 15" stroke="#000000" stroke-width="4" stroke-dasharray="8 4" fill="none"/>
  <path d="M5 35 L95 35" stroke="#cc0000" stroke-width="6" stroke-linecap="round" fill="none"/>
  <path d="M5 55 L60 55 L60 85" stroke="#008800" stroke-width="6"
        stroke-linejoin="bevel" fill="none"/>
  <path d="M70 55 L95 55 L95 85" stroke="#0000cc" stroke-width="6"
        stroke-linejoin="round" fill="none"/>
  <path d="M5 95 L95 95" stroke="#000000" stroke-width="0" fill="none"/>
</svg>''',

  'colors_hex_forms': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <rect x="0" y="0" width="50" height="50" fill="#f00"/>
  <rect x="50" y="0" width="50" height="50" fill="#0f08"/>
  <rect x="0" y="50" width="50" height="50" fill="#3366cccc"/>
  <rect x="50" y="50" width="50" height="50" fill="#123456"/>
</svg>''',

  'colors_functions': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <g color="#ff8800">
    <rect x="0" y="0" width="25" height="50" fill="rgb(255, 0, 0)"/>
    <rect x="25" y="0" width="25" height="50" fill="rgba(0, 0, 255, 0.5)"/>
    <rect x="50" y="0" width="25" height="50" fill="hsl(120, 100%, 50%)"/>
    <rect x="75" y="0" width="25" height="50" fill="rebeccapurple"/>
  </g>
  <rect x="0" y="50" width="25" height="50" fill="rgb(100%, 50%, 0%)"/>
  <rect x="25" y="50" width="25" height="50" fill="currentColor"/>
  <rect x="50" y="50" width="25" height="50" fill="transparent"/>
  <rect x="75" y="50" width="25" height="50" fill="steelblue"/>
</svg>''',

  'style_attribute': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <rect x="5" y="5" width="40" height="40"
        style="fill:#ffcc00;stroke:#333333;stroke-width:3"/>
  <g style="fill:none;stroke:#009900;stroke-width:5;stroke-linecap:square">
    <path d="M5 60 L45 90"/>
    <path d="M55 60 L95 90"/>
  </g>
</svg>''',

  'nested_deep': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <g fill="#dd2222" transform="translate(50 50)">
    <g fill="#22dd22" transform="rotate(10)">
      <g fill="#2222dd" transform="scale(0.8)">
        <g fill="#dddd22">
          <g>
            <rect x="-30" y="-30" width="20" height="20"/>
            <rect x="10" y="10" width="20" height="20"/>
          </g>
        </g>
      </g>
    </g>
  </g>
</svg>''',

  'empty_group': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <g></g>
  <g fill="#123456"></g>
  <rect x="25" y="25" width="50" height="50" fill="#abcdef"/>
</svg>''',

  'defs_only': r'''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="unused">
      <stop offset="0" stop-color="#000000"/>
      <stop offset="1" stop-color="#ffffff"/>
    </linearGradient>
    <symbol id="unusedSymbol">
      <rect x="0" y="0" width="10" height="10"/>
    </symbol>
  </defs>
</svg>''',
};

/// Directory scanned for extra corpus files, so real exported artwork can be
/// dropped in without touching code.
const String corpusDirectory = 'test/corpus';

/// All corpus entries: built-in plus any `*.svg` found in [corpusDirectory].
Map<String, String> loadCorpus() {
  final corpus = Map<String, String>.from(inlineCorpus);
  final dir = Directory(corpusDirectory);
  if (!dir.existsSync()) return corpus;
  for (final entity in dir.listSync()) {
    if (entity is! File || !entity.path.endsWith('.svg')) continue;
    final name = entity.uri.pathSegments.last.replaceAll('.svg', '');
    corpus[name] = entity.readAsStringSync();
  }
  return corpus;
}
