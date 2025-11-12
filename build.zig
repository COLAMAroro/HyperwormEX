const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    
    // Default to ReleaseSmall for minimal binary size
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    // Backend selection option
    const backend = b.option(
        []const u8,
        "backend",
        "Graphics backend to use: null, x11, or raylib (default: null)",
    ) orelse "null";

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

    // Add build option for backend selection
    const options = b.addOptions();
    options.addOption([]const u8, "backend", backend);
    exe.root_module.addImport("build_options", options.createModule());

    // Link libc for system calls and math functions
    exe.linkLibC();

    // Backend-specific dependencies
    if (std.mem.eql(u8, backend, "x11")) {
        // X11 backend requires X11, GLX, and GL libraries
        exe.linkSystemLibrary("X11");
        exe.linkSystemLibrary("GL");
    } else if (std.mem.eql(u8, backend, "raylib")) {
        // Raylib backend
        // Try to find raylib via pkg-config or system
        exe.linkSystemLibrary("raylib");
    }
    // Null backend needs no additional libraries

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
