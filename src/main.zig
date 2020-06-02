usingnamespace @import("raylib");
const std = @import("std");
const warn = std.debug.warn;


const screenWidth = 650;
const screenHeight = 800;
const cellSide = (screenWidth -50) / 10;
const numberRows = (screenHeight -25) / cellSide;
const bottom = screenHeight -25 -cellSide;

const Square = struct {
    filled: bool,
};

const FallingSquare = struct {
    posY: c_int,
    column: u8,
    done: bool,

    pub fn update(self: *FallingSquare) void {
        if (self.done) {
            return;
        }
        self.posY += 2;
        if (self.posY >= bottom) {
            self.posY = bottom;
            self.done = true;
        }
    }

    pub fn draw(self: FallingSquare) void {
        const left: c_int = 25 + (cellSide*self.column);
        DrawRectangle(left, self.posY, cellSide, cellSide, DARKGRAY);
    }
};

pub fn main() anyerror!void
{
    // Initialization
    //--------------------------------------------------------------------------------------
    

    var squaresMatrix:  [numberRows][10]*Square = undefined;
    for (squaresMatrix) |*row| {
        for (row.*) |*item| {
            var c = Square{ .filled=false, };
            item.* = &c;
        }
    }

    var falling_square = FallingSquare{ .posY=0, .column=1, .done=false, };

    InitWindow(screenWidth, screenHeight, "Tetris");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    warn("screenHeight: {}\n", .{screenHeight});
    
    warn("numberRows: {}\n", .{numberRows});

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        falling_square.update();

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(WHITE);

            // draw border
            DrawRectangle(0, 0, 25, screenHeight, LIGHTGRAY);  // left
            DrawRectangle(screenWidth-25, 0, 25, screenHeight, LIGHTGRAY); // right
            DrawRectangle(25, screenHeight-25, screenWidth-50, 25, LIGHTGRAY); // bottom
           
            // draw grid
            var x: c_int = 0;
            var y: c_int = 0;
            for (squaresMatrix) |row| {
                x = 0;
                for (row) |item| {
                    if (item.filled == true) {
                        const left: c_int = 25 + (cellSide*x);
                        const top: c_int = (screenHeight-25-cellSide) - (cellSide*y);
                        DrawRectangle(left, top, cellSide, cellSide, DARKGRAY);
                    } else {
                        const left: c_int = 25 + (cellSide*x);
                        const top: c_int = (screenHeight-25-cellSide) - (cellSide*y);
                        DrawRectangle(left, top, cellSide, cellSide, LIGHTGRAY);
                        DrawRectangle(left+1, top+1, cellSide-2, cellSide-2, WHITE);
                    }
                    x += 1;
                }
                y += 1;
            }

            // draw falling
            falling_square.draw();

            // var i: i32 = 0;
            // var left: i32 = 25;
            // const increment = (screenWidth-50) / 10;
            // while (i < 10) {
            //     i += 1;
            //     DrawRectangle(left, screenHeight/2, 5, 10, DARKGRAY);
            //     left += increment;
            // }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
