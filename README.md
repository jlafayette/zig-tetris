# Zig Tetris

Tetris created with zig and raylib.

Thanks to Not-Nik for the raylib bindings [raylib-zig](https://github.com/Not-Nik/raylib-zig)
I used this to generate the template for this project (everything in the raylib-zig folder).

## Requires

[Zig](https://ziglang.org/) 0.8.0<br/>
[raylib](https://www.raylib.com/) 3.0

## Setup and Build

### MacOS

- Install raylib: `brew install raylib`
- Then it just works: `zig build run`

### Windows

- Download raylib installer
- Navigate to `C:\raylib\raylib\projects\VS2017` and build the solution in Visual Studio Code
- Currently this build directory is hardcoded in build.zig:<br/>`C:/raylib/raylib/projects/VS2017/bin/x64/Release.DLL`
- `zig build run`

I'm probably doing this wrong...

## TODO

- [ ] Level up
- [ ] (Difficulty) faster ticks
- [ ] Display current level
- [x] Combo score for multiple rows
- [ ] Flash combo scores / multipliers
- [ ] (Difficulty) junk rows
- [ ] Display controls on the start and pause screens
- [ ] Add sound
- [ ] Add high score
- [ ] Add screenshot or gif to README
- [ ] (Difficulty) Slowly reduce likelyhood of pieces that are helpful
- [ ] Throw in large shapes! (with countdown til arrival)
- [ ] Add two player coop or competition mode
- [ ] Add AI oppenent
- [ ] Online play
