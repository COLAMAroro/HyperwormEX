// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;

pub const Camera = struct {
    pos: Vec3,
    yaw: f32,
    pitch: f32,
    pitch_offset: f32,
    forward: Vec3,
    right: Vec3,
    up: Vec3,

    pub fn init(pos: Vec3) Camera {
        var cam = Camera{
            .pos = pos,
            .yaw = 0.0,
            .pitch = 0.0,
            .pitch_offset = 0.0,
            .forward = .{ .x = 1.0, .y = 0.0, .z = 0.0 },
            .right = .{ .x = 0.0, .y = 0.0, .z = -1.0 },
            .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        };
        cam.updateVectors();
        return cam;
    }

    pub fn updateVectors(self: *Camera) void {
        const math = std.math;
        const total_pitch = self.pitch + self.pitch_offset;

        // Clamp pitch to avoid gimbal lock
        const clamped_pitch = @max(-1.5, @min(1.5, total_pitch));

        // Calculate forward vector
        self.forward.x = @cos(self.yaw) * @cos(clamped_pitch);
        self.forward.y = @sin(clamped_pitch);
        self.forward.z = @sin(self.yaw) * @cos(clamped_pitch);
        self.forward = self.forward.normalize();

        // Calculate right vector
        self.right.x = @cos(self.yaw - math.pi / 2.0);
        self.right.y = 0.0;
        self.right.z = @sin(self.yaw - math.pi / 2.0);
        self.right = self.right.normalize();

        // Calculate up vector
        self.up.x = self.right.y * self.forward.z - self.right.z * self.forward.y;
        self.up.y = self.right.z * self.forward.x - self.right.x * self.forward.z;
        self.up.z = self.right.x * self.forward.y - self.right.y * self.forward.x;
    }
};
