# Zig Tetris

Tetris created with zig and raylib. This is a project to play around with zig and learn the language.

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
- Add DLL files to build.zig:<br/>`exe.addLibPath("C:\\raylib\\raylib\\projects\\VS2017\\bin\\x64\\Release.DLL");`
- `zig build run`

Seems like there should be a better way...

## TODO

- [x] Add README
- [ ] Add LICENSE
- [ ] Make repo public
- [ ] Give each piece has a color
- [ ] Desaturate colors when they are added to the grid
- [ ] Make ghost a desaturated tint of current piece color
- [ ] Display controls on the start and pause screens
- [ ] Add difficulty? maybe faster ticks, junk rows
- [ ] Add score
- [ ] Add sound
- [ ] Add two player coop or competition mode?
- [ ] Add screenshot or gif to README
