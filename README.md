# Scream Lite

Scream Lite is a lightweight community fork of [Cure Audio Scream](https://github.com/Cure-Audio/Scream), an open-source distortion/filter effect inspired by the classic 2010-era "Scream" sound.

The goal of this fork is deliberately narrow: **keep the sound and useful modulation workflow, remove unnecessary overhead, and make the plugin a little safer and easier to maintain.**

## Downloads

Prebuilt installers are produced by GitHub Actions:

- **macOS:** AUv2, VST3 and CLAP in one `.pkg`
- **Windows:** VST3 and CLAP in one `.exe`

The macOS community build is currently unsigned/not notarized, so macOS may require manual approval in Privacy & Security on first install.

## What changed in Lite

Compared with the upstream version, this fork:

- removes the built-in update checker and its HTTP/TLS/JSON dependencies;
- reduces the large per-instance scratch-memory reservation;
- fixes LFO modulation buffer allocation;
- hardens filter processing at low sample rates and extreme input levels;
- fixes MIDI note handling across channels and Note On with velocity 0;
- fixes stereo retrigger detection for phase-cancelled signals;
- fixes peak-meter scanning for large audio blocks;
- validates saved state/preset data before allocations and copies;
- uses separate AU/VST3/CLAP IDs so Scream Lite can coexist with upstream Scream;
- keeps standalone/debug tooling out of normal release builds;
- builds release installers automatically for macOS and Windows.

These changes are mostly about **reliability, memory use and packaging**. The core Scream DSP and modulation concept are intentionally left intact.

## Plugin formats

| Platform | Formats |
| --- | --- |
| macOS | AUv2, VST3, CLAP |
| Windows | VST3, CLAP |

## Building from source

Requirements:

- CMake
- Ninja
- Clang/clang-cl
- [sokol-shdc](https://github.com/floooh/sokol-tools)
- macOS or Windows

Clone with submodules:

```sh
git clone --recurse-submodules https://github.com/myldy20/Scream_Lite
cd Scream_Lite
```

Generate shaders and build:

### macOS

```sh
./shaders.sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

### Windows

```bat
shaders.bat
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

To build the optional standalone test application, configure with:

```
-DSCREAM_LITE_BUILD_STANDALONE=ON
```

## Building installers

With the required build tools available:

### macOS

```sh
bash installer/macos.sh
```

Output: `dist/ScreamLite_v<version>.pkg`

### Windows

```bat
installer\windows.bat
```

Output: `dist\ScreamLite_v<version>.exe`

## Credits

Scream Lite is derived from **Cure Audio Scream**, which in turn continues work from [Speechrezz/Scream-Filter](https://github.com/Speechrezz/Scream-Filter).

Original Scream project: [Cure-Audio/Scream](https://github.com/Cure-Audio/Scream)

See [LICENSE](LICENSE) for licensing terms.
