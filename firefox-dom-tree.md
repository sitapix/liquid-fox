# Firefox DOM Element Tree Reference

## Window Structure

```
:root (html element)
  appearance: -moz-sidebar → activates macOS vibrancy
  ::before → used for window gradient tint overlay

body
  ├── #navigator-toolbox
  │   ├── #titlebar (when tabsintitlebar)
  │   │   └── #TabsToolbar (horizontal tab bar, or collapsed in vertical mode)
  │   │       └── #tabbrowser-tabs (contains tabs in horizontal mode)
  │   │           └── #tabbrowser-arrowscrollbox (scrollable tab container)
  │   │               ├── .tabbrowser-tab (individual tabs)
  │   │               ├── tab-group (tab group containers)
  │   │               └── #tabs-newtab-button
  │   ├── #nav-bar (address bar + navigation buttons)
  │   │   ├── #urlbar-container
  │   │   │   └── #urlbar → .urlbar-background
  │   │   ├── back/forward/reload buttons
  │   │   └── extension icons, menu button
  │   └── #PersonalToolbar (bookmarks bar, optional)
  │
  ├── #browser
  │   └── #browser-panel
  │       ├── #sidebar-main (Lit web component, shadow DOM)
  │       │   └── (internal: moz-button elements for sidebar icons)
  │       ├── #sidebar-box (sidebar panels when open)
  │       │   └── .sidebar-browser-stack
  │       │       └── #sidebar (<browser> element - replaced, no pseudo-elements)
  │       └── #appcontent
  │           └── #tabbrowser-tabbox
  │               └── #tabbrowser-tabpanels
  │                   └── .browserContainer (web content frame)
  │                       └── <browser> (actual web page)
  │
  └── (other: findbar, notification boxes, etc.)
```

### Key Notes - Window
- `#navigator-toolbox` has a `border-bottom` separator (--chrome-content-separator-color)
- All intermediate elements (body, #browser, #appcontent, etc.) need `background: transparent` for vibrancy
- `#sidebar-main` is a Lit web component - CSS custom properties pierce shadow DOM
- `.browserContainer::after` and `.sidebar-browser-stack::after` used for gradient outline
- `#sidebar` is a `<browser>` replaced element - cannot have ::after pseudo-elements

## Vertical Tabs (sidebar-main #tabbrowser-tabs)

Detection: `:root:has(sidebar-main #tabbrowser-tabs)`

In vertical mode, `#tabbrowser-tabs` moves from `#TabsToolbar` into `sidebar-main`.

```
sidebar-main (Lit component, shadow DOM)
  └── #tabbrowser-tabs[orient="vertical"]
      ├── #pinned-tabs-container[orient="vertical"] (arrowscrollbox)
      │   └── .tabbrowser-tab[pinned] (grid layout, rows sized by --tab-height-with-margin-padding)
      │       └── (same .tab-stack > .tab-background structure)
      ├── #vertical-pinned-tabs-splitter (drag-to-resize between pinned and regular tabs)
      └── #tabbrowser-arrowscrollbox
          ├── .tabbrowser-tab
          │   └── .tab-stack
          │       └── .tab-background
          │           ├── (tab content: icon, label, close button)
          │           └── .tab-group-line (absolutely positioned, hidden in groups)
          │
          ├── tab-group (custom element, default: display: contents)
          │   ├── .tab-group-label-container
          │   │   └── .tab-group-label-hover-highlight
          │   │       └── .tab-group-label (role="button")
          │   ├── <slot/> (tabs inserted here)
          │   │   └── .tabbrowser-tab (same structure as above)
          │   ├── .tab-group-line (group indicator)
          │   └── .tab-group-overflow-count-container
          │       └── .tab-group-overflow-count ("+1", "+2" label)
          │
          └── #tabs-newtab-button
```

### Key Notes - Vertical Tabs
- `tab-group` uses `display: contents` by default → must override to `display: flex; flex-direction: column` to render as visible box
- Expanded groups indent children with `margin-inline-start: var(--space-medium)`
- `--tab-border-radius` controls tab corner rounding
- `.tab-background:is([selected], [multiselected])` for selected tab styling
- Sidebar button styling uses CSS custom properties that pierce shadow DOM:
  - `--button-background-color-hover`, `--button-background-color-active`
  - `--button-background-color-ghost-hover`, `--button-background-color-ghost-active`
  - `--toolbarbutton-active-background`, `--button-border-radius`

## Horizontal Tabs (#TabsToolbar)

Detection: `:root:not(:has(sidebar-main #tabbrowser-tabs))`

```
#TabsToolbar
  └── #tabbrowser-tabs[orient="horizontal"]
      └── #tabbrowser-arrowscrollbox
          ├── .tabbrowser-tab
          │   └── .tab-stack
          │       └── .tab-background
          │           ├── (favicon, label, close button)
          │           └── .tab-group-line (colored line at bottom, position: absolute)
          │
          ├── tab-group (custom element, default: display: contents)
          │   ├── .tab-group-label-container
          │   │   └── .tab-group-label-hover-highlight
          │   │       └── .tab-group-label
          │   ├── <slot/> → .tabbrowser-tab children
          │   ├── .tab-group-line (NOT a direct child - lives inside each tab's .tab-background)
          │   └── .tab-group-overflow-count-container
          │       └── .tab-group-overflow-count ("+1", "+2")
          │
          └── #tabs-newtab-button
```

### Key Notes - Horizontal Tabs
- `tab-group` uses `display: contents` by default → override to `display: flex; flex-direction: row`
- `.tab-group-line` is INSIDE `.tab-stack > .tab-background > .tab-group-line` (within each tab)
- Group indicator line controlled by CSS variables:
  - `--tab-group-line-color: light-dark(var(--tab-group-color), var(--tab-group-color-invert))`
  - `--tab-group-line-thickness: 2px`
  - `--tab-group-line-toolbar-border-distance: 1px`
- Line uses `position: absolute`, `background-color: var(--tab-group-line-color)`
- Enabled via: `tab-group & { display: flex; }` (nested CSS)
- `.tab-group-label-hover-highlight` uses `box-shadow` ring for hover (can bleed beyond margins)
- For collapsed groups with single tab: line appears on `.tab-group-label-container`

## Tab Group Internal Structure (shared)

```
tab-group
  ├── .tab-group-label-container (vbox, pack="center")
  │   └── .tab-group-label-hover-highlight (vbox, pack="center")
  │       └── .tab-group-label (label element, role="button")
  ├── <html:slot/> (where .tabbrowser-tab children are slotted)
  ├── .tab-group-line (group color indicator)
  └── .tab-group-overflow-count-container (vbox, pack="center")
      └── .tab-group-overflow-count (label, role="button")
```

### Tab Group CSS Variables
- `--tab-group-color` — the group's assigned color
- `--tab-group-color-invert` — inverted for dark mode
- `--tab-group-color-pale` — lighter variant for collapsed state
- `--tab-group-line-color` — computed line color (use transparent to hide)
- `--tab-group-line-thickness` — line height (use 0px to hide)
- `--tab-hover-background-color: color-mix(in srgb, currentColor 11%, transparent)`
