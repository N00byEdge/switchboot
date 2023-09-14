const std = @import("std");

pub fn build(b: *std.Build) void {
    const reset_stub = b.addSystemCommand(&.{"nasm", "src/reset_stub/reset_stub.asm", "-o"});
    const reset_stub_out_path = reset_stub.addOutputFileArg("reset_stub.bin");

    const exe = b.addExecutable(.{
        .name = "uefi_app",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/uefi_app/main.zig" },
        .target = .{
            .cpu_arch = .x86_64,
            .os_tag = .uefi,
            .cpu_model = .baseline,
        },
        .optimize = .ReleaseSmall,
    });
    exe.addAnonymousModule("reset_stub", .{
        .source_file = reset_stub_out_path,
    });
    exe.step.dependOn(&reset_stub.step);
    b.installArtifact(exe);
}
