const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_joltc = try buildLibJoltc(b, .{
        .target = target,
        .optimize = optimize,
        .shared = false,
        .no_exceptions = true,
    });

    const mod_test_joltc = b.addModule("test-joltc", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/test.zig"),
    });

    mod_test_joltc.linkLibrary(lib_joltc);

    const mod_tests = b.addTest(.{
        .root_module = mod_test_joltc,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}

pub fn buildLibJoltc(
    b: *std.Build,
    options: struct {
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
        shared: bool = false,
        no_exceptions: bool = true,
    },
) !*std.Build.Step.Compile {
    const joltc_dep = b.dependency("joltc", .{});
    const jph_dep = b.dependency("jolt_physics", .{});

    const lib_joltc = b.addLibrary(
        .{
            .name = "joltc",
            .linkage = if (options.shared) .dynamic else .static,
            .root_module = b.createModule(
                .{
                    .target = options.target,
                    .optimize = options.optimize,
                    .link_libc = true,
                    .link_libcpp = true,
                },
            ),
        },
    );

    if (options.shared and options.target.result.os.tag == .windows) {
        lib_joltc.root_module.addCMacro("JPH_API", "extern __declspec(dllexport)");
    }
    b.installArtifact(lib_joltc);
    lib_joltc.installHeader(joltc_dep.path("include/joltc.h"), "joltc.h");

    lib_joltc.root_module.addIncludePath(joltc_dep.path("include"));
    lib_joltc.root_module.addIncludePath(jph_dep.path(""));
    if (options.target.result.abi != .msvc) {
        lib_joltc.root_module.link_libc = true;
    } else {
        lib_joltc.root_module.linkSystemLibrary("advapi32", .{});
    }

    const c_flags = &.{
        "-std=c++17",
        if (options.no_exceptions) "-fno-exceptions" else "",
        "-fno-access-control",
        "-fno-sanitize=undefined",
    };

    lib_joltc.root_module.addCSourceFiles(.{
        .root = joltc_dep.path("src"),
        .files = &.{
            "joltc.cpp",
        },
        .flags = c_flags,
    });

    const allocator = b.allocator;
    var cpp_files = try std.ArrayList([]const u8).initCapacity(allocator, 0);
    defer cpp_files.deinit(allocator);

    const jolt_path = jph_dep.path("Jolt");
    const jolt_root = try jolt_path.getPath3(b, null).toString(allocator);
    try collectCppFiles(b.graph.io, allocator, jolt_root, &cpp_files);

    var rel_files = try std.ArrayList([]const u8).initCapacity(allocator, cpp_files.items.len);
    defer rel_files.deinit(allocator);

    const environ_map = b.graph.environ_map;
    for (cpp_files.items) |abs_path| {
        const rel_path = try std.Io.Dir.path.relative(
            allocator,
            jolt_root,
            &environ_map,
            jolt_root,
            abs_path,
        );
        try rel_files.append(allocator, rel_path);
    }

    lib_joltc.root_module.addCSourceFiles(.{
        .root = jph_dep.path("Jolt"),
        .files = rel_files.items,
        .flags = c_flags,
    });

    return lib_joltc;
}

fn collectCppFiles(
    io: std.Io,
    allocator: std.mem.Allocator,
    dir_path: []const u8,
    files: *std.ArrayList([]const u8),
) !void {
    var dir = try std.Io.Dir.openDirAbsolute(io, dir_path, .{ .iterate = true });
    defer dir.close(io);

    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        const full_path = try std.fs.path.join(allocator, &.{ dir_path, entry.name });
        switch (entry.kind) {
            .file => {
                if (std.mem.endsWith(u8, entry.name, ".cpp")) {
                    try files.append(allocator, full_path);
                }
            },
            .directory => try collectCppFiles(io, allocator, full_path, files),
            else => {},
        }
    }
}
