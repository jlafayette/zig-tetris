usingnamespace @import("raylib");
const std = @import("std");
const warn = std.debug.warn;

const grid_width: i32 = 10;
const grid_height: i32 = 20;
const grid_cell_size: i32 = 32;
const margin: i32 = 20;
const screen_width: i32 = (grid_width * grid_cell_size) + (margin * 2);
const screen_height: i32 = (grid_height * grid_cell_size) + margin;


const Grid = struct {
    grid: [grid_width * grid_height]bool,

    pub fn init() Grid {
        var grid: [grid_width * grid_height]bool = undefined;
        for (grid) |*item, i| {
            item.* = false;
        }
        return Grid{ .grid=grid };
    }

    pub fn get_active(self: Grid, x: i32, y: i32) bool {
        if (x < 0) { return true; }
        if (y < 0) { return false; }
        const index: usize = @intCast(usize, y) * @intCast(usize, grid_width) + @intCast(usize, x);
        if (index >= self.grid.len) {
            return true;
        }
        return self.grid[index];
    }

    pub fn set_active_state(self: *Grid, x: i32, y: i32, state: bool) void {
        if (x < 0 or y < 0) {
            return;
        }
        const index: usize = @intCast(usize, y) * @intCast(usize, grid_width) + @intCast(usize, x);
        if (index >= self.grid.len) {
            return;
        }
        self.grid[index] = state;
    }

    pub fn draw(self: Grid) void {
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
    }
};


const Pos = struct {
    x: i32,
    y: i32,
};

const Type = enum {
    Cube,
    Long,
};
const Rotation = enum {
    A, B, C, D
};

const Piece = struct {
    x: i32,
    y: i32,
    squares: [4]Pos,
    t: Type,
    r: Rotation,

    pub fn init(t: Type) Piece {
        return Piece{
            .x=4,
            .y=0,
            .squares=Piece.get_squares(t, Rotation.A),
            .t=t,
            .r=Rotation.A,
        };
    }

    pub fn get_squares(t: Type, r: Rotation) [4]Pos {
        return switch (t) {
            Type.Cube => [_]Pos{
                    Pos{ .x=0, .y=0 }, Pos{ .x=1, .y=0 },
                    Pos{ .x=0, .y=1 }, Pos{ .x=1, .y=1 }
                },
            Type.Long => switch (r) {
                Rotation.A, Rotation.C => [_]Pos{
                    Pos{ .x=-1, .y=0 }, Pos{ .x=0, .y=0 }, Pos{ .x=1, .y=0 }, Pos{ .x=2, .y=0 }
                },
                Rotation.B, Rotation.D => [_]Pos{
                    Pos{ .x=0, .y=-1 },
                    Pos{ .x=0, .y=0 },
                    Pos{ .x=0, .y=1 },
                    Pos{ .x=0, .y=2 }
                },
            },
        };
    }

    pub fn rotate(self: *Piece, grid: *Grid) void {
        const r = switch (self.r) {
            Rotation.A => Rotation.B,
            Rotation.B => Rotation.C,
            Rotation.C => Rotation.D,
            Rotation.D => Rotation.A,
        };
        const squares = Piece.get_squares(self.t, r);
        if (self.check_collision(squares, grid)) {
            return;
        } else {
            self.squares = squares;
            self.r = r;
        }
    }

    pub fn check_collision(self: *Piece, squares: [4]Pos, grid: *Grid) bool {
        for (squares) |pos| {
            const x = self.x + pos.x;
            const y = self.y + pos.y;
            if ((x >= grid_width) or (x < 0) or (y >= grid_height) or grid.get_active(x, y)) {
                return true;
            }
        }
        return false;
    }

    pub fn update(self: *Piece) void {
        self.y += 1;
    }
    pub fn draw(self: Piece) void {
        for (self.squares) |pos| {
            DrawRectangle(
                (self.x + pos.x) * grid_cell_size + margin,
                (self.y + pos.y) * grid_cell_size,
                grid_cell_size, grid_cell_size, GOLD);
        }
    }
    pub fn move_right(self: *Piece, grid: *Grid) void {
        const can_move = blk: {
            for (self.squares) |pos| {
                const x = self.x + pos.x + 1;
                const y = self.y + pos.y;
                if ((x >= grid_width) or grid.get_active(x, y)) {
                    break :blk false;
                }
            }
            break :blk true;
        };
        if (can_move) {
            self.x += 1;
        }
    }
    pub fn move_left(self: *Piece, grid: *Grid) void {
        const can_move = blk: {
            for (self.squares) |pos| {
                const x = self.x + pos.x - 1;
                const y = self.y + pos.y;
                if ((x < 0) or grid.get_active(x, y)) {
                    break :blk false;
                }
            }
            break :blk true;
        };
        if (can_move) {
            self.x -= 1;
        }
    }
    pub fn move_down(self: *Piece, grid: *Grid) void {

        const can_move = blk: {
            for (self.squares) |pos| {
                const x = self.x + pos.x;
                const y = self.y + pos.y + 1;
                if ((y >= grid_height) or grid.get_active(x, y)) {
                    break :blk false;
                }
            }
            break :blk true;
        };
        if (can_move) {
            self.y += 1;
        } else {
            for (self.squares) |pos| {
                 grid.set_active_state(self.x + pos.x, self.y + pos.y, true);
            }
            self.reset();
        }
    }
    pub fn reset(self: *Piece) void {
        self.y = 0;
        self.x = 4;
        self.t = switch (self.t) {
            Type.Cube => Type.Long,
            Type.Long => Type.Cube,
        };
        self.r = Rotation.A;
        self.squares = Piece.get_squares(self.t, self.r);
    }
};


pub fn main() anyerror!void
{
    // Initialization
    //--------------------------------------------------------------------------------------

    var piece = Piece.init(Type.Cube);
    var grid = Grid.init();
    var tick: usize = 0;

    InitWindow(screen_width, screen_height, "Tetris");
    defer CloseWindow();

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
            piece.move_right(&grid);
        }
        if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
            piece.move_left(&grid);
        }
        if (IsKeyDown(KeyboardKey.KEY_DOWN)) {
            piece.move_down(&grid);
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP)) {
            piece.rotate(&grid);
        }

        if (tick == 30) {
            piece.move_down(&grid);
            tick = 0;
        }
        tick += 1;

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(LIGHTGRAY);

            // // draw border
            // DrawRectangle(0, 0, margin, screen_height, LIGHTGRAY);  // left
            // DrawRectangle(screen_width - margin, 0, margin, screen_height, LIGHTGRAY); // right
            // DrawRectangle(margin, screen_height - margin, screen_width - (margin * 2), margin, LIGHTGRAY); // bottom

            grid.draw();
            piece.draw();

        EndDrawing();
        //----------------------------------------------------------------------------------
    }
}
