# Lepton-Inspired Improvements for Liquid Fox

**Date:** 2026-03-22
**Status:** Approved

## Overview

Seven improvements to Liquid Fox inspired by the Firefox-UI-Fix (Lepton) project. All CSS changes stay in the single raw `userChrome.css` file, structured for future SCSS migration.

## 1. `@layer tokens-foundation` Override

**Problem:** Firefox 145+ introduces `--border-radius-medium` (8px default) in a `tokens-foundation` CSS layer that overrides theme rounding.

**Solution:** Place a `@layer tokens-foundation` block after the internal variables section:

```css
@layer tokens-foundation {
  :root, :host(.anonymous-content-host) {
    --border-radius-medium: var(--liquid-radius-small) !important;
  }
}
```

**Location:** After the "Internal Variables" section, before the "Pill-shaped URL bar" section.

## 2. Audio Tab Resize Fix

**Problem:** Firefox 136+ dynamically resizes tabs when the sound/muted icon appears, causing width jumping in horizontal tabs.

**Solution:** Add to the horizontal tabs section:

```css
.tabbrowser-tab:is([soundplaying], [muted], [activemedia-blocked]):not([pinned]) {
  --tab-min-width: inherit !important;
}
```

**Location:** Inside the horizontal tabs `:root:not(...)` block, after the pinned tab gap rule. Scoped to horizontal only since vertical tabs use full-width rows and don't have this issue.

## 3. Pref-Gating Infrastructure

**Mechanism:** Firefox's `-moz-bool-pref` media query reads boolean `about:config` prefs at runtime. CSS wraps optional features in `@media (-moz-bool-pref: "prefName") { ... }`.

**Prefs (all default false — opt-in):**

| Pref | Feature |
|------|---------|
| `liquidFox.autohide.bookmarkbar` | Autohide bookmarks toolbar |
| `liquidFox.tab.close_button_at_hover` | Show close button only on hover |

**CSS structure:** A new `/* Optional Features (pref-gated) */` section placed after the "Find bar" section, before "Scrollbar". Each feature wrapped in its own `@media (-moz-bool-pref: "...")` block.

**install.sh changes:** Add `user_pref()` calls for each pref with `false` default, using the existing `add_pref` function. Update the post-install message to inform users about available opt-in features.

**Limitation:** Changing a pref in `about:config` requires a Firefox restart to take effect (stylesheet is loaded once at startup).

## 4. Autohide Bookmarks Bar

**Pref:** `liquidFox.autohide.bookmarkbar`

**Behavior:**
- Bookmarks bar collapses: `max-height: 0; overflow: hidden; opacity: 0; padding-block: 0; margin: 0`
- Hovering `#navigator-toolbox` reveals it: `max-height: 40px; opacity: 1; padding-block: 1px` (40px accommodates all density settings)
- Transition on `max-height` and `opacity` using `--liquid-transition-speed` with `ease-in-out`
- Respects `prefers-reduced-motion` via existing global collapse
- Note: `max-height` transitions can be slightly jittery vs grid-based collapse, but grid isn't feasible in Firefox chrome context. Acceptable tradeoff.

**Scope:** Scoped inside the horizontal tabs `:root:not(...):not(:has(sidebar-main #tabbrowser-tabs))` block. Bookmarks bar is part of `#navigator-toolbox` in both layouts but autohide only makes sense in horizontal mode.

## 5. Tab Close Button on Hover Only

**Pref:** `liquidFox.tab.close_button_at_hover`

**Behavior:**
- Default state: `.tab-close-button` hidden with `opacity: 0; pointer-events: none`
- On `.tabbrowser-tab:hover` or `[selected]`/`[multiselected]`: `opacity: 1; pointer-events: auto`
- Smooth opacity transition
- Applies to both horizontal and vertical tab layouts

## 6. `userChrome-overrides.css` Support

**install.sh changes:**
- After copying `userChrome.css`, check if `$TARGET/chrome/userChrome-overrides.css` exists
- If it exists, append `@import url("userChrome-overrides.css");` to the end of the installed `userChrome.css` (if not already present, checked via `grep -qF`)
- Print a message noting the overrides file was preserved
- Do NOT create or overwrite the overrides file — it's user-managed

**Note on `@import` placement:** Per CSS spec, `@import` must appear before other rules. However, Firefox's chrome stylesheet loader processes `@import` at end-of-file — this is a known pattern used by Lepton and other userChrome projects. Relies on Firefox-specific behavior.

## 7. DOM Stability Comments

Add inline comments to fragile selectors noting the Firefox element and approximate version introduced. Format: `/* Firefox NNN+: description */`

**Target selectors:**
- `sidebar-main` — Firefox 130+ sidebar custom element
- `tab-group` — Firefox 131+ tab grouping element
- `tab-split-view-wrapper` — Firefox 131+ split view wrapper
- `#sidebar-main[sidebar-launcher-expanded]` — Firefox 131+ expand-on-hover attribute
- `.urlbar-searchmode-switcher` — Firefox 131+ search mode UI
- `#tabbrowser-tabpanels[splitview]` — Firefox 131+ split view attribute

## File Changes

| File | Changes |
|------|---------|
| `chrome/userChrome.css` | Add tokens-foundation layer, audio fix, pref-gated features section, DOM comments |
| `install.sh` | Add pref writes, add overrides.css import logic |

## Future Work (Deferred)

- GitHub Pages config page with sliders/toggles that exports `user.js` + `userChrome-overrides.css`
- SCSS build pipeline if file grows past ~1200 lines
- Additional pref-gated features (floating findbar, autohide navbar, etc.)
