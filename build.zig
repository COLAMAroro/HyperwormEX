const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    
    // Default to ReleaseSmall for minimal binary size
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    // Main executable
    const exe = b.addExecutable(.{
        .name = "hyperworm",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src-zig/main.zig"),
            .target = target,
            .optimize = optimize,
            .strip = true,
            .single_threaded = true,
        }),
    });

    // Link libc for system calls and math functions
    exe.linkLibC();

    // Install the executable
    b.installArtifact(exe);

    // Run step
    const run_step = b.step("run", "Run the game");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
