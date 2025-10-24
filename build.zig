const std = @import("std");
const Step = std.Build.Step;

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "hello_world.app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/hello_world.zig"),
            // .root_source_file = b.path("src/hello_world_two.zig"),
            // .root_source_file = b.path("src/scroll_view.zig"),
            // .root_source_file = b.path("src/selection_list.zig"),
            .target = b.resolveTargetQuery(.{
                .cpu_arch = .arm,
                .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_a7 },
                .os_tag = .linux,
                .abi = .gnueabi,
                .glibc_version = .{ .major = 2, .minor = 23, .patch = 0 },
            }),
        }),
    });

    exe.addIncludePath(b.path("sdk/include"));
    exe.addIncludePath(b.path("sdk/include/freetype2"));
    exe.addIncludePath(b.path("sdk/local/include"));
    exe.addLibraryPath(b.path("sdk/local/lib"));
    exe.linkSystemLibrary("hwconfig");
    exe.linkSystemLibrary("inkview");
    exe.linkLibC();

    const applications_dir: std.Build.InstallDir = .{ .custom = "applications" };

    const install_artifact = b.addInstallArtifact(exe, .{
        .dest_dir = .{
            .override = applications_dir,
        },
    });

    install_artifact.step.dependOn(&b.addInstallFileWithDir(b.path("netcat.sh"), applications_dir, "netcat.app").step);
    install_artifact.step.dependOn(&b.addInstallFileWithDir(b.path("gdbserver.sh"), applications_dir, "gdbserver.app").step);
    install_artifact.step.dependOn(&b.addInstallFileWithDir(b.path("SDK.pdf"), .prefix, "PocketBook SDK Documentation.pdf").step);

    const dest_ip = b.option([]const u8, "dest_ip", "device ip") orelse "";
    if (std.mem.eql(u8, "", dest_ip)) {
        b.getInstallStep().dependOn(&install_artifact.step);
    } else {
        const send_tar = SendTar.create(b, dest_ip, 10003);
        send_tar.step.dependOn(&install_artifact.step);
        b.getInstallStep().dependOn(&send_tar.step);
    }
}

const SendTar = struct {
    pub const base_id: Step.Id = .custom;

    step: Step,
    dest_ip: []const u8,
    dest_port: u16,

    pub fn create(owner: *std.Build, dest_ip: []const u8, dest_port: u16) *SendTar {
        const send_tar = owner.allocator.create(SendTar) catch @panic("OOM");

        send_tar.* = .{
            .step = Step.init(.{
                .id = base_id,
                .name = owner.fmt("send tarball to {s}:{d}", .{ dest_ip, dest_port }),
                .owner = owner,
                .makeFn = make,
            }),
            .dest_ip = owner.dupe(dest_ip),
            .dest_port = dest_port,
        };

        return send_tar;
    }

    fn make(step: *Step, options: Step.MakeOptions) !void {
        _ = options; // No progress to report.
        const b = step.owner;
        const send_tar: *SendTar = @fieldParentPtr("step", step);

        var tcp_stream = try std.net.tcpConnectToAddress(try std.net.Address.parseIp(send_tar.dest_ip, send_tar.dest_port));
        defer tcp_stream.close();
        var tcp_buffer: [1024]u8 = undefined;
        var tcp_writer = tcp_stream.writer(&tcp_buffer);

        var gzip_buffer: [std.compress.flate.max_window_len]u8 = undefined;
        var gzip_compress: std.compress.flate.Compress = try .init(&tcp_writer.interface, &gzip_buffer, .gzip, .default);
        const gzip_writer = &gzip_compress.writer;

        var tar_writer: std.tar.Writer = .{ .underlying_writer = gzip_writer };

        var install_dir = try std.fs.cwd().openDir(b.getInstallPath(.prefix, ""), .{ .iterate = true });
        defer install_dir.close();

        var install_walker = try install_dir.walk(b.allocator);
        defer install_walker.deinit();

        while (try install_walker.next()) |install_entry| {
            switch (install_entry.kind) {
                .file => {
                    const file = try install_entry.dir.openFile(install_entry.basename, .{ .mode = .read_only });
                    defer file.close();
                    var file_buffer: [1024]u8 = undefined;
                    var file_reader = file.reader(&file_buffer);

                    try tar_writer.writeFile(install_entry.path, &file_reader, std.time.nanoTimestamp());
                },
                else => {},
            }
        }

        try tar_writer.finishPedantically();
        try gzip_writer.flush();
        try tcp_writer.interface.flush();
    }
};
