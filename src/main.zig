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
            if (i == 52 or i == 0 or i == 10 or i == 51 or i == 199 or i == 190) {
                item.* = true;
            } else {
                item.* = false;
            }
        }
        return Grid{ .grid=grid };
    }

    pub fn get_active(self: Grid, x: usize, y: usize) bool {
        const index: usize = y * @intCast(usize, grid_width) + x;
        return self.grid[index];
    }

    pub fn set_active_state(self: *Grid, x: usize, y: usize, state: bool) void {
        const index: usize = y * @intCast(usize, grid_width) + x;
        self.grid[index] = state;
    }

    pub fn draw(self: Grid) void {
        var y: usize = 0;
        var upper_left_y: i32 = 0;
        while (y < grid_height) {
            var x: usize = 0;
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


const FallingSquare = struct {
    x: usize,
    y: usize,

    pub fn update(self: *FallingSquare) void {
        self.y += 1;
    }
    pub fn draw(self: FallingSquare) void {
        DrawRectangle(
            @intCast(i32, self.x) * grid_cell_size + margin,
            @intCast(i32, self.y) * grid_cell_size,
            grid_cell_size, grid_cell_size, GOLD);
    }
    pub fn move_right(self: *FallingSquare, grid: *Grid) void {
        // todo detect collision in grid
        warn("move right!\n", .{});
        if (self.x < grid_width - 1) {
            self.x += 1;
            if (grid.get_active(self.x, self.y)) {
                self.x -= 1;
            }
        }
    }
    pub fn move_left(self: *FallingSquare, grid: *Grid) void {
        warn("move left!\n", .{});
        if (self.x > 0) {
            self.x -= 1;
            if (grid.get_active(self.x, self.y)) {
                self.x += 1;
            }
        }
    }
    pub fn move_down(self: *FallingSquare, grid: *Grid) void {
        if (self.y + 1 == grid_height or grid.get_active(self.x, self.y + 1)) {
            grid.set_active_state(self.x, self.y, true);
            self.reset();
        } else {
            self.y += 1;
        }
    }
    pub fn reset(self: *FallingSquare) void {
        self.y = 0;
    }
};


pub fn main() anyerror!void
{
    // Initialization
    //--------------------------------------------------------------------------------------

    var falling_square = FallingSquare{ .x=1, .y=0, };
    var grid = Grid.init();
    var tick: usize = 0;

    InitWindow(screen_width, screen_height, "Tetris");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
            falling_square.move_right(&grid);
        }
        if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
            falling_square.move_left(&grid);
        }
        if (IsKeyDown(KeyboardKey.KEY_DOWN)) {
            falling_square.move_down(&grid);
        }

        if (tick == 30) {
            falling_square.move_down(&grid);
            tick = 0;
        }
        tick += 1;

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(WHITE);

            // draw border
            DrawRectangle(0, 0, margin, screen_height, LIGHTGRAY);  // left
            DrawRectangle(screen_width - margin, 0, margin, screen_height, LIGHTGRAY); // right
            DrawRectangle(margin, screen_height - margin, screen_width - (margin * 2), margin, LIGHTGRAY); // bottom

            grid.draw();
            falling_square.draw();

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
