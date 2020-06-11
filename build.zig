const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("Tetris", "src/main.zig");
    exe.setBuildMode(mode);

    // TODO: Make this path an argument that can be passed into build command
    if (exe.target.isWindows()) {
        exe.addLibPath("C:/raylib/raylib/projects/VS2017/bin/x64/Release.DLL");
        const raylib_dll = "C:/raylib/raylib/projects/VS2017/bin/x64/Release.DLL/raylib.dll";
        b.installFile(raylib_dll, "bin/raylib.dll");
    }

    exe.linkSystemLibrary("raylib");
    exe.addPackagePath("raylib", "raylib-zig/raylib-zig.zig");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
