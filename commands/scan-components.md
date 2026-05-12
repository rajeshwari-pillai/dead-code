---
description: Find unused React, Vue, or Angular components — components that are defined/exported but never rendered or registered anywhere in the project. Provides exact removal steps with confidence ratings.
---

Scan for unused UI components in: $ARGUMENTS

Follow these steps precisely.

## Step 1 — Detect framework

Check for:
- `.tsx` / `.jsx` files + `import React` or `from 'react'` → **React**
- `.vue` files + `<template>` / `defineComponent` / `<script setup>` → **Vue.js**
- `.component.ts` + `@Component` decorator + `angular.json` → **Angular**
- `next.config.*` + `pages/` or `app/` directory → **Next.js** (React-based, extra page rules apply)
- `nuxt.config.*` + `pages/` → **Nuxt.js** (Vue-based, extra page rules apply)

## Step 2 — Collect all component definitions

### React
Find every exported component:
```
grep -r "export.*const\|export.*function\|export default function\|export default class" --include="*.tsx" --include="*.jsx" .
```
For each, record: component name, file path, export type (named / default).

### Vue.js
Find every `.vue` file — each file is a component. Also find:
```
grep -r "defineComponent\|export default {" --include="*.vue" .
```

### Angular
Find every `@Component` decorated class:
```
grep -r "@Component" --include="*.ts" .
```
Record: selector string (e.g. `app-user-card`), class name, file path.

## Step 3 — Search for usages project-wide

### React
For each component `MyComponent`:
- Search JSX usage: `grep -r "<MyComponent" src/`
- Search dynamic usage: `grep -r "MyComponent" src/` (catches `React.createElement(MyComponent)`, lazy imports)
- Search re-exports: `grep -r "MyComponent" src/index.ts` or barrel files

### Vue.js
For each component `MyCard.vue` / `MyCard`:
- Template usage: `grep -r "<MyCard\|<my-card" src/`
- Import usage: `grep -r "import.*MyCard" src/`
- Dynamic component: `grep -r ":is=\"MyCard\"\|component.*MyCard" src/`
- Global registration: `grep -r "app.component.*MyCard\|Vue.component.*MyCard" src/`

### Angular
For each component with selector `app-my-card`:
- Template usage: `grep -r "<app-my-card" src/`
- Module declarations + exports: `grep -r "MyCardComponent" src/`
- Dynamic: `grep -r "ViewContainerRef\|createComponent.*MyCard" src/`

## Step 4 — Check special cases before flagging

**Do NOT flag:**
- Next.js: files in `pages/` or `app/` — they are auto-registered as routes
- Angular: components in a module's `bootstrap` array
- Components registered globally (`app.component()` in Vue, `NgModule.declarations` with re-export)
- Components used only in Storybook files (`*.stories.tsx`) — flag as MEDIUM, not dead
- Components only used in test files (`*.test.tsx`, `*.spec.ts`) — flag as MEDIUM

## Step 5 — Output findings

### Summary table
```
## Unused Components Report

Framework: {React | Vue | Angular | Next.js | Nuxt.js}
Components scanned: {N}
Unused found: {N}

| # | Confidence | Component | File | Last touched |
|---|-----------|-----------|------|--------------|
| 1 | HIGH       | LegacyBanner | components/LegacyBanner.tsx | - |
| 2 | MEDIUM     | OldPaymentCard | components/OldPaymentCard.vue | only in stories |
| 3 | LOW        | AdminWidget | components/AdminWidget.tsx | dynamic import possible |
```

### Per-finding block

For EVERY unused component:

```
---
### Finding #N — Confidence: {HIGH | MEDIUM | LOW}
**Unused component: {ComponentName}**
`{file}:{line}`

**Confidence: HIGH** — searched project-wide, 0 usages found outside definition.
**Confidence: MEDIUM** — only used in tests/stories, or globally registered check uncertain.
**Confidence: LOW** — dynamic import, lazy loading, or string-based component reference possible.

**Why it's dead**
{One sentence: no JSX render / no import / selector never in template}

**Verify**
```bash
grep -r "{ComponentName}" src/
# Expected: only the definition file and this finding
```

**Solution — safe to remove**
```bash
# Delete the component file:
rm {file}

# Also remove its import from any barrel/index file:
grep -r "from.*{ComponentName}" src/
```

**Also check**
- Any associated test file: `{ComponentName}.test.tsx` / `{ComponentName}.spec.ts`
- Any associated style file: `{ComponentName}.module.css` / `{ComponentName}.scss`
- Any associated story: `{ComponentName}.stories.tsx`
```

## Confidence rules

**HIGH** — zero usages found in all `.tsx`/`.jsx`/`.vue`/`.html` template files and no dynamic reference.

**MEDIUM** — one of:
- Component only used in test or story files
- Component is globally registered (could be used in templates without explicit import)
- Lazy-loaded via `React.lazy()` or dynamic `import()` with a variable path

**LOW** — one of:
- Component name is generic (`Card`, `Button`, `Modal`) — grep may miss dynamic string usage
- Framework uses auto-import (Nuxt, Vue with unplugin-auto-import) — file presence = auto-registered
- Recently added — may be wired up in a PR not yet merged