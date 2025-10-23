const std = @import("std");

const c = @cImport({
    @cInclude("inkview.h");
});

const kFontSize: c_int = 40;

fn main_handler(event_type: c_int, _: c_int, _: c_int) callconv(.c) c_int {
    switch (event_type) {
        c.EVT_INIT => {
            const font = c.OpenFont("LiberationSans", kFontSize, 0);
            c.ClearScreen();
            c.SetFont(font, c.BLACK);
            _ = c.DrawTextRect(0, @divTrunc(c.ScreenHeight() - kFontSize, 2), c.ScreenWidth(), kFontSize, "Hello, world!", c.ALIGN_CENTER);
            c.FullUpdate();
            c.CloseFont(font);
        },
        c.EVT_KEYPRESS => {
            c.CloseApp();
        },
        else => {},
    }

    return 0;
}

pub fn main() !void {
    c.InkViewMain(main_handler);
}
