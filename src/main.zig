const std = @import("std");
const microzig = @import("microzig");
const usb = @import("usb.zig");
const gpio = @import("gpio.zig");
const rp2040 = microzig.hal;
const time = rp2040.time;

pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    std.log.err("panic: {s}", .{message});
    @breakpoint();
    while (true) {}
}

pub const std_options = struct {
    pub const log_level = .debug;
    pub const logFn = rp2040.uart.log;
};

pub fn main() !void {
    // set up the LED lit up
    gpio.led_init();

    // enable the UART
    gpio.uart_init();

    // set up the inputs and outputs
    gpio.pins_init();

    // Set up all the outputs as HIGH
    gpio.pins_init();

    // Initialize the USB interface
    usb.init();

    while (true) {
        // Do the actual polling
        // would be perfect to move to the other core...
        rp2040.usb.Usb.task(
            false,
        ) catch unreachable;

        // Actually scan the keyboard matrix
        // This function will also add any pressed keys to the report,
        // so we have nothing else to do except keep calling the function.
        gpio.scan_matrix();
    }
}
