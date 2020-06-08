usingnamespace @import("raylib");
const std = @import("std");
const warn = std.debug.warn;
const panic = std.debug.panic;

const grid_width: i32 = 10;
const grid_height: i32 = 20;
const grid_cell_size: i32 = 32;
const margin: i32 = 20;
const screen_width: i32 = (grid_width * grid_cell_size) + (margin * 2);
const screen_height: i32 = (grid_height * grid_cell_size) + margin;

const State = enum {
    StartScreen,
    Play,
    Pause,
    GameOver,
};

const Pos = struct {
    x: i32,
    y: i32,
};

fn p(x: i32, y: i32) Pos {
    return Pos{ .x=x, .y=y };
}

const Type = enum {
    Cube,
    Long,
    Z,
    S,
    T,
    L,
    J,
};
const Rotation = enum {
    A, B, C, D
};

const GameOver = error {
    NoRoom,
};

const Game = struct {
    grid: [grid_width * grid_height]bool,
    squares: [4]Pos,
    rng: std.rand.DefaultPrng,
    state: State,
    t: Type,
    r: Rotation,
    tick: i32,
    freeze_down: i32,
    x: i32,
    y: i32,
    gameover: bool,

    pub fn init() Game {
        // grid
        var grid: [grid_width * grid_height]bool = undefined;
        for (grid) |*item, i| {
            item.* = false;
        }
        // rng
        var buf: [8]u8 = undefined;
        std.crypto.randomBytes(buf[0..]) catch |err| {
            panic("unable to seed random number generator: {}", .{err});
        };
        const seed = std.mem.readIntLittle(u64, buf[0..8]);
        var r = std.rand.DefaultPrng.init(seed);      
        // squares
        const t = Type.Cube;
        var squares = Game.get_squares(t, Rotation.A);
        return Game{
            .grid=grid,
            .squares=squares,
            .rng=r,
            .state=State.StartScreen,
            .t=t,
            .r=Rotation.A,
            .tick=0,
            .freeze_down=0,
            .x=4,
            .y=0,
            .gameover=false,
        };
    }
    pub fn update(self: *Game) void {
        if (self.gameover) {
            self.reset();
            self.piece_reset() catch |err| {};
            self.tick = 0;
            self.gameover = false;
            self.state = State.GameOver;
        }
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
            self.move_right();
        }
        if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
            self.move_left();
        }
        if (IsKeyDown(KeyboardKey.KEY_DOWN)) {
            if (self.freeze_down <= 0) {
                if (self.move_down()) |moved| {
                    if (!moved) {
                        self.freeze_down = 60;
                    }
                } else |err| {
                    self.gameover = true;
                }
            }
        }
        if (IsKeyReleased(KeyboardKey.KEY_DOWN)) {
            self.freeze_down = 0;
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP)) {
            self.rotate();
        }
        if (self.tick == 30) {
            if (self.move_down()) |moved| {} else |err| switch (err) {
                error.NoRoom => { self.gameover = true; },
            }
            self.remove_full_rows();
            self.tick = 0;
        }
        self.tick += 1;
        if (self.freeze_down > 0) {
            self.freeze_down -= 1;
        }
    }
    fn row_is_full(self: Game, y: i32) bool {
        if (y >= self.grid.len or y < 0) {
            warn("Row index out of bounds {}", .{y});
            return false;
        }
        var x: i32 = 0;
        return while (x < grid_width) : (x += 1) {
            if (!self.get_active(x, y)) {
                break false;
            }
        } else true;
    }
    fn copy_row(self: *Game, y1: i32, y2: i32) void {
        if (y1 == y2) {
            warn("Invalid copy, {} must not equal {}\n", .{y1, y2});
            return;
        }
        if (y2 < 0 or y1 >= grid_height or y2 >= grid_height) {
            warn("Invalid copy, {} or {} is out of bounds\n", .{y1, y2});
            return;
        }
        var x: i32 = 0;
        while (x < grid_width) : (x += 1) {
            if (y1 < 0) {
                self.set_active_state(x, y2, false);
            } else {
                self.set_active_state(x, y2, self.get_active(x, y1));
            }
        }
    }
    fn copy_rows(self: *Game, src_y: i32, dst_y: i32) void {
        // Starting at dest row, copy everything above, but starting at dest
        if (src_y >= dst_y) {
            warn("{} must be less than {}\n", .{src_y, dst_y});
            return;
        }
        var y1: i32 = src_y;
        var y2: i32 = dst_y;
        while (y2 > -1) {
            self.copy_row(y1, y2);
            y1 -= 1;
            y2 -= 1;
        }
    }
    pub fn remove_full_rows(self: *Game) void {
        // Remove full rows
        var y: i32 = grid_height - 1;
        var cp_y: i32 = y;
        while (y > -1) {
            if (self.row_is_full(y)) {
                while (self.row_is_full(cp_y)) {
                    cp_y -= 1;
                }
                self.copy_rows(cp_y, y);
                cp_y = y;
            }
            y -= 1;
            cp_y -= 1;
        }
    }
    pub fn get_active(self: Game, x: i32, y: i32) bool {
        if (x < 0) { return true; }
        if (y < 0) { return false; }
        const index: usize = @intCast(usize, y) * @intCast(usize, grid_width) + @intCast(usize, x);
        if (index >= self.grid.len) {
            return true;
        }
        return self.grid[index];
    }
    pub fn set_active_state(self: *Game, x: i32, y: i32, state: bool) void {
        if (x < 0 or y < 0) {
            return;
        }
        const index: usize = @intCast(usize, y) * @intCast(usize, grid_width) + @intCast(usize, x);
        if (index >= self.grid.len) {
            return;
        }
        self.grid[index] = state;
    }
    pub fn reset(self: *Game) void {
        for (self.grid) |*item, i| {
            item.* = false;
        }
    }
    pub fn piece_reset(self: *Game) !void {
        self.y = 0;
        self.x = 4;
        const index = self.rng.random.uintLessThanBiased(@TagType(Type), @typeInfo(Type).Enum.fields.len);
        self.t = @intToEnum(Type, index);
        self.r = Rotation.A;
        self.squares = Game.get_squares(self.t, self.r);
        if (self.check_collision(self.squares)) {
            return error.NoRoom;
        }
    }
    pub fn draw(self: *Game) void {
        var y: i32 = 0;
        var upper_left_y: i32 = 0;
        while (y < grid_height) {
            var x: i32 = 0;
            var upper_left_x: i32 = margin;
            while (x < grid_width) {

                if (self.get_active(x, y)) {
                    DrawRectangle(upper_left_x, upper_left_y, grid_cell_size, grid_cell_size, DARKGRAY);
                } else {
                    DrawRectangle(upper_left_x, upper_left_y, grid_cell_size, grid_cell_size, LIGHTGRAY);
                    DrawRectangle(upper_left_x + 1, upper_left_y + 1, grid_cell_size - 2, grid_cell_size - 2, WHITE);
                }

                upper_left_x += grid_cell_size; 
                x += 1;
            }
            upper_left_y += grid_cell_size;
            y += 1;
        }

        // Draw falling piece and ghost
        const ghost_square_offset = self.get_ghost_square_offset();
        for (self.squares) |pos| {
            // Draw ghost
            DrawRectangle(
                (self.x + pos.x) * grid_cell_size + margin,
                (self.y + ghost_square_offset + pos.y) * grid_cell_size,
                grid_cell_size, grid_cell_size, LIGHTGRAY);
            // Draw shape
            DrawRectangle(
                (self.x + pos.x) * grid_cell_size + margin,
                (self.y + pos.y) * grid_cell_size,
                grid_cell_size, grid_cell_size, GOLD);
        }
    }
    pub fn get_squares(t: Type, r: Rotation) [4]Pos {
        return switch (t) {
            Type.Cube => [_]Pos{
                    p(0, 0), p(1, 0),
                    p(0, 1), p(1, 1)
                },
            Type.Long => switch (r) {
                Rotation.A, Rotation.C => [_]Pos{
                    p(-1, 0), p(0, 0), p(1, 0), p(2, 0)
                },
                Rotation.B, Rotation.D => [_]Pos{
                    p(0,-1),
                    p(0, 0),
                    p(0, 1),
                    p(0, 2)
                },
            },
            Type.Z => switch (r) {
                Rotation.A, Rotation.C => [_]Pos{
                    p(-1, 0), p(0, 0),
                              p(0, 1), p(1, 1)
                },
                Rotation.B, Rotation.D => [_]Pos{
                              p(0, -1),
                    p(-1, 0), p(0,  0),
                    p(-1, 1)
                },
            },
            Type.S => switch (r) {
                Rotation.A, Rotation.C => [_]Pos{
                              p(0, 0), p(1, 0),
                    p(-1, 1), p(0, 1)
                },
                Rotation.B, Rotation.D => [_]Pos{
                    p(0,-1),
                    p(0, 0), p(1, 0),
                             p(1, 1)
                },
            },
            Type.T => switch (r) {
                Rotation.A, => [_]Pos{
                              p(0,-1), 
                    p(-1, 0), p(0, 0), p(1, 0),
                },
                Rotation.B => [_]Pos{
                    p(0,-1),
                    p(0, 0), p(1, 0),
                    p(0, 1)
                },
                Rotation.C, => [_]Pos{
                    p(-1, 0), p(0, 0), p(1, 0),
                              p(0, 1), 
                },
                Rotation.D => [_]Pos{
                              p(0,-1),
                    p(-1, 0), p(0, 0),
                              p(0, 1)
                },
            },
            Type.L => switch (r) {
                Rotation.A => [_]Pos{
                    p(0,-1),
                    p(0, 0),
                    p(0, 1), p(1, 1),
                },
                Rotation.B => [_]Pos{
                    p(-1, 0), p(0, 0), p(1, 0),
                    p(-1, 1),
                },
                Rotation.C => [_]Pos{
                    p(-1,-1), p(0,-1),
                              p(0, 0),
                              p(0, 1),
                },
                Rotation.D => [_]Pos{
                                       p(1,-1),
                    p(-1, 0), p(0, 0), p(1, 0),
                },
            },
            Type.J => switch (r) {
                Rotation.A => [_]Pos{
                              p(0,-1),
                              p(0, 0),
                    p(-1, 1), p(0, 1),
                },
                Rotation.B => [_]Pos{
                    p(-1,-1),
                    p(-1, 0), p(0, 0), p(1, 0),
                },
                Rotation.C => [_]Pos{
                    p(0,-1), p(1,-1),
                    p(0, 0),
                    p(0, 1),
                },
                Rotation.D => [_]Pos{
                    p(-1, 0), p(0, 0), p(1, 0),
                                       p(1, 1)
                },
            },
        };
    }
    pub fn get_ghost_square_offset(self: *Game) i32 {
        var offset: i32 = 0;
        while (true) {
            if (self.check_collision_offset(0, offset, self.squares)) {
                break;
            }
            offset += 1;
        }
        return offset - 1;
    }
    pub fn rotate(self: *Game) void {
        const r = switch (self.r) {
            Rotation.A => Rotation.B,
            Rotation.B => Rotation.C,
            Rotation.C => Rotation.D,
            Rotation.D => Rotation.A,
        };
        const squares = Game.get_squares(self.t, r);
        if (self.check_collision(squares)) {
            // Try moving left or right by one or two squares. This helps when trying
            // to rotate when right next to the wall or another block. Esp noticable
            // on the 4x1 (Long) type.
            const x_offsets = [_]i32 { 1, -1, 2, -2 };
            for (x_offsets) |x_offset| {
                if (!self.check_collision_offset(x_offset, 0, squares)) {
                    self.x += x_offset;
                    self.squares = squares;
                    self.r = r;
                    return;
                }
            }
        } else {
            self.squares = squares;
            self.r = r;
        }
    }
    pub fn check_collision(self: *Game, squares: [4]Pos) bool {
        for (squares) |pos| {
            const x = self.x + pos.x;
            const y = self.y + pos.y;
            if ((x >= grid_width) or (x < 0) or (y >= grid_height) or self.get_active(x, y)) {
                return true;
            }
        }
        return false;
    }
    fn check_collision_offset(self: *Game, offset_x: i32, offset_y: i32, squares: [4]Pos) bool {
        for (squares) |pos| {
            const x = self.x + pos.x + offset_x;
            const y = self.y + pos.y + offset_y;
            if ((x >= grid_width) or (x < 0) or (y >= grid_height) or self.get_active(x, y)) {
                return true;
            }
        }
        return false;
    }
    pub fn move_right(self: *Game) void {
        const can_move = blk: {
            for (self.squares) |pos| {
                const x = self.x + pos.x + 1;
                const y = self.y + pos.y;
                if ((x >= grid_width) or self.get_active(x, y)) {
                    break :blk false;
                }
            }
            break :blk true;
        };
        if (can_move) {
            self.x += 1;
        }
    }
    pub fn move_left(self: *Game) void {
        const can_move = blk: {
            for (self.squares) |pos| {
                const x = self.x + pos.x - 1;
                const y = self.y + pos.y;
                if ((x < 0) or self.get_active(x, y)) {
                    break :blk false;
                }
            }
            break :blk true;
        };
        if (can_move) {
            self.x -= 1;
        }
    }
    pub fn move_down(self: *Game) !bool {
        const can_move = blk: {
            for (self.squares) |pos| {
                const x = self.x + pos.x;
                const y = self.y + pos.y + 1;
                if ((y >= grid_height) or self.get_active(x, y)) {
                    break :blk false;
                }
            }
            break :blk true;
        };
        if (can_move) {
            self.y += 1;
            return true;
        } else {
            for (self.squares) |pos| {
                 self.set_active_state(self.x + pos.x, self.y + pos.y, true);
            }
            try self.piece_reset();
            return false;
        }
    }
};

pub fn main() anyerror!void
{
    // Initialization
    var game = Game.init();
    InitWindow(screen_width, screen_height, "Tetris");
    defer CloseWindow();

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        game.update();

        BeginDrawing();

            ClearBackground(LIGHTGRAY);
            game.draw();

        EndDrawing();
    }
}
