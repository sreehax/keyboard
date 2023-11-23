pub const Keycode = enum(u8) {
    NA = 0x00,
    // Letters
    A = 0x04,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
    // Numbers
    N1,
    N2,
    N3,
    N4,
    N5,
    N6,
    N7,
    N8,
    N9,
    N0,
    // Misc
    Enter,
    Esc,
    Backspace,
    Tab,
    Space,
    Minus,
    Equal,
    LeftBrace, // [ and {
    RightBrace, // ] and }
    Backslash, // \ and |
    HashTilde, // # and ~ (Non-US)
    Semicolon, // ; and :
    Apostrophe, // ' and "
    Grave, // ` and ~
    Comma, // , and <
    Dot, // . and >
    Slash, // / and ?
    CapsLock,
    // Function Keys
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    // I straight up do not care about the rest
    // If you do, then add them lol
    LCtrl = 0xE0,
    LShift,
    LAlt,
    LMeta,
    RCtrl,
    RShift,
    RAlt,
    RMeta,
    // MUST BE LAST
    Fn = 0xFF,

    pub fn modifierBit(self: Keycode) ?u8 {
        const keycode = @intFromEnum(self);
        if (keycode >= 0xE0 and keycode <= 0xE7) {
            return 1 << (keycode - 0xE0);
        }
        return null;
    }
};
