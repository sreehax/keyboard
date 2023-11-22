const std = @import("std");
const K = @import("scancodes.zig").Keys;

// These would be the columns of the keyboard matrix
pub const outputs = .{
    7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
};

// These would be the rows of the keyboard matrix
pub const inputs = .{
    2, 3, 4, 5, 6,
};

// The default keyboard layout
pub const default_layout = .{
    .{ K.Esc, K.N1, K.N2, K.N3, K.N4, K.N5, K.N6, K.N7, K.N8, K.N9, K.N0, K.LBrace, K.RBrace, K.Backslash, K.NA },
    .{ K.Tab, K.Apostrophe, K.Comma, K.Dot, K.P, K.Y, K.F, K.G, K.C, K.R, K.L, K.Slash, K.Equal, K.Backspace, K.NA },
    .{ K.LCtrl, K.A, K.O, K.E, K.U, K.I, K.D, K.H, K.T, K.N, K.S, K.Minus, K.Enter, K.NA, K.NA },
    .{ K.LShift, K.Semicolon, K.Q, K.J, K.K, K.X, K.B, K.M, K.W, K.V, K.Z, K.RShift, K.Fn, K.NA, K.NA },
    .{ K.LAlt, K.LMeta, K.NA, K.NA, K.NA, K.Space, K.NA, K.NA, K.NA, K.RMeta, K.RAlt, K.NA, K.NA, K.NA, K.NA },
};
