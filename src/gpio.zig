const std = @import("std");
const microzig = @import("microzig");
const config = @import("config.zig");
const usb = @import("usb.zig");
const rp2040 = microzig.hal;
const gpio = rp2040.gpio;
const SIO = microzig.chip.peripherals.SIO;

const led = gpio.num(25);
const uart = rp2040.uart.num(0);
const baud_rate = 115200;
const uart_tx_pin = gpio.num(0);
const uart_rx_pin = gpio.num(1);

pub fn led_init() void {
    led.set_function(.sio);
    led.set_direction(.out);
    led.put(1);
}

pub fn uart_init() void {
    uart.apply(.{
        .baud_rate = baud_rate,
        .tx_pin = uart_tx_pin,
        .rx_pin = uart_rx_pin,
        .clock_config = rp2040.clock_config,
    });

    rp2040.uart.init_logger(uart);
}

pub fn pins_init() void {
    inline for (config.outputs) |n| {
        const curr = gpio.num(n);
        curr.set_function(.sio);
        curr.set_direction(.out);
        curr.put(1);
    }

    // Set up all the inputs with the internal pull-up resistor
    inline for (config.inputs) |n| {
        const curr = gpio.num(n);
        curr.set_function(.sio);
        curr.set_direction(.in);
        curr.set_pull(.up);
    }
}

fn hold_up() void {
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        asm volatile ("nop");
    }
}

pub fn scan_matrix() void {
    var gpio_dump: u32 = undefined;
    inline for (config.outputs, 0..) |output_pin, i| {
        const output = gpio.num(output_pin);
        // Set the pin to LOW
        output.put(0);

        hold_up();

        // get all the GPIO state in one go, then mask out what we want
        gpio_dump = SIO.GPIO_IN.raw;

        inline for (config.inputs, 0..) |input_pin, j| {
            // if the pin is LOW, then we got the row and column matched
            // inputs are rows, outputs are columns
            if ((1 << input_pin) & gpio_dump == 0) {
                const key = config.default_layout[j][i];

                usb.add_key_to_report(key);
            }
        }
        // Set the pin back to HIGH
        output.put(1);

        // Now that we added all the pressed keys to the report, dispatch it.
    }
}
