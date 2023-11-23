const std = @import("std");
const microzig = @import("microzig");
const rp2040 = microzig.hal;
const Keycode = @import("scancodes.zig").Keycode;
const usb = rp2040.usb;

fn ep1_in_callback(dc: *usb.DeviceConfiguration, data: []const u8) void {
    _ = data;
    usb.Usb.callbacks.usb_start_rx(
        dc.endpoints[2], // EP1_OUT_CFG,
        64,
    );
}

fn ep1_out_callback(dc: *usb.DeviceConfiguration, data: []const u8) void {
    usb.Usb.callbacks.usb_start_tx(dc.endpoints[3], // EP1_IN_CFG,
        data);
}

pub var EP1_OUT_CFG: usb.EndpointConfiguration = .{
    .descriptor = &usb.EndpointDescriptor{
        .length = 7,
        .descriptor_type = usb.DescType.Endpoint,
        .endpoint_address = usb.Dir.Out.endpoint(1),
        .attributes = @intFromEnum(usb.TransferType.Interrupt),
        .max_packet_size = 64,
        .interval = 100,
    },
    .endpoint_control_index = 2,
    .buffer_control_index = 3,
    .data_buffer_index = 2,
    .next_pid_1 = false,
    .callback = ep1_out_callback,
};

pub var EP1_IN_CFG: usb.EndpointConfiguration = .{
    .descriptor = &usb.EndpointDescriptor{
        .length = 7,
        .descriptor_type = usb.DescType.Endpoint,
        .endpoint_address = usb.Dir.In.endpoint(1),
        .attributes = @intFromEnum(usb.TransferType.Interrupt),
        .max_packet_size = 64,
        .interval = 100,
    },
    .endpoint_control_index = 1,
    .buffer_control_index = 2,
    .data_buffer_index = 3,
    .next_pid_1 = false,
    .callback = ep1_in_callback,
};

pub var DEVICE_CONFIGURATION: usb.DeviceConfiguration = .{
    .device_descriptor = &.{
        .length = 18,
        .descriptor_type = usb.DescType.Device,
        .bcd_usb = 0x0110, // USB 1.1
        .device_class = 0x03, // HID
        .device_subclass = 0x01, // BOOT protocol
        .device_protocol = 0x01, // KEYBOARD
        .max_packet_size0 = 64, // EP0 Max Packet Size
        .vendor = 0xCAFE,
        .product = 0xBABE,
        .bcd_device = 0x0100,
        .manufacturer_s = 1,
        .product_s = 2,
        .serial_s = 3,
        .num_configurations = 1,
    },
    .interface_descriptor = &.{
        .length = 9,
        .descriptor_type = usb.DescType.Interface,
        .interface_number = 0, // TODO: Figure this shit out??
        .alternate_setting = 0,
        .num_endpoints = 2,
        .interface_class = 0x03, // HID
        .interface_subclass = 0x01, // BOOT protocol
        .interface_protocol = 0x01, // KEYBOARD
        .interface_s = 0,
    },
    .config_descriptor = &.{
        .length = 9,
        .descriptor_type = usb.DescType.Config,
        .total_length = 9 + 9 + 7 + 7 + 9,
        .num_interfaces = 1,
        .configuration_value = 1,
        .configuration_s = 0,
        .attributes = 0xC0, // SELF_POWER
        .max_power = 0x32,
    },
    .lang_descriptor = "\x04\x03\x09\x04",
    .descriptor_strings = &.{
        &usb.utf8ToUtf16Le("Raspberry Pi"),
        &usb.utf8ToUtf16Le("Sreehari's USB Keyboard"),
        &usb.utf8ToUtf16Le("cafebabe"),
    },
    .hid = .{
        .hid_descriptor = &.{
            .bcd_hid = 0x0111,
            .country_code = 0,
            .num_descriptors = 1,
            .report_length = @sizeOf(@TypeOf(MyReportDescriptor)),
        },
        .report_descriptor = &MyReportDescriptor,
    },
    .endpoints = .{
        &usb.EP0_OUT_CFG,
        &usb.EP0_IN_CFG,
        &EP1_OUT_CFG,
        &EP1_IN_CFG,
    },
};

pub fn init() void {
    // Initialize the USB clock
    usb.Usb.init_clk();

    // Initialize the USB device with our configuration settings
    usb.Usb.init_device(&DEVICE_CONFIGURATION) catch unreachable;
}

pub fn add_key_to_report(key: Keycode) void {
    std.log.info("Key pressed: {s}", .{@tagName(key)});
}

// This is a hybrid report descriptor with support for both legacy 6KRO and infinite NKRO
// This is achieved by marking the traditional 6KRO space as padding and filling in the
// NKRO info right after. This means compliant hosts will see the NKRO info while BIOSes
// that only support 6KRO will ignore the descriptor and only see the 6KRO info.
// Thus, both cases are fully satisfied, even if the BIOS doesn't say it only supports 6KRO.
// Adapted from https://emergent.unpythonic.net/01626210345
pub const TOTAL_BYTES = 24;
pub const MyReportDescriptor = [_]u8{
    0x05, 0x01, // Usage Page (Generic Desktop),
    0x09, 0x06, // Usage (Keyboard),
    0xA1, 0x01, // Collection (Application),
    0x85, 0x01, //   Report ID (1)
    // Modifiers (Used for both the boot specification and NKRO)
    0x75, 0x01, //   Report Size (1),
    0x95, 0x08, //   Report Count (8),
    0x05, 0x07, //   Usage Page (Key Codes),
    0x19, 0xE0, //   Usage Minimum (224),
    0x29, 0xE7, //   Usage Maximum (231),
    0x15, 0x00, //   Logical Minimum (0),
    0x25, 0x01, //   Logical Maximum (1),
    0x81, 0x02, //   Input (Data, Variable, Absolute)
    // LED output report
    0x95, 0x05, //   Report Count (5)
    0x75, 0x01, //   Report Size (1),
    0x05, 0x08, //   Usage Page (LEDs),
    0x19, 0x01, //   Usage Minimum (1),
    0x29, 0x05, //   Usage Maximum (5),
    0x91, 0x02, //   Output (Data, Variable, Absolute),
    0x95, 0x01, //   Report Count (1),
    0x75, 0x03, //   Report Size (3),
    0x91, 0x03, //   Output (Constant),
    // Padding / fake boot keyboard
    0x95, 0x38, //   Report Count (56),
    0x75, 0x01, //   Report Size (1),
    0x81, 0x01, //   Input (Bruh),
    // rest of the keys
    0x95, (TOTAL_BYTES - 8) * 8, //   Report Count (),
    0x75, 0x01, //   Report Size (1),
    0x15, 0x00, //   Logical Minimum (0),
    0x25, 0x01, //   Logical Maximum (1),
    0x05, 0x07, //   Usage Page (Key Codes),
    0x19, 0x00, //   Usage Minimum (0),
    0x29, (TOTAL_BYTES - 8) * 8 - 1, //   Usage Maximum (),
    0x81, 0x02, //   Input (Data, Variable, Absolute),
    0xC0, //       End Collection
};
