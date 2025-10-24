const std = @import("std");

const c = @cImport({
    @cInclude("inkview.h");
});

const kErrorFail: c_int = -1;

pub const AppState = struct {
    font: [*c]c.ifont = null,
    font_size: c_int = 10,

    pub fn onInit(self: *AppState) c_int {
        self.font = c.OpenFont("LiberationSans", self.font_size, 0);
        return if (self.font == null) kErrorFail else 0;
    }

    pub fn onShow(self: *AppState) void {
        c.ClearScreen();
        c.SetFont(self.font, c.BLACK);
        _ = c.DrawTextRect(0, @divTrunc(c.ScreenHeight() - self.font_size, 2), c.ScreenWidth(), self.font_size, "Hello, world!", c.ALIGN_CENTER);
        c.FullUpdate();
    }

    pub fn onKeyPress(_: *const AppState) void {
        c.CloseApp();
    }

    pub fn onExit(self: *AppState) void {
        if (self.font != null) {
            c.CloseFont(self.font);
            self.font = null;
        }
    }
};
