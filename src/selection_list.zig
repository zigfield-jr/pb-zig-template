const std = @import("std");

const c = @cImport({
    @cInclude("selection_list.h");
});

var cb = c.SelectionListCallbacks{
    .Draw = draw,
    .SelectedItemChanged = selected_item_changed,
    .ItemClicked = item_clicked,
    .DrawStaticElements = draw_static_elements,
    .ItemLongClicked = item_long_clicked,
    .ScrollPositionChanged = scroll_position_changed,
};
var cb_context = "Hello, world!";
var selection_list: ?*c.SelectionList = null;

fn main_handler(event_type: c_int, param_one: c_int, param_two: c_int) callconv(.c) c_int {
    switch (event_type) {
        c.EVT_INIT => {
            const screen_rect = c.irect{
                .w = c.ScreenWidth(),
                .h = c.ScreenHeight() - c.GetCaptionHeight(),
            };
            selection_list = c.SelectionList_Init(screen_rect, @ptrCast(&cb), @ptrCast(&cb_context), 100);
            _ = c.SelectionList_SetItemcount(selection_list, 20);
            _ = c.SelectionList_UseDraggableScroller(selection_list, 1);
        },
        c.EVT_SHOW => {
            _ = c.Message(1, "", "fix caption", 500);
            _ = c.SelectionList_Draw(selection_list);
            _ = c.SelectionList_Update(selection_list);
        },
        c.EVT_POINTERUP, c.EVT_POINTERDOWN, c.EVT_POINTERMOVE, c.EVT_POINTERLONG, c.EVT_POINTERHOLD, c.EVT_POINTERDRAG, c.EVT_POINTERCANCEL, c.EVT_POINTERCHANGED => {
            _ = c.SelectionList_HandleEvent(selection_list, event_type, param_one, param_two);
        },
        c.EVT_KEYPRESS => {
            c.SelectionList_Destroy(selection_list);
            c.CloseApp();
        },
        else => {},
    }

    return 0;
}

fn draw(_: ?*anyopaque, _: c_int, item_rect: c.irect, _: c_int, is_touched: c_int) callconv(.c) void {
    _ = c.FillArea(item_rect.x + 20, item_rect.y + 10, item_rect.w - 40, item_rect.h - 20, if (is_touched != 0) c.DGRAY else c.LGRAY);
}

fn selected_item_changed(_: ?*anyopaque, _: c_int) callconv(.c) void {}

fn item_clicked(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn draw_static_elements(_: ?*anyopaque, _: c.irect) callconv(.c) void {}

fn item_long_clicked(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn scroll_position_changed(_: ?*anyopaque, _: c_int, _: c_int) callconv(.c) void {}

pub fn main() !void {
    c.InkViewMain(main_handler);
}
