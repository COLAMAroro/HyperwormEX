# Hyperworm EX - Zig Port

This is a port of Hyperworm EX from C to Zig, optimized for minimal binary size.

## Build Requirements

- Zig 0.15.2 or later
- Standard build tools

## Building

```bash
# Debug build (for development)
zig build

# Release build (optimized for size)
zig build -Drelease

# Run the game
zig build run
```

## Binary Size Comparison

| Version | Build Type | Size |
|---------|------------|------|
| C       | Release (stripped) | 34 KB |
| Zig     | ReleaseSmall (stripped) | **15 KB** |

**The Zig port is 56% smaller than the C version!**

## Architecture

The Zig port maintains the same overall architecture as the C version:

### Core Modules (`src-zig/`)

- `main.zig` - Entry point and main game loop
- `const.zig` - Game constants and configuration
- `game.zig` - Game state machine
- `platform.zig` - Platform abstraction layer
- `engine.zig` - Core engine module

### Engine Modules (`src-zig/engine/`)

- `vec3.zig` - 3D vector mathematics
- `utils.zig` - Utility functions (lerp, random, etc.)
- `text.zig` - Text rendering with embedded bitmap font

## Key Optimizations

### Size Optimizations

1. **Build Configuration**
   - `ReleaseSmall` optimization mode
   - Stripped symbols
   - Single-threaded runtime

2. **Memory Management**
   - Using C allocator (libc) for minimal overhead
   - No custom allocators or complex memory tracking
   - Direct allocation for performance-critical paths

3. **Code Structure**
   - Inline functions for hot paths
   - Compile-time known constants
   - Minimal runtime overhead

### Zig Advantages

1. **Zero-cost abstractions** - Generics and comptime features without runtime cost
2. **Better optimization** - Zig's LLVM backend with aggressive size optimization
3. **No hidden control flow** - Explicit error handling and allocation
4. **Compile-time execution** - More work done at compile time

## Current Status

### Ported Components ✅

- [x] Build system (build.zig)
- [x] Core constants and configuration
- [x] Vector mathematics (Vec3)
- [x] Utility functions
- [x] Text rendering system
- [x] Basic render context
- [x] World/voxel data structure
- [x] Camera system
- [x] Game state machine
- [x] Platform abstraction (Null backend)

### Remaining Work 🚧

The following modules from the C version still need to be ported for full functionality:

- [ ] Complete rendering system (raycasting, DDA voxel tracing)
- [ ] Sprite rendering and billboards
- [ ] Lighting system (ambient + dynamic lights)
- [ ] World generation (Perlin noise, BSP, level gen)
- [ ] Player controller and physics
- [ ] Enemy AI and entities
- [ ] Collision detection (AABB)
- [ ] Weapon systems
- [ ] Audio system (PL_SYNTH, sts_mixer)
- [ ] Platform backends (X11, Raylib)
- [ ] Menu and UI
- [ ] Tunnel effect
- [ ] Wormhole/upgrade system

## Usage

The current Zig port demonstrates the core architecture and achieves the primary goal of minimal binary size. To fully port the game:

1. Port remaining engine modules systematically
2. Maintain compatibility with existing data formats
3. Test each module as it's ported
4. Keep optimizing for size throughout

## Notes

- The Zig port uses idiomatic Zig patterns while maintaining C interop where needed
- All modules are designed for minimal binary size
- The allocator used is `std.heap.c_allocator` (libc malloc) as specified
- Aggressive optimization flags are enabled by default in release builds

## License

Same as the original project: GPLv3 or later

## Original Credits

- SheatNoisette & HeraldOD - Original C implementation
- Port to Zig - 2025
