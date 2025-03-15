const options = @import("options");
const c = @cImport({
    if (options.use_double_precision) @cDefine("JPH_DOUBLE_PRECISION", "");
    if (options.enable_asserts) @cDefine("JPH_ENABLE_ASSERTS", "");
    if (options.enable_cross_platform_determinism) @cDefine("JPH_CROSS_PLATFORM_DETERMINISTIC", "");
    if (options.enable_debug_renderer) @cDefine("JPH_DEBUG_RENDERER", "");
    @cInclude("joltc.h");
});

pub extern fn JPH_Init() c_int;
pub extern fn JPH_Shutdown() void;

pub fn init() bool {
    return c.JPH_Init();
}

pub fn shutdown() void {
    return c.JPH_Shutdown();
}
