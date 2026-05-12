---
description: Find unused React props, Vue props, and Angular @Input()/@Output() bindings — defined in the component interface but never read in the component body or passed from any parent.
---

Scan for unused component props in: $ARGUMENTS

Follow these steps precisely.

## Step 1 — Detect framework

- `.tsx` / `.jsx` + `interface.*Props` or `type.*Props` or `PropTypes` → **React**
- `.vue` + `defineProps` or `props:` option → **Vue.js**
- `.component.ts` + `@Input()` / `@Output()` → **Angular**

## Step 2 — Collect all prop definitions

### React
Find all Props interfaces/types:
```bash
grep -rn "interface.*Props\|type.*Props\s*=" --include="*.tsx" --include="*.jsx" --include="*.ts" src/
```
For each Props type, read the component file and list every field. Then check:
- Is the field destructured in the component function? (`const { title, legacyId } = props`)
- Is it accessed via `props.fieldName`?
- Is it used in JSX or returned value?

### Vue.js
Find all `defineProps` calls:
```bash
grep -rn "defineProps" --include="*.vue" src/
```
For each prop field:
- Is it accessed as `props.fieldName` in `<script setup>`?
- Is it used in `<template>` as `{{ propName }}` or `:attr="propName"`?

### Angular
Find all `@Input()` and `@Output()` decorators:
```bash
grep -rn "@Input()\|@Output()" --include="*.ts" src/
```
For each `@Input() propName`:
- Is `propName` used in the component's template?
- Is `[propName]="value"` or `propName="value"` in any parent template?

For each `@Output() eventName`:
- Is `this.eventName.emit(...)` called in the component class?
- Is `(eventName)="handler"` in any parent template?

## Step 3 — Two-level check

**Level 1 — Unused inside component** (HIGH confidence):
The prop is defined but never read inside the component's own template/body.

**Level 2 — Never passed from parent** (MEDIUM confidence):
The prop is used inside the component but no parent ever passes it — meaning it always has its default value or `undefined`. Search all usages of `<ComponentName` and check if the prop is ever bound.

## Step 4 — Output findings

### Summary table
```
## Unused Props Report

Framework: {React | Vue | Angular}
Components scanned: {N}
Unused props found: {N}

| # | Confidence | Level | Component | Prop | File:Line |
|---|-----------|-------|-----------|------|-----------|
| 1 | HIGH       | Unused in body | PaymentCard | legacyId | components/PaymentCard.tsx:8 |
| 2 | HIGH       | Unused in body | UserForm | subtitle | components/UserForm.vue:5 |
| 3 | MEDIUM     | Never passed from parent | StatusBadge | variant | components/StatusBadge.tsx:12 |
| 4 | LOW        | Spread props possible | DataTable | onLegacySort | components/DataTable.tsx:20 |
```

### Per-finding block

```
---
### Finding #N — Confidence: {HIGH | MEDIUM | LOW}
**Unused prop: `{propName}` in `{ComponentName}`**
`{file}:{line}`

**Level**: {Unused inside component body | Never passed from any parent}

**Why it's dead**
{One sentence: prop defined in interface but never destructured / accessed / bound}

**Current code**
```tsx
// The Props interface with the dead prop highlighted
interface {ComponentName}Props {
  title: string;
  legacyId: string;   // ← never used below
}
```

**Verify**
```bash
# Check if prop is ever read in component body:
grep -n "legacyId" {file}

# Check if prop is ever passed from a parent:
grep -r 'legacyId' src/ --include="*.tsx" --include="*.jsx" --include="*.vue" --include="*.html"
```

**Solution**
```tsx
// REMOVE the unused prop from the interface:
interface {ComponentName}Props {
  title: string;
  // legacyId removed
}

// Also remove from destructuring if present:
// const { title, legacyId } = props  →  const { title } = props
```
```

## Confidence rules

**HIGH**:
- Prop defined in interface/defineProps/@Input but never destructured, accessed, or interpolated anywhere in the component file

**MEDIUM**:
- Prop is used inside the component but never bound in any parent template — always undefined/default
- Prop only used in a commented-out block

**LOW**:
- Component uses spread props (`{...props}`, `v-bind="$attrs"`, `@HostBinding`) — spread may forward the prop
- Prop used conditionally via `props[dynamicKey]`
- Component is a base/abstract component designed to be extended