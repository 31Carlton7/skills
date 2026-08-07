---
name: swiftui
description: SwiftUI mental model (identity, lifetime, dependencies), performance rules for views/List/Table, and the iOS 26 / macOS Tahoe Liquid Glass design APIs. Use when writing or reviewing SwiftUI code, debugging state loss, broken animations, slow updates/hangs/hitches, or adopting the new design system.
---

# SwiftUI

Distilled from three WWDC sessions:
- [Demystify SwiftUI (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10022/) — identity, lifetime, dependencies
- [Demystify SwiftUI performance (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10160/) — dependency graph, slow updates, List/Table
- [Build a SwiftUI app with the new design (WWDC25)](https://developer.apple.com/videos/play/wwdc2025/323/) — Liquid Glass APIs

## Core mental model

When SwiftUI looks at code it sees three things:

1. **Identity** — how SwiftUI recognizes elements as the same or distinct across updates.
2. **Lifetime** — the duration of an identity. View *values* (the structs) are ephemeral, recreated on every body evaluation; identity is what persists.
3. **Dependencies** — the inputs (properties, @State, @Binding, @Environment, observable objects) that, when changed, require a new body. Views + dependencies form a graph, not a tree; SwiftUI re-evaluates only invalidated views.

**The single most important consequence:** `@State`/`@StateObject` storage is tied to identity. When identity changes, state is destroyed and recreated from initial values. Unexpected state loss, broken transitions, and flashing UI are almost always identity bugs.

## Identity rules

- **Explicit identity**: `ForEach(items)` (via `Identifiable`), `ForEach(items, id: \.someKey)`, `.id(_:)`. **Structural identity**: type + position in the hierarchy — every `if`/`else` branch is a *distinct* view with distinct identity.
- Identifiers must be **stable** (never generate in a computed property — `var id: UUID { UUID() }` is a classic bug; don't use array indices) and **unique** (one ID per view; a non-unique key like `name` drops rows and breaks animations). Use database IDs or stable properties of the data.
- **Branch vs. modifier**: `if expired { content.opacity(0.3) } else { content }` creates two identities — state resets and views fade in/out instead of animating in place. Prefer a single view with an **inert modifier**: `content.opacity(expired ? 0.3 : 1)`. Inert modifiers (opacity 1, padding 0, `transformEnvironment`, etc.) are cheap and get pruned. Before writing a branch, ask: is this two different views, or two states of one view?
- **Avoid `AnyView`** wherever possible. It erases the type structure SwiftUI uses for identity, hurts performance, hides compiler diagnostics, and hurts readability. In helper functions that return different view types per branch, apply `@ViewBuilder` to the function and use plain `if`/`switch` instead of wrapping in `AnyView`.

## Performance rules

Slow updates cause hangs (delayed response) and hitches (skipped animation frames). Common causes and fixes:

- **Keep `body` cheap.** No data filtering, sorting, expensive string interpolation, bundle lookups, or heap allocation in body. Move work to the model or an async `.task`.
- **Don't do synchronous expensive work in `@StateObject`/`@State` initializers** (e.g. fetching in an object's `init` that's lazily hit from body). Make it async and load in `.task { await ... }`.
- **Scope dependencies tightly.** A view whose value contains a whole `Dog` re-renders when *any* dog property changes. Extract subviews that take only what they render (`ScalableDogImage(image:)` not `(dog:)`). The `Observable` macro also auto-narrows dependencies to properties actually read. Use judgment — not every dependency needs extraction.
- **Debugging re-renders:** call `Self._printChanges()` in body (or via `expression Self._printChanges()` at an LLDB breakpoint) to see why body ran. `@self` = view value changed; a named property = that dynamic property changed. Underscore API — debug only, never ship it.

### List and Table

List/Table gather **all row identifiers eagerly, up front**. Rows are built on demand, but only if SwiftUI can count rows without building content — so **each ForEach element must resolve to a constant number of views**:

- No `if` inside ForEach content to filter rows (element count becomes 0-or-1 → all rows must be built). No `AnyView` (count unknown). Filter the *data*, and do the filtering in the model (cached), not inline in body (linear cost on every evaluation).
- Keep identifiers cheap to compute; row count = elements × views-per-element, and views-per-element must be constant.
- Flatten nested `ForEach` — except dynamic sections (`ForEach` of sections containing `ForEach` of rows), which SwiftUI understands and keeps fast.
- Table: prefer the streamlined `Table { ... ForEach(collection) }` initializer (back-deploys); note iOS 17 changed row identity to come from the ForEach data, not `TableRow` values.

## Liquid Glass / new design (Xcode 26, iOS 26, macOS Tahoe)

Building with the Xcode 26 SDK updates most standard components automatically. Key APIs:

- **App structure**: floating glass sidebar on `NavigationSplitView`; `backgroundExtensionEffect()` extends hero images under the sidebar without clipping. Tab bar floats and can minimize on scroll: `.tabBarMinimizeBehavior(.onScrollDown)`; put controls above it with `.tabViewBottomAccessory { }` and read `tabViewBottomAccessoryPlacement` from the environment to adapt when collapsed.
- **Sheets/presentations**: partial-height sheets get an inset glass background — remove custom `presentationBackground`s. Sheets/menus/popovers can morph out of their presenting button via zoom-transition source/destination.
- **Toolbars**: items sit on floating glass and auto-group; use `ToolbarSpacer(.fixed)`/`.flexible` to control grouping, `.sharedBackgroundVisibility(.hidden)` to detach an item, `.badge(_:)` on toolbar items. Icons are monochrome by default — tint only to convey meaning. Remove any custom backgrounds/darkening behind bars; tune the scroll edge effect with `scrollEdgeEffectStyle`.
- **Search**: `.searchable` on `NavigationSplitView` → top-trailing field (Mac/iPad) / bottom field (iPhone); `.searchToolbarBehavior` for the minimized button variant. Dedicated search tab: give the tab a `.search` role and put `.searchable` on the `TabView`.
- **Controls**: bordered buttons are capsules; `.buttonBorderShape` to override; extra-large size and `.glass` / `.glassProminent` button styles exist. Sliders support tick marks (step or manual `ticks` closure) and `neutralValue` for non-leading fill start. Use `ConcentricRectangle`/container-concentric corners to match container curvature.
- **Custom glass**: `.glassEffect()` (default capsule; pass a shape to customize; `.tint` for meaning; `.interactive` for touch response). Multiple glass elements **must** share a `GlassEffectContainer` to sample each other correctly; add `glassEffectID(_:in:)` with a `Namespace` for fluid morphing between states.
- **Adoption checklist**: build with Xcode 26, audit backgrounds behind sheets/toolbars and remove them, then add custom glass only for signature elements.
