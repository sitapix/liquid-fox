# Liquid Fox

A transparent Firefox theme for macOS with vibrancy blur, rounded panels, and a subtle gradient tint. Supports both vertical and horizontal tab layouts.

## Requirements

- macOS
- Firefox 130+

## Install

### Quick (script)

```bash
./install.sh
```

The script lets you pick a Firefox profile and copies `chrome/userChrome.css` into it.

### Manual

1. Open `about:profiles` in Firefox and find your active profile directory
2. Create a `chrome/` folder inside it (if it doesn't exist)
3. Copy `chrome/userChrome.css` into that folder

### Enable in about:config

Open `about:config` in Firefox and set both of these to `true`:

```
toolkit.legacyUserProfileCustomizations.stylesheets
widget.macos.titlebar-blend-mode.behind-window
```

Then restart Firefox.

## Features

- macOS vibrancy/blur behind the entire browser chrome
- Subtle gradient tint overlay
- Rounded content panels with soft shadows and gradient outlines
- Dia-inspired tab group styling (vertical and horizontal)
- Collapsed sidebar overrides for vertical tabs
- Sidebar icon strip styling with background for horizontal tabs
- Dark mode adjustments (stronger group tints, brighter backdrop)
