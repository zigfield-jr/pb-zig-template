const std = @import("std");
const AppState = @import("app_state.zig").AppState;

const c = @cImport({
    @cInclude("inkview.h");
});

const kFontSize: c_int = 40;

var app_state: AppState = .{ .font_size = kFontSize };

fn main_handler(event_type: c_int, _: c_int, _: c_int) callconv(.c) c_int {
    var rv: c_int = 0;

    switch (event_type) {
        c.EVT_INIT => {
            rv = app_state.onInit();
        },
        c.EVT_SHOW => {
            app_state.onShow();
        },
        c.EVT_KEYPRESS => {
            app_state.onKeyPress();
        },
        c.EVT_EXIT => {
            app_state.onExit();
        },
        else => {},
    }

    return rv;
}

pub fn main() !void {
    c.InkViewMain(main_handler);
}
