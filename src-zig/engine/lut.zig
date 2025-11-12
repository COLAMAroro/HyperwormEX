// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later
//
// Color LUT (Lookup Table) system

const std = @import("std");
const utils = @import("utils.zig");

pub const LUT_COLORS_R = 256;
pub const LUT_COLORS_G = 256;
pub const LUT_COLORS_B = 256;

// Main LUT - 256x256x256 = 16,777,216 entries * 4 bytes = 67MB
var system_lut: [LUT_COLORS_R][LUT_COLORS_G][LUT_COLORS_B]u32 = undefined;

pub fn convertRgb(r: u8, g: u8, b: u8) u32 {
    return system_lut[r][g][b];
}

pub fn reset() void {
    for (0..LUT_COLORS_R) |r| {
        for (0..LUT_COLORS_G) |g| {
            for (0..LUT_COLORS_B) |b| {
                system_lut[r][g][b] = utils.rgba2u32(@intCast(r), @intCast(g), @intCast(b), 0xff);
            }
        }
    }
}

pub fn build(colors: []const u32) void {
    for (0..LUT_COLORS_R) |r| {
        for (0..LUT_COLORS_G) |g| {
            for (0..LUT_COLORS_B) |b| {
                var match_color_pos: usize = 0;
                var match_distance_min: usize = std.math.maxInt(usize);

                for (colors, 0..) |color, idx| {
                    // Extract RGB from color
                    const current_r: i32 = @intCast((color >> 16) & 0xff);
                    const current_g: i32 = @intCast((color >> 8) & 0xff);
                    const current_b: i32 = @intCast(color & 0xff);

                    // Calculate distance (squared Euclidean)
                    const dr = @as(i32, @intCast(r)) - current_r;
                    const dg = @as(i32, @intCast(g)) - current_g;
                    const db = @as(i32, @intCast(b)) - current_b;
                    
                    const dist: usize = @intCast(dr * dr + dg * dg + db * db);

                    if (dist < match_distance_min) {
                        match_color_pos = idx;
                        match_distance_min = dist;
                    }
                }

                // Use the closest match
                const matched_color = colors[match_color_pos];
                const matched_r: u8 = @intCast((matched_color >> 16) & 0xff);
                const matched_g: u8 = @intCast((matched_color >> 8) & 0xff);
                const matched_b: u8 = @intCast(matched_color & 0xff);
                
                system_lut[r][g][b] = utils.rgba2u32(matched_r, matched_g, matched_b, 0xff);
            }
        }
    }
}
