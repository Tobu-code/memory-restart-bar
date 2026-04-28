# MemoryRestartBar

A lightweight native macOS menu bar app for quickly restarting frequently used applications.

## Features

- Add any `.app` from your system
- Persist tracked apps across restarts (`UserDefaults`)
- Restart a single app from the menu row
- Remove a tracked app from the same row
- Restart all tracked apps sequentially
- Show status feedback for add/restart/remove/batch actions

## Requirements

- macOS 13+
- Xcode Command Line Tools / Swift toolchain

## Run Locally

```bash
swift build
swift run
```

## Build a `.app` Bundle

Use one command:

```bash
./scripts/build_app.sh
```

Output bundle: `dist/MemoryRestartBar.app`  
You can open it directly or move it to `/Applications`.

## If Signing or Launch Validation Fails

If Gatekeeper blocks launch:

```bash
xattr -dr com.apple.quarantine "dist/MemoryRestartBar.app"
spctl --assess -vv "dist/MemoryRestartBar.app"
```

Then open with Finder right-click **Open** once to trust the app locally.

## How to Use

1. Click the menu bar icon.
2. Select **Add Application...** and choose a `.app`.
3. Use row actions:
   - **Restart icon**: restart that app
   - **Trash icon**: remove that app from tracking
4. Click **Restart All** to restart all tracked apps in sequence.
5. Use **Quit** to exit.

## Status Messages

- `Added: <AppName>`: app added successfully
- `Already added: <AppName>`: duplicate app detected
- `Restarted: <AppName>`: single restart success
- `Quit timeout: <AppName>` / `Launch failed: <AppName>`: restart failure
- `Restart All done: x/y`: batch summary

## Development

```bash
swift test
```

Project conventions and contributor rules are in `AGENTS.md`.

## License

This project is released under the MIT License. See `LICENSE` for details.
