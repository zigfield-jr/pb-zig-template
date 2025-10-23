const std = @import("std");

const c = @cImport({
    @cInclude("scrollview.h");
});

var content_handler = c.ScrollView_Content{
    .Draw = draw,
    .ProcessEvent = process_event,
    .DrawStaticElements = draw_static_elements,
};
var content_context = "Hello, world!";
var scroll_view: ?*c.ScrollView = null;

fn main_handler(event_type: c_int, param_one: c_int, param_two: c_int) callconv(.c) c_int {
    switch (event_type) {
        c.EVT_INIT => {
            const screen_rect = c.irect{
                .w = c.ScreenWidth(),
                .h = c.ScreenHeight() - c.GetCaptionHeight(),
            };
            scroll_view = c.ScrollView_Init(screen_rect, @ptrCast(&content_handler), @ptrCast(&content_context), c.SCROLL_VIEW_FLAG_DRAW_HORIZONTAL_SCROLLER);
            _ = c.ScrollView_SetContentSize(scroll_view, c.ScreenWidth() * 2, (c.ScreenHeight() - c.GetCaptionHeight()) * 2);
            _ = c.ScrollView_SetViewport(scroll_view, @divTrunc(c.ScreenWidth(), 2), @divTrunc(c.ScreenHeight() - c.GetCaptionHeight(), 2));
        },
        c.EVT_SHOW => {
            _ = c.Message(1, "", "fix caption", 500);
            _ = c.ScrollView_Draw(scroll_view);
            _ = c.ScrollView_Update(scroll_view);
        },
        c.EVT_POINTERUP, c.EVT_POINTERDOWN, c.EVT_POINTERMOVE, c.EVT_POINTERLONG, c.EVT_POINTERHOLD, c.EVT_POINTERDRAG, c.EVT_POINTERCANCEL, c.EVT_POINTERCHANGED => {
            _ = c.ScrollView_HandleEvent(scroll_view, event_type, param_one, param_two);
        },
        c.EVT_KEYPRESS => {
            c.ScrollView_Destroy(scroll_view);
            c.CloseApp();
        },
        else => {},
    }

    return 0;
}

fn draw(_: ?*anyopaque, content_rect: c.irect, to_x: c_int, to_y: c_int) callconv(.c) void {
    const x = to_x - content_rect.x - 100 + c.ScreenWidth();
    const y = to_y - content_rect.y - 100 + c.ScreenHeight() - c.GetCaptionHeight();
    c.FillArea(x, y, 200, 200, c.LGRAY);
}

fn process_event(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn draw_static_elements(_: ?*anyopaque, _: c.irect) callconv(.c) void {}

pub fn main() !void {
    c.InkViewMain(main_handler);
}
