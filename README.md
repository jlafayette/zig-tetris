# Zig Tetris

Tetris created with zig and raylib.

Thanks to Not-Nik for the raylib bindings [raylib-zig](https://github.com/Not-Nik/raylib-zig)
I used this to generate the template for this project (everything in the raylib-zig folder).

## Requires

[Zig](https://ziglang.org/)<br/>
[raylib](https://www.raylib.com/)

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

- [x] Show preview of next piece
- [ ] Display controls on the start and pause screens
- [ ] Add difficulty? maybe faster ticks, junk rows
- [x] Add score
- [ ] Add sound
- [ ] Add two player coop or competition mode?
- [ ] Add screenshot or gif to README
- [ ] Add high score
- [ ] Level up
- [x] Add timer so you can't skip past Game Over screen too quick
- [x] Freeze space input so you don't pause right away after Start screen