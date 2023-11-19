const std = @import("std");
const rp2040 = @import("rp2040");

pub fn build(b: *std.Build) void {
    const microzig = @import("microzig").init(b, "microzig");
    const optimize = b.standardOptimizeOption(.{});

    const firmware = microzig.addFirmware(b, .{ .name = "keyboard", .target = rp2040.boards.raspberry_pi.pico, .optimize = optimize, .source_file = .{ .path = "src/main.zig" } });

    microzig.installFirmware(b, firmware, .{});

    microzig.installFirmware(b, firmware, .{ .format = .elf });
}
