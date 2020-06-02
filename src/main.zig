usingnamespace @import("raylib");

pub fn main() anyerror!void
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 650;
    const screenHeight = 800;

    InitWindow(screenWidth, screenHeight, "Tetris");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(WHITE);

            // draw border
            DrawRectangle(0, 0, 25, screenHeight, LIGHTGRAY);  // left
            DrawRectangle(screenWidth-25, 0, 25, screenHeight, LIGHTGRAY); // right
            DrawRectangle(25, screenHeight-25, screenWidth-50, 25, LIGHTGRAY); // bottom

            var i: i32 = 0;
            var left: i32 = 25;
            const increment = (screenWidth-50) / 10;
            while (i < 10) {
                i += 1;
                DrawRectangle(left, screenHeight/2, 5, 10, DARKGRAY);
                left += increment;
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
