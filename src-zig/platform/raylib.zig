// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later
//
// Raylib backend - cross-platform rendering

const std = @import("std");
const engine = @import("../engine.zig");
const c = @import("../const.zig");

// Raylib C bindings
const raylib = @cImport({
    @cInclude("raylib.h");
});

pub const Platform = struct {
    allocator: std.mem.Allocator,
    fb_texture: raylib.Texture2D,
    fb_pixels: []raylib.Color,
    mouse_locked: bool,

    pub fn init() !Platform {
        std.debug.print("[PLATFORM] Initializing Raylib backend...\n", .{});

        const allocator = std.heap.c_allocator;

        // Initialize window
        raylib.InitWindow(c.WINDOW_WIDTH, c.WINDOW_HEIGHT, c.WINDOW_NAME ++ " - (Raylib)");
        raylib.SetTargetFPS(9999);
        raylib.SetWindowState(raylib.FLAG_WINDOW_RESIZABLE);
        raylib.SetExitKey(0);

        // Create render texture for software framebuffer
        const fb_render_texture = raylib.LoadRenderTexture(c.SOFTWARE_WIDTH, c.SOFTWARE_HEIGHT);
        const fb_texture = fb_render_texture.texture;
        
        // Allocate pixel buffer
        const fb_pixels = try allocator.alloc(raylib.Color, c.SOFTWARE_WIDTH * c.SOFTWARE_HEIGHT);
        
        // Set texture filter to point (pixel-perfect)
        raylib.SetTextureFilter(fb_texture, raylib.TEXTURE_FILTER_POINT);

        return Platform{
            .allocator = allocator,
            .fb_texture = fb_texture,
            .fb_pixels = fb_pixels,
            .mouse_locked = false,
        };
    }

    pub fn deinit(self: *Platform) void {
        std.debug.print("[PLATFORM] Shutting down Raylib...\n", .{});
        
        self.allocator.free(self.fb_pixels);
        raylib.CloseWindow();
    }

    pub fn update(self: *Platform, render: *engine.Render) bool {
        // Check if window should close
        if (raylib.WindowShouldClose()) {
            return false;
        }

        // Get delta time
        render.dt = raylib.GetFrameTime();
        if (render.dt > 0.25) {
            render.dt = 0.25;
        }

        // Update mouse buttons
        const mouse_click_left: u8 = if (raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT)) 0x01 else 0;
        const mouse_click_right: u8 = if (raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_RIGHT)) 0x02 else 0;
        _ = mouse_click_left;
        _ = mouse_click_right;
        // render.mouse_click = mouse_click_left | mouse_click_right; // Would need to add this to Render struct

        // Toggle mouse lock
        if (raylib.IsMouseButtonPressed(raylib.MOUSE_BUTTON_LEFT) and !self.mouse_locked) {
            self.mouse_locked = true;
            raylib.HideCursor();
            raylib.DisableCursor();
        }

        if (raylib.IsKeyPressed(raylib.KEY_ESCAPE) and self.mouse_locked) {
            self.mouse_locked = false;
            raylib.ShowCursor();
            raylib.EnableCursor();
        }

        // Update mouse delta for FPS camera
        if (self.mouse_locked) {
            const mouse_pos = raylib.GetMousePosition();
            const screen_center_x: i32 = @divTrunc(raylib.GetScreenWidth(), 2);
            const screen_center_y: i32 = @divTrunc(raylib.GetScreenHeight(), 2);

            // Calculate delta (would need to store in render struct)
            _ = mouse_pos.x - @as(f32, @floatFromInt(screen_center_x));
            _ = mouse_pos.y - @as(f32, @floatFromInt(screen_center_y));

            // Wrap mouse to center
            raylib.SetMousePosition(screen_center_x, screen_center_y);
        }

        return true;
    }

    pub fn renderBegin(self: *Platform, render: *engine.Render) void {
        // Copy framebuffer to pixel buffer
        // Convert from RGBA u32 to Raylib Color
        for (0..c.SOFTWARE_HEIGHT) |y| {
            for (0..c.SOFTWARE_WIDTH) |x| {
                const pos = x + y * c.SOFTWARE_WIDTH;
                const pixel = render.frame_buffer[pos];
                
                self.fb_pixels[pos] = raylib.Color{
                    .r = @intCast(pixel & 0xFF),
                    .g = @intCast((pixel >> 8) & 0xFF),
                    .b = @intCast((pixel >> 16) & 0xFF),
                    .a = 255,
                };
            }
        }
    }

    pub fn renderEnd(self: *Platform, render: *engine.Render) void {
        _ = render;
        // Update texture with new pixels
        raylib.UpdateTexture(self.fb_texture, self.fb_pixels.ptr);

        // Draw to screen
        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.BLACK);

        const source_rec = raylib.Rectangle{
            .x = 0,
            .y = 0,
            .width = @floatFromInt(self.fb_texture.width),
            .height = @floatFromInt(self.fb_texture.height),
        };

        const dest_rec = raylib.Rectangle{
            .x = 0,
            .y = 0,
            .width = @floatFromInt(raylib.GetScreenWidth()),
            .height = @floatFromInt(raylib.GetScreenHeight()),
        };

        const origin = raylib.Vector2{ .x = 0, .y = 0 };

        raylib.DrawTexturePro(self.fb_texture, source_rec, dest_rec, origin, 0.0, raylib.WHITE);
        raylib.EndDrawing();
    }
};
