// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");
const c = @import("const.zig");

pub const vec3 = @import("engine/vec3.zig");
pub const utils = @import("engine/utils.zig");
pub const text = @import("engine/text.zig");
pub const aabb = @import("engine/aabb.zig");
pub const camera = @import("engine/camera.zig");
pub const lut = @import("engine/lut.zig");

pub const Vec3 = vec3.Vec3;
pub const AABB = aabb.AABB;
pub const Camera = camera.Camera;

// Simple world structure (voxel data)
pub const World = struct {
    width: usize,
    height: usize,
    depth: usize,
    data: []u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize, depth: usize) !World {
        const size = width * height * depth;
        const data = try allocator.alloc(u8, size);
        @memset(data, 0);

        return World{
            .width = width,
            .height = height,
            .depth = depth,
            .data = data,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *World) void {
        self.allocator.free(self.data);
    }

    pub inline fn get(self: *const World, x: usize, y: usize, z: usize) u8 {
        if (x >= self.width or y >= self.height or z >= self.depth) {
            return 0;
        }
        const idx = x + y * self.width + z * self.width * self.height;
        return self.data[idx];
    }

    pub inline fn set(self: *World, x: usize, y: usize, z: usize, value: u8) void {
        if (x >= self.width or y >= self.height or z >= self.depth) {
            return;
        }
        const idx = x + y * self.width + z * self.width * self.height;
        self.data[idx] = value;
    }
};



// Main render context
pub const Render = struct {
    width: usize,
    height: usize,
    frame_buffer: []u32,
    depth_buffer: []f32,
    cam: Camera,
    world: ?*World,
    dt: f32,
    allocator: std.mem.Allocator,

    pub fn init(width: usize, height: usize) !Render {
        const allocator = std.heap.c_allocator;
        const frame_buffer = try allocator.alloc(u32, width * height);
        const depth_buffer = try allocator.alloc(f32, width * height);

        @memset(frame_buffer, c.SKY_COLOR);
        @memset(depth_buffer, 0.0);

        return Render{
            .width = width,
            .height = height,
            .frame_buffer = frame_buffer,
            .depth_buffer = depth_buffer,
            .cam = Camera.init(.{ .x = 0.0, .y = 0.0, .z = 0.0 }),
            .world = null,
            .dt = 0.016, // ~60 FPS default
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Render) void {
        self.allocator.free(self.frame_buffer);
        self.allocator.free(self.depth_buffer);
    }

    pub fn clear(self: *Render) void {
        @memset(self.frame_buffer, c.SKY_COLOR);
        @memset(self.depth_buffer, c.RENDER_DISTANCE);
    }

    pub fn drawText(self: *Render, txt: []const u8, y: usize) void {
        const text_mod = @import("engine/text.zig");
        text_mod.drawCentered(self.frame_buffer, self.width, self.height, txt, y, 0xFFFFFF);
    }

    pub fn renderWorld(self: *Render) void {
        // World rendering would be implemented here
        _ = self;
    }
};
