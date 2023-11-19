const std = @import("std");
const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const Stack = std.ArrayList(u8);
const Move = struct {
    from: u8,
    to: u8,
    n: usize,
};

const CrateMoverModel = enum {
    x9000,
    x9001,
};

const CrateMover = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    stacks: []Stack,
    todo: []Move,
    model: CrateMoverModel,

    fn init(allocator: std.mem.Allocator, s: []const u8, comptime model: CrateMoverModel) !Self {
        const end = std.mem.indexOfPos(u8, s, 0, "\n\n").?;

        var stacks: []Stack = undefined;
        var it = std.mem.splitBackwardsScalar(u8, s[0..end], '\n');
        if (it.next()) |header| {
            _ = header;
            const n_stacks = (end - it.index.?) / 4;
            stacks = try allocator.alloc(Stack, n_stacks);
            errdefer free(allocator, stacks);
            var i: usize = 0;
            while (i < n_stacks) {
                stacks[i] = Stack.init(allocator);
                i += 1;
            }

            while (it.next()) |line| {
                i = 0;
                while (i < n_stacks) {
                    const pos = 1 + (i * 4);
                    const char = line[pos];
                    if (char != ' ') {
                        try stacks[i].append(char);
                    }
                    i += 1;
                }
            }
        }

        var todo = std.ArrayList(Move).init(allocator);
        errdefer todo.deinit();

        var moves_it = std.mem.splitScalar(u8, s[end + 2 ..], '\n');
        while (moves_it.next()) |line| {
            if (line.len == 0) continue;
            var tokens = std.mem.tokenizeScalar(u8, line, ' ');
            _ = tokens.next(); // ignore move
            const n = try std.fmt.parseInt(usize, tokens.next().?, 10);
            _ = tokens.next(); // ignore from
            const from = try std.fmt.parseInt(u8, tokens.next().?, 10);
            _ = tokens.next(); // ignore to
            const to = try std.fmt.parseInt(u8, tokens.next().?, 10);
            try todo.append(.{ .from = from, .to = to, .n = n });
        }

        return .{
            .allocator = allocator,
            .stacks = stacks,
            .todo = try todo.toOwnedSlice(),
            .model = model,
        };
    }

    fn run(self: *Self) !void {
        // TODO: field fn(*Self) anyerror!void in the struct didn't quite work...
        return switch (self.model) {
            .x9000 => self.run9000(),
            .x9001 => self.run9001(),
        };
    }

    fn run9000(self: *Self) anyerror!void {
        for (self.todo) |*todo| {
            var src = &self.stacks[todo.from - 1];
            var dst = &self.stacks[todo.to - 1];
            try dst.ensureTotalCapacity(dst.items.len + todo.n);
            while (todo.n > 0) {
                try dst.append(src.popOrNull().?);
                todo.n -= 1;
            }
        }
    }

    fn run9001(self: *Self) anyerror!void {
        for (self.todo) |*todo| {
            var src = &self.stacks[todo.from - 1];
            var dst = &self.stacks[todo.to - 1];
            const idx = src.items.len - todo.n;
            const items = src.items[idx..];
            try dst.appendSlice(items);
            src.shrinkRetainingCapacity(idx);
            todo.n = 0;
        }
    }

    fn cratesOnTop(self: *Self) ![]u8 {
        var crates_on_top = try self.allocator.alloc(u8, self.stacks.len);
        errdefer self.allocator.free(crates_on_top);
        for (self.stacks, 0..) |*stack, i| {
            crates_on_top[i] = stack.items[stack.items.len - 1];
        }
        return crates_on_top;
    }

    fn deinit(self: *Self) void {
        free(self.allocator, self.stacks);
        self.allocator.free(self.todo);
    }

    fn free(allocator: std.mem.Allocator, stacks: []Stack) void {
        defer allocator.free(stacks);
        for (stacks) |*stack| {
            stack.deinit();
        }
    }
};

test "Example - part 1" {
    var allocator = std.testing.allocator;
    var crateMover = try CrateMover.init(allocator, example, .x9000);
    defer crateMover.deinit();
    try crateMover.run();
    const answer = try crateMover.cratesOnTop();
    defer allocator.free(answer);
    try std.testing.expect(std.mem.eql(u8, "CMZ", answer));
}

test "Input - part 1" {
    var allocator = std.testing.allocator;
    var crateMover = try CrateMover.init(allocator, input, .x9000);
    defer crateMover.deinit();
    try crateMover.run();
    const answer = try crateMover.cratesOnTop();
    defer allocator.free(answer);
    try std.testing.expect(std.mem.eql(u8, "GRTSWNJHH", answer));
}

test "Example - part 2" {
    var allocator = std.testing.allocator;
    var crateMover = try CrateMover.init(allocator, example, .x9001);
    defer crateMover.deinit();
    try crateMover.run();
    const answer = try crateMover.cratesOnTop();
    defer allocator.free(answer);
    try std.testing.expect(std.mem.eql(u8, "MCD", answer));
}

test "Input - part 2" {
    var allocator = std.testing.allocator;
    var crateMover = try CrateMover.init(allocator, input, .x9001);
    defer crateMover.deinit();
    try crateMover.run();
    const answer = try crateMover.cratesOnTop();
    defer allocator.free(answer);
    try std.testing.expect(std.mem.eql(u8, "QLFQDBBHM", answer));
}
