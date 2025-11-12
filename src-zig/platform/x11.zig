// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later
//
// X11 backend with OpenGL rendering

const std = @import("std");
const engine = @import("../engine.zig");
const c = @import("../const.zig");

// X11 and OpenGL C bindings
const X11 = @cImport({
    @cInclude("X11/Xlib.h");
    @cInclude("X11/Xutil.h");
    @cInclude("GL/gl.h");
    @cInclude("GL/glx.h");
    @cInclude("time.h");
});

pub const Platform = struct {
    allocator: std.mem.Allocator,
    display: *X11.Display,
    root: X11.Window,
    window: X11.Window,
    visual_info: *X11.XVisualInfo,
    colormap: X11.Colormap,
    glx_context: X11.GLXContext,
    texture_id: X11.GLuint,
    invisible_cursor: X11.Cursor,
    last_time: X11.struct_timespec,
    keys: [65535]u8,
    mouse_delta_x: i32,
    mouse_delta_y: i32,
    mouse_locked: bool,
    mouse_click: u8,

    pub fn isKeyPressed(self: *const Platform, keysym: c_ulong) bool {
        if (keysym >= self.keys.len) return false;
        return self.keys[@intCast(keysym)] != 0;
    }

    pub fn init() !Platform {
        std.debug.print("[PLATFORM] Initializing X11 backend...\n", .{});

        const allocator = std.heap.c_allocator;

        // Open X11 display
        const display = X11.XOpenDisplay(null) orelse return error.CannotConnectToXServer;
        const root = X11.DefaultRootWindow(display);

        // Get current time
        var last_time: X11.struct_timespec = undefined;
        _ = X11.clock_gettime(X11.CLOCK_MONOTONIC, &last_time);

        // Create invisible cursor
        const invisible_cursor = createInvisibleCursor(display, root);

        // Choose visual
        var visual_attribs = [_]c_int{
            X11.GLX_RGBA,
            X11.GLX_DEPTH_SIZE,
            24,
            X11.GLX_DOUBLEBUFFER,
            X11.None,
        };
        const visual_info = X11.glXChooseVisual(display, 0, @ptrCast(&visual_attribs)) orelse 
            return error.NoAppropriateVisual;

        // Create colormap
        const colormap = X11.XCreateColormap(display, root, visual_info.*.visual, X11.AllocNone);

        // Set window attributes
        var swa: X11.XSetWindowAttributes = undefined;
        swa.colormap = colormap;
        swa.event_mask = X11.ExposureMask | X11.StructureNotifyMask | X11.KeyPressMask | 
                         X11.KeyReleaseMask | X11.ButtonPressMask | X11.PointerMotionMask;
        swa.override_redirect = X11.False;

        // Create window
        const window = X11.XCreateWindow(
            display,
            root,
            0,
            0,
            c.WINDOW_WIDTH,
            c.WINDOW_HEIGHT,
            0,
            visual_info.*.depth,
            X11.InputOutput,
            visual_info.*.visual,
            X11.CWColormap | X11.CWEventMask,
            &swa,
        );
        
        _ = X11.XMapWindow(display, window);
        _ = X11.XStoreName(display, window, c.WINDOW_NAME);

        // Create OpenGL context (direct rendering = True/1)
        const glx_context = X11.glXCreateContext(display, visual_info, null, 1) orelse
            return error.CannotCreateGLContext;

        // Make context current
        _ = X11.glXMakeCurrent(display, window, glx_context);

        // Enable 2D texturing
        X11.glEnable(X11.GL_TEXTURE_2D);

        // Generate and bind texture
        var texture_id: X11.GLuint = 0;
        X11.glGenTextures(1, &texture_id);
        X11.glBindTexture(X11.GL_TEXTURE_2D, texture_id);

        // Set texture parameters (nearest neighbor for pixel-perfect)
        X11.glTexParameteri(X11.GL_TEXTURE_2D, X11.GL_TEXTURE_MIN_FILTER, X11.GL_NEAREST);
        X11.glTexParameteri(X11.GL_TEXTURE_2D, X11.GL_TEXTURE_MAG_FILTER, X11.GL_NEAREST);

        return Platform{
            .allocator = allocator,
            .display = display,
            .root = root,
            .window = window,
            .visual_info = visual_info,
            .colormap = colormap,
            .glx_context = glx_context,
            .texture_id = texture_id,
            .invisible_cursor = invisible_cursor,
            .last_time = last_time,
            .keys = [_]u8{0} ** 65535,
            .mouse_delta_x = 0,
            .mouse_delta_y = 0,
            .mouse_locked = false,
            .mouse_click = 0,
        };
    }

    pub fn deinit(self: *Platform) void {
        std.debug.print("[PLATFORM] Shutting down X11...\n", .{});

        _ = X11.glXMakeCurrent(self.display, X11.None, null);
        X11.glXDestroyContext(self.display, self.glx_context);
        
        if (self.texture_id != 0) {
            X11.glDeleteTextures(1, &self.texture_id);
        }
        
        if (self.invisible_cursor != X11.None) {
            _ = X11.XFreeCursor(self.display, self.invisible_cursor);
        }
        
        _ = X11.XDestroyWindow(self.display, self.window);
        _ = X11.XFreeColormap(self.display, self.colormap);
        _ = X11.XFree(self.visual_info);
        _ = X11.XCloseDisplay(self.display);
    }

    pub fn update(self: *Platform, render: *engine.Render) bool {
        // Calculate delta time
        var current_time: X11.struct_timespec = undefined;
        _ = X11.clock_gettime(X11.CLOCK_MONOTONIC, &current_time);

        const dt_sec = @as(f64, @floatFromInt(current_time.tv_sec - self.last_time.tv_sec));
        const dt_nsec = @as(f64, @floatFromInt(current_time.tv_nsec - self.last_time.tv_nsec));
        render.dt = @as(f32, @floatCast(dt_sec + dt_nsec / 1e9));

        self.last_time = current_time;

        // Cap delta time
        if (render.dt > 0.25) render.dt = 0.25;

        // Reset mouse delta
        self.mouse_delta_x = 0;
        self.mouse_delta_y = 0;

        // Process X11 events
        _ = X11.XFlush(self.display);
        
        while (X11.XPending(self.display) > 0) {
            var xev: X11.XEvent = undefined;
            _ = X11.XNextEvent(self.display, &xev);

            switch (xev.type) {
                X11.ConfigureNotify => {
                    const width = @as(usize, @intCast(xev.xconfigure.width));
                    const height = @as(usize, @intCast(xev.xconfigure.height));
                    
                    if (width != render.width or height != render.height) {
                        X11.glViewport(0, 0, @intCast(width), @intCast(height));
                        X11.glClearColor(0.0, 0.0, 0.0, 1.0);
                        X11.glClear(X11.GL_COLOR_BUFFER_BIT);
                    }
                },
                X11.KeyPress => {
                    const keysym = X11.XLookupKeysym(&xev.xkey, 0);
                    if (keysym < self.keys.len) {
                        self.keys[@intCast(keysym)] = 1;
                    }

                    // ESC unlocks mouse
                    if (keysym == X11.XK_Escape and self.mouse_locked) {
                        _ = X11.XUngrabPointer(self.display, X11.CurrentTime);
                        _ = X11.XUndefineCursor(self.display, self.window);
                        self.mouse_locked = false;
                        self.mouse_delta_x = 0;
                        self.mouse_delta_y = 0;
                    }
                },
                X11.KeyRelease => {
                    const keysym = X11.XLookupKeysym(&xev.xkey, 0);
                    if (keysym < self.keys.len) {
                        self.keys[@intCast(keysym)] = 0;
                    }
                },
                X11.ButtonPress => {
                    if (xev.xbutton.button == X11.Button1) {
                        self.mouse_click |= 0x01; // MOUSE_LEFT_CLICK

                        // Lock mouse on left click
                        if (!self.mouse_locked) {
                            const grab_status = X11.XGrabPointer(
                                self.display,
                                self.window,
                                X11.True,
                                X11.PointerMotionMask | X11.ButtonPressMask | X11.ButtonReleaseMask,
                                X11.GrabModeAsync,
                                X11.GrabModeAsync,
                                self.window,
                                self.invisible_cursor,
                                X11.CurrentTime,
                            );

                            if (grab_status == X11.GrabSuccess) {
                                self.mouse_locked = true;
                                self.mouse_click = 0;
                            }
                        }
                    }
                    
                    if (xev.xbutton.button == X11.Button3) {
                        self.mouse_click |= 0x02; // MOUSE_RIGHT_CLICK
                    }
                },
                X11.ButtonRelease => {
                    if (xev.xbutton.button == X11.Button1) {
                        self.mouse_click &= ~@as(u8, 0x01);
                    }
                    if (xev.xbutton.button == X11.Button3) {
                        self.mouse_click &= ~@as(u8, 0x02);
                    }
                },
                X11.MotionNotify => {
                    if (self.mouse_locked) {
                        const center_x: c_int = @intCast(c.WINDOW_WIDTH / 2);
                        const center_y: c_int = @intCast(c.WINDOW_HEIGHT / 2);

                        if (xev.xmotion.x != center_x or xev.xmotion.y != center_y) {
                            self.mouse_delta_x = xev.xmotion.x - center_x;
                            self.mouse_delta_y = xev.xmotion.y - center_y;
                            _ = X11.XWarpPointer(self.display, X11.None, self.window, 0, 0, 0, 0, center_x, center_y);
                        } else {
                            self.mouse_delta_x = 0;
                            self.mouse_delta_y = 0;
                        }
                    }
                },
                else => {},
            }
        }

        return true;
    }

    pub fn renderBegin(self: *Platform, render: *engine.Render) void {
        _ = self;
        _ = render;
        X11.glClearColor(0.0, 0.0, 0.0, 1.0);
        X11.glClear(X11.GL_COLOR_BUFFER_BIT);
    }

    pub fn renderEnd(self: *Platform, render: *engine.Render) void {
        // Set up orthographic projection
        X11.glMatrixMode(X11.GL_PROJECTION);
        X11.glLoadIdentity();
        X11.glOrtho(0, @floatFromInt(c.WINDOW_WIDTH), @floatFromInt(c.WINDOW_HEIGHT), 0, -1, 1);

        // Calculate aspect ratio for letterboxing/pillarboxing
        const buffer_aspect = @as(f32, @floatFromInt(c.SOFTWARE_WIDTH)) / @as(f32, @floatFromInt(c.SOFTWARE_HEIGHT));
        const window_aspect = @as(f32, @floatFromInt(c.WINDOW_WIDTH)) / @as(f32, @floatFromInt(c.WINDOW_HEIGHT));

        var quad_width: f32 = undefined;
        var quad_height: f32 = undefined;
        var offset_x: f32 = 0.0;
        var offset_y: f32 = 0.0;

        if (window_aspect > buffer_aspect) {
            // Pillarbox
            quad_height = @floatFromInt(c.WINDOW_HEIGHT);
            quad_width = quad_height * buffer_aspect;
            offset_x = (@as(f32, @floatFromInt(c.WINDOW_WIDTH)) - quad_width) / 2.0;
        } else {
            // Letterbox
            quad_width = @floatFromInt(c.WINDOW_WIDTH);
            quad_height = quad_width / buffer_aspect;
            offset_y = (@as(f32, @floatFromInt(c.WINDOW_HEIGHT)) - quad_height) / 2.0;
        }

        // Upload framebuffer to texture
        X11.glTexImage2D(
            X11.GL_TEXTURE_2D,
            0,
            X11.GL_RGBA,
            c.SOFTWARE_WIDTH,
            c.SOFTWARE_HEIGHT,
            0,
            X11.GL_RGBA,
            X11.GL_UNSIGNED_BYTE,
            render.frame_buffer.ptr,
        );

        // Draw fullscreen quad with texture
        X11.glBegin(X11.GL_QUADS);
        X11.glTexCoord2f(0.0, 0.0);
        X11.glVertex2f(offset_x, offset_y);
        X11.glTexCoord2f(1.0, 0.0);
        X11.glVertex2f(offset_x + quad_width, offset_y);
        X11.glTexCoord2f(1.0, 1.0);
        X11.glVertex2f(offset_x + quad_width, offset_y + quad_height);
        X11.glTexCoord2f(0.0, 1.0);
        X11.glVertex2f(offset_x, offset_y + quad_height);
        X11.glEnd();

        // Swap buffers
        X11.glXSwapBuffers(self.display, self.window);
    }

    fn createInvisibleCursor(display: *X11.Display, root: X11.Window) X11.Cursor {
        var black: X11.XColor = undefined;
        black.red = 0;
        black.green = 0;
        black.blue = 0;

        const no_data = [_]u8{0} ** 8;
        const bitmap = X11.XCreateBitmapFromData(display, root, &no_data, 8, 8);
        const cursor = X11.XCreatePixmapCursor(display, bitmap, bitmap, &black, &black, 0, 0);
        
        return cursor;
    }
};
