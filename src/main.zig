usingnamespace @import("raylib");
const std = @import("std");
const warn = std.debug.warn;

const grid_width: i32 = 10;
const grid_height: i32 = 20;
const grid_cell_size: i32 = 32;
const margin: i32 = 20;
const screen_width: i32 = (grid_width * grid_cell_size) + (margin * 2);
const screen_height: i32 = (grid_height * grid_cell_size) + margin;

// const Square = struct {
//     filled: bool,
// };

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
        // draw grid
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
    tick: usize = 0,

    pub fn update(self: *FallingSquare) void {
        if (self.tick == 30) {
            self.y += 1;
            self.tick = 0;
        }
        self.tick += 1;
    }
    pub fn draw(self: FallingSquare) void {
        DrawRectangle(
            @intCast(i32, self.x) * grid_cell_size + margin,
            @intCast(i32, self.y) * grid_cell_size,
            grid_cell_size, grid_cell_size, GOLD);
    }
};

// pub fn main() anyerror!void {
//     var x: usize = 1;
//     var y: c_int = -2;
//     const z = @intCast(c_int, x) + y;
//     warn("z: {} type: {}", .{z, @typeName(@TypeOf(z))});
// }

pub fn main() anyerror!void
{
    // Initialization
    //--------------------------------------------------------------------------------------

    var falling_square = FallingSquare{ .x=1, .y=0, };

    var grid = Grid.init();

    // var grid: [grid_width * grid_height]bool = undefined;

    // for (grid) |*item, i| {
    //     if (i == 32 or i == 0 or i == 10 or i == 21 or i == 199 or i == 190) {
    //         item.* = true;
    //     } else {
    //         item.* = false;
    //     }
    // }

    InitWindow(screen_width, screen_height, "Tetris");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // warn("screen_height: {}\n", .{screen_height});
    warn("grid type: {}\n", .{@typeName(@TypeOf(grid))});

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        falling_square.update();
        if (falling_square.y + 1 == grid_height or grid.get_active(falling_square.x, falling_square.y + 1)) {
            grid.set_active_state(falling_square.x, falling_square.y, true);
            falling_square.y = 0;
        }

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
