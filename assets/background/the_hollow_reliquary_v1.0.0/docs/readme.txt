THE HOLLOW RELIQUARY - GOTHIC METROIDVANIA ENVIRONMENT PACK
Version 1.0.0 | 32x32 side-view pixel art

OVERVIEW
Build underground chapels, ruined sanctuaries and cursed reliquaries for a
side-scrolling action game or metroidvania. Every usable asset is original,
drawn at native pixel resolution and delivered without embedded labels.

CONTENTS
- 47-piece 8-neighbor blob autotile in stone and moss variants
- 64 modular architecture tiles
- 23 separate environmental props
- 6 animated elements: candle, brazier, sigil, drip, spikes and ground mist
- Individual animation frames and horizontal spritesheets
- 3 background/parallax layers at 512x288
- Tiled TSX terrain file and a 16x9 TMX sample map
- 630x500 cover, two scene sizes and three 960x540 store images
- Autotile mapping, collision guide, palette, manifest and license

TECHNICAL SPECIFICATION
- Perspective: side-view / platformer
- Grid: 32x32 pixels
- Format: PNG RGBA with true transparency
- Base light: cold upper-left; emissive fire and violet magic are local accents
- Animation pivot: bottom-center unless manifest.json says otherwise
- Naming: lowercase ASCII with deterministic zero-based frame indices
- Scaling: use integer scale factors and nearest-neighbor filtering

QUICK IMPORT
Unity: Texture Type Sprite (2D and UI), Filter Mode Point, Compression None,
       Pixels Per Unit 32. Slice sheets using the dimensions in manifest.json.
Godot: set the Canvas texture filter to Nearest. Use region/grid slicing with
       the frame dimensions listed in manifest.json.
Unreal: apply the 2D Pixels texture group, nearest filtering and no texture
        compression that introduces color bleeding.

TILED
Open engine/tiled/demo_map.tmx. The terrain TSX references the stone sheet with
a relative path. Tile 0 is empty; terrain tiles are local IDs 1 through 47.
The exact 8-neighbor mask for every tile is in docs/autotile_47_map.json.

STORE DISPLAY
Previews contain promotional text; usable tiles, props, backgrounds, frames and
spritesheets do not. GIF files are previews only and are enlarged 4x.

SUPPORT / VERSIONING
Keep this ZIP as the original v1.0.0 archive. When updating a project, compare
docs/changelog.txt and manifest.json before replacing imported textures.
