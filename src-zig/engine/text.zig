// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");

pub const LETTER_WIDTH = 5;
pub const LETTER_HEIGHT = 7;
pub const LETTER_SPACING = 1;

// Embedded font - " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-/|<>"
pub const system_font = [43][LETTER_HEIGHT]u8{
    .{ 0, 0, 0, 0, 0, 0, 0 }, // Space
    .{ 0b01110, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001 }, // A
    .{ 0b11110, 0b10001, 0b10001, 0b11110, 0b10001, 0b10001, 0b11110 }, // B
    .{ 0b01110, 0b10001, 0b10000, 0b10000, 0b10000, 0b10000, 0b01111 }, // C
    .{ 0b11100, 0b10010, 0b10001, 0b10001, 0b10001, 0b10001, 0b11110 }, // D
    .{ 0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b11111 }, // E
    .{ 0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b10000 }, // F
    .{ 0b01110, 0b10001, 0b10000, 0b10111, 0b10001, 0b10001, 0b01110 }, // G
    .{ 0b10001, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001 }, // H
    .{ 0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b11111 }, // I
    .{ 0b11111, 0b00010, 0b00010, 0b00010, 0b10010, 0b10010, 0b01100 }, // J
    .{ 0b10001, 0b10010, 0b10100, 0b11000, 0b10100, 0b10010, 0b10001 }, // K
    .{ 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b11111 }, // L
    .{ 0b10001, 0b11011, 0b10101, 0b10001, 0b10001, 0b10001, 0b10001 }, // M
    .{ 0b10001, 0b11001, 0b10101, 0b10011, 0b10001, 0b10001, 0b10001 }, // N
    .{ 0b01110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110 }, // O
    .{ 0b11110, 0b10001, 0b10001, 0b11110, 0b10000, 0b10000, 0b10000 }, // P
    .{ 0b01110, 0b10001, 0b10001, 0b10001, 0b10101, 0b01110, 0b00011 }, // Q
    .{ 0b11110, 0b10001, 0b10001, 0b11110, 0b10001, 0b10001, 0b10001 }, // R
    .{ 0b01110, 0b10001, 0b10000, 0b01110, 0b00001, 0b10001, 0b01110 }, // S
    .{ 0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100 }, // T
    .{ 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110 }, // U
    .{ 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01010, 0b00100 }, // V
    .{ 0b10001, 0b10001, 0b10001, 0b10001, 0b10101, 0b11011, 0b10001 }, // W
    .{ 0b10001, 0b10001, 0b01010, 0b00100, 0b01010, 0b10001, 0b10001 }, // X
    .{ 0b10001, 0b10001, 0b01010, 0b00100, 0b00100, 0b00100, 0b00100 }, // Y
    .{ 0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b10000, 0b11111 }, // Z
    .{ 0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110 }, // 0
    .{ 0b00100, 0b01100, 0b10100, 0b00100, 0b00100, 0b00100, 0b11111 }, // 1
    .{ 0b01110, 0b10001, 0b00001, 0b00010, 0b00100, 0b01000, 0b11111 }, // 2
    .{ 0b01110, 0b10001, 0b00001, 0b00110, 0b00001, 0b10001, 0b01110 }, // 3
    .{ 0b00010, 0b00110, 0b01010, 0b10010, 0b11111, 0b00010, 0b00010 }, // 4
    .{ 0b11111, 0b10000, 0b10000, 0b11110, 0b00001, 0b00001, 0b11110 }, // 5
    .{ 0b01110, 0b10001, 0b10000, 0b11110, 0b10001, 0b10001, 0b01110 }, // 6
    .{ 0b11111, 0b00001, 0b00010, 0b00100, 0b00100, 0b00100, 0b00100 }, // 7
    .{ 0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110 }, // 8
    .{ 0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b10001, 0b01110 }, // 9
    .{ 0b00000, 0b00000, 0b00000, 0b00000, 0b00000, 0b01100, 0b01100 }, // .
    .{ 0b00000, 0b00000, 0b00000, 0b11111, 0b00000, 0b00000, 0b00000 }, // -
    .{ 0b00001, 0b00010, 0b00010, 0b00100, 0b00100, 0b01000, 0b01000 }, // /
    .{ 0b00110, 0b00110, 0b00110, 0b00110, 0b00110, 0b00110, 0b00110 }, // |
    .{ 0b00000, 0b00100, 0b01100, 0b11111, 0b01100, 0b00100, 0b00000 }, // <
    .{ 0b00000, 0b00100, 0b00110, 0b11111, 0b00110, 0b00100, 0b00000 }, // >
};

fn charToIndex(c: u8) usize {
    return switch (c) {
        ' ' => 0,
        '0'...'9' => (c - '0') + 27,
        '.' => 37,
        '-' => 38,
        '/' => 39,
        '|' => 40,
        '<' => 41,
        '>' => 42,
        else => c & 0x1F, // Letters A-Z
    };
}

pub fn draw(
    buffer: []u32,
    buffer_width: usize,
    buffer_height: usize,
    text: []const u8,
    position_x: usize,
    position_y: usize,
    color: u32,
) void {
    var x = position_x;
    for (text) |c| {
        const index = charToIndex(c);

        for (0..LETTER_HEIGHT) |row| {
            const bits = system_font[index][row];
            for (0..LETTER_WIDTH) |col| {
                if ((bits & (@as(u8, 1) << @intCast(LETTER_WIDTH - 1 - col))) != 0) {
                    const px = x + col;
                    const py = position_y + row;
                    if (px < buffer_width and py < buffer_height) {
                        buffer[py * buffer_width + px] = 0xff000000 | color;
                    }
                }
            }
        }

        x += LETTER_WIDTH + LETTER_SPACING;
    }
}

pub fn drawCentered(
    buffer: []u32,
    buffer_width: usize,
    buffer_height: usize,
    text: []const u8,
    position_y: usize,
    color: u32,
) void {
    const text_width = text.len * (LETTER_WIDTH + LETTER_SPACING);
    const start_x = if (text_width < buffer_width) (buffer_width - text_width) / 2 else 0;
    draw(buffer, buffer_width, buffer_height, text, start_x, position_y, color);
}
