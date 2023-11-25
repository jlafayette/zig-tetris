# Zig Tetris

Tetris created with zig and raylib.

Thanks to Not-Nik for the raylib bindings [raylib-zig](https://github.com/Not-Nik/raylib-zig)
I used this to generate the template for this project (everything in the raylib-zig folder,
the build.zig, and build.zig.zon file).

## Requires

[Zig](https://ziglang.org/) 0.11.0<br/>
[raylib](https://www.raylib.com/) 4.6

## Setup and Build

- `git submodule init`
- `git submodule update`
- `zig build run`

## TODO

- [ ] Reset difficulty when starting a new game
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
