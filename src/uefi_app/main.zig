const std = @import("std");

const reset_stub = @embedFile("reset_stub");

fn fake_exit_boot_services() std.os.uefi.Status {
    while(true) {}
}

fn on_suspend() noreturn {
    while(true) {}
}

pub fn main() std.os.uefi.Status {
    const blob: *[reset_stub.len]u8 = @ptrFromInt(0x1000);
    asm volatile(
        \\rep movsb
        :
        : [_] "{rsi}" (reset_stub.ptr)
        , [_] "{rcx}" (reset_stub.len)
        , [_] "{rdi}" (blob)
        : "rsi", "rcx", "rdi"
    );
    asm volatile(
        \\sgdt 0x80(%[reg])
        \\sidt 0x86(%[reg])
        :
        : [reg] "r" (blob)
    );
    const cr3 = asm(
        \\mov %%cr3, %[reg]
        : [reg] "=r" (-> u64)
    );
    // we hope cr3 fits in 32 bits...
    std.mem.writeIntLittle(u32, blob[0x8C..][0..4], @as(u32, @truncate(cr3)));
    std.mem.writeIntLittle(u64, blob[0x90..][0..8], @intFromPtr(&on_suspend));
    const cs = asm(
        \\mov %%cs, %[reg]
        : [reg] "=r" (-> u16)
    );
    std.mem.writeIntLittle(u16, blob[0x92..][0..2], cs);
    return .Success;
}
