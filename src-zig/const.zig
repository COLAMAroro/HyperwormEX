// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

// Engine configuration constants

// Engine flags
pub const SAFE_MODE = false;
pub const ENABLE_FOG = true;
pub const UNREAL_TEX_AA = true;
pub const NINTENDO_64 = false;
pub const ENABLE_LUT = true;

// Software renderer size
pub const SOFTWARE_WIDTH: usize = 320;
pub const SOFTWARE_HEIGHT: usize = 180;

// Real GL Window
pub const WINDOW_WIDTH: usize = 1280;
pub const WINDOW_HEIGHT: usize = 720;
pub const WINDOW_NAME = "HYPERWORM EX - 1.1";

// Rendering distances
pub const RENDER_DISTANCE: f32 = 64.0;
pub const RENDER_SPRITE_DISTANCE: f32 = 30.0;
pub const RENDER_DIV: usize = 1;

// Float limits
pub const ENGINE_MIN_FLOAT: f32 = 1e-6;
pub const ENGINE_MAX_FLOAT: f32 = 1e9;

// FOV
pub const FOV_DEG: f32 = 90.0;
pub const FOV: f32 = FOV_DEG * 0.01745329;

// Texture size
pub const TEX_SIZE: usize = 32;

// Lighting
pub const MAX_LIGHTS: usize = 2;
pub const AMBIENT_LIGHT_COLOR: u32 = 0xFFFFFF;
pub const SKY_COLOR: u32 = 0x202020;
pub const AMBIENT_INTENSITY: f32 = 0.25;

// Textures
pub const MAX_TEXTURES: usize = 16;

// Fog
pub const FOG_INTENSITY: f32 = 1.0;

// Physics
pub const GRAVITY: f32 = 22.0;

// Actors
pub const MAX_ACTORS: usize = 128;
