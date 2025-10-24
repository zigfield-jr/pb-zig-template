const std = @import("std");
const app_state = @import("app_state.zig");

const c = @cImport({
    @cInclude("inkview.h");
});

const kFontSize: c_int = 40;

var state: app_state.AppState = .{ .font_size = kFontSize };

fn main_handler(event_type: c_int, _: c_int, _: c_int) callconv(.c) c_int {
    var rv: c_int = 0;

    switch (event_type) {
        c.EVT_INIT => {
            rv = state.onInit();
        },
        c.EVT_SHOW => {
            state.onShow();
        },
        c.EVT_KEYPRESS => {
            state.onKeyPress();
        },
        c.EVT_EXIT => {
            state.onExit();
        },
        else => {},
    }

    return rv;
}

pub fn main() !void {
    c.InkViewMain(main_handler);
}
