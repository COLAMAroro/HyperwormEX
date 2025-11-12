// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const Vec3 = @import("vec3.zig").Vec3;

pub const AABB = struct {
    min_x: f32,
    min_y: f32,
    min_z: f32,
    max_x: f32,
    max_y: f32,
    max_z: f32,

    pub fn pointInside(self: AABB, point: Vec3) bool {
        return point.x >= self.min_x and point.x <= self.max_x and
            point.y >= self.min_y and point.y <= self.max_y and
            point.z >= self.min_z and point.z <= self.max_z;
    }

    pub fn overlap(a: AABB, b: AABB) bool {
        return a.min_x <= b.max_x and a.max_x >= b.min_x and
            a.min_y <= b.max_y and a.max_y >= b.min_y and
            a.min_z <= b.max_z and a.max_z >= b.min_z;
    }

    pub fn offset(self: AABB, off: Vec3) AABB {
        return .{
            .min_x = self.min_x + off.x,
            .min_y = self.min_y + off.y,
            .min_z = self.min_z + off.z,
            .max_x = self.max_x + off.x,
            .max_y = self.max_y + off.y,
            .max_z = self.max_z + off.z,
        };
    }

    pub fn extents(self: AABB) Vec3 {
        return .{
            .x = self.max_x - self.min_x,
            .y = self.max_y - self.min_y,
            .z = self.max_z - self.min_z,
        };
    }

    pub fn fromSize(width: f32, height: f32) AABB {
        const half_w = width / 2.0;
        return .{
            .min_x = -half_w,
            .min_y = 0.0,
            .min_z = -half_w,
            .max_x = half_w,
            .max_y = height,
            .max_z = half_w,
        };
    }
};
