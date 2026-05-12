---
description: Find unused CSS classes, SCSS variables, mixins, custom properties, keyframes, and Tailwind custom tokens that are defined but never referenced in any template, JSX, or HTML file.
---

Scan for unused styles in: $ARGUMENTS

Follow these steps precisely.

## Step 1 — Detect style stack

Check for:
- `.css` files without preprocessor → **Plain CSS**
- `.scss` / `.sass` files → **SCSS/Sass**
- `.less` files → **Less**
- `tailwind.config.js` / `tailwind.config.ts` → **Tailwind CSS**
- `*.module.css` / `*.module.scss` → **CSS Modules** (React / Next.js)
- `<style>` blocks in `.vue` files → **Vue scoped styles**
- `styled-components` / `@emotion` imports → **CSS-in-JS** (flag separately)

## Step 2 — Collect all style definitions

### CSS / SCSS classes
```bash
grep -rn "^\s*\.[a-zA-Z][a-zA-Z0-9_-]*\s*[{,]" --include="*.css" --include="*.scss" --include="*.sass" --include="*.less" .
```
For each class selector `.my-class`, record: class name, file, line.

### SCSS variables
```bash
grep -rn "^\s*\$[a-zA-Z][a-zA-Z0-9_-]*\s*:" --include="*.scss" --include="*.sass" .
```

### SCSS mixins
```bash
grep -rn "@mixin\s\+[a-zA-Z][a-zA-Z0-9_-]*" --include="*.scss" --include="*.sass" .
```

### CSS custom properties
```bash
grep -rn "--[a-zA-Z][a-zA-Z0-9_-]*\s*:" --include="*.css" --include="*.scss" .
```

### @keyframes
```bash
grep -rn "@keyframes\s\+[a-zA-Z][a-zA-Z0-9_-]*" --include="*.css" --include="*.scss" .
```

### Tailwind custom tokens
Read `tailwind.config.js` / `tailwind.config.ts` — collect all keys under `theme.extend` (colors, spacing, fontFamily, etc.).

## Step 3 — Search for usages

### For CSS classes
Search templates, JSX, HTML, and Vue files:
```bash
# JSX / TSX (className)
grep -r "className.*{class-name}\|className=\".*{class-name}" --include="*.tsx" --include="*.jsx" src/

# HTML / Vue templates
grep -r "class=\".*{class-name}\|:class.*{class-name}" --include="*.html" --include="*.vue" src/

# CSS Modules (styles.className)
grep -r "styles\.{camelCaseName}" --include="*.tsx" --include="*.jsx" src/

# Dynamic classes (template literals, clsx, classnames)
grep -r "{class-name}" src/
```

### For SCSS variables (`$my-var`)
```bash
grep -rn "\$my-var" --include="*.scss" --include="*.sass" --include="*.css" .
# Count occurrences — definition line + any usage lines
```

### For SCSS mixins (`@mixin my-mixin`)
```bash
grep -rn "@include\s\+my-mixin" --include="*.scss" --include="*.sass" .
```

### For CSS custom properties (`--my-prop`)
```bash
grep -rn "var(--my-prop)" --include="*.css" --include="*.scss" --include="*.tsx" --include="*.html" --include="*.vue" .
```

### For @keyframes (`@keyframes myAnim`)
```bash
grep -rn "animation.*myAnim\|animation-name.*myAnim" --include="*.css" --include="*.scss" --include="*.tsx" --include="*.html" .
```

### For Tailwind custom tokens (e.g. color key `legacy-brand`)
```bash
grep -r "legacy-brand" --include="*.tsx" --include="*.jsx" --include="*.html" --include="*.vue" src/
# Covers: text-legacy-brand, bg-legacy-brand, border-legacy-brand, etc.
```

## Step 4 — Special cases — do NOT flag

- CSS reset / normalize rules (body, html, *, ::before, ::after)
- Classes used only in dynamically constructed strings (`classList.add(varName)`) — flag as LOW
- Classes in `@media` print stylesheets — may be used outside normal flow
- SCSS variables / mixins in a `_variables.scss` / `_mixins.scss` designed to be `@use`d by other files — verify across all files
- CSS Modules: camelCase conversion — `.my-class` → `styles.myClass`; search for both forms
- Tailwind: JIT mode scans all template files — a class not found in current scan may still be safe if `content` glob is wider

## Step 5 — Output findings

### Summary table
```
## Unused Styles Report

Stack: {Plain CSS | SCSS | Tailwind | CSS Modules | Vue Scoped}
Style files scanned: {N}
Template files scanned: {N}
Unused found: {N}

| # | Confidence | Type | Name | File:Line |
|---|-----------|------|------|-----------|
| 1 | HIGH       | CSS class | .legacy-banner | styles/main.scss:45 |
| 2 | HIGH       | SCSS variable | $old-spacing | styles/_vars.scss:12 |
| 3 | HIGH       | @keyframes | legacyFadeIn | styles/animations.css:88 |
| 4 | MEDIUM     | CSS class | .card-title | components/Card.module.css:5 |
| 5 | LOW        | Tailwind token | legacy-brand | tailwind.config.js:14 |
```

### Per-finding block

```
---
### Finding #N — Confidence: {HIGH | MEDIUM | LOW}
**Unused {CSS class | SCSS variable | mixin | custom property | keyframes | Tailwind token}: {name}**
`{file}:{line}`

**Why it's dead**
{One sentence: class never in className / variable never interpolated / mixin never @included}

**Verify**
```bash
{exact grep command to confirm 0 usages}
```

**Solution — remove these lines**
```css
/* REMOVE from {file}:{line_start}–{line_end}: */
{exact lines to delete}
```
```

## Confidence rules

**HIGH**:
- Class/variable/mixin/keyframe searched across all templates and style files — 0 usages
- SCSS variable only defined, never interpolated (`#{$var}`) or used in value

**MEDIUM**:
- CSS Module class: camelCase conversion makes grep unreliable — check both `.my-class` and `styles.myClass`
- Class appears in dynamically constructed strings (`'card-' + type`) — may be used at runtime
- Class in a shared component library file — external consumers possible

**LOW**:
- Generic name (`.active`, `.hidden`, `.open`) — grep results unreliable
- Tailwind custom token — JIT purge may keep or remove based on `content` config
- Class defined in a vendor override file (`_overrides.scss`) — intentional specificity