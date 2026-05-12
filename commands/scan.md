---
description: Scan an entire project or directory for all types of dead code — unused imports, functions, endpoints, tasks, env vars, and unreachable blocks. Works for Python, Java, Go, JS/TS, Ruby, PHP, C#. Provides solutions with confidence levels.
---

Scan for all dead code in: $ARGUMENTS

If no argument given, scan the entire project from the current directory.

## Step 1 — Identify language and framework

Check file extensions and imports to determine:
- Primary language (Python / Java / Go / TypeScript / Ruby / PHP / C#)
- Framework (Django / Spring / NestJS / Rails / Laravel / ASP.NET / Gin)
- Background task system (Celery / Sidekiq / Bull / Quartz)

## Step 2 — Find all source files

Collect files to scan:
- Python: `**/*.py` excluding `migrations/`, `__pycache__/`, `.venv/`
- Java/Kotlin: `**/*.java`, `**/*.kt` excluding `target/`, `build/`
- Go: `**/*.go` excluding `vendor/`
- JS/TS: `**/*.{js,ts,tsx}` excluding `node_modules/`, `dist/`, `.next/`
- Ruby: `**/*.rb` excluding `vendor/`
- PHP: `**/*.php` excluding `vendor/`
- C#: `**/*.cs` excluding `bin/`, `obj/`

List the file count per category before reviewing.

## Step 3 — Scan each category

For every file check:
- Imports / using / use / require statements never referenced in the file body
- Functions / methods defined but never called anywhere in the project
- Classes defined but never instantiated, extended, or imported
- Variables assigned but never read
- Code after `return` / `raise` / `throw` / `panic` / `exit`
- API routes / handlers registered nowhere
- Background tasks never enqueued
- Constants / enums never referenced
- Commented-out code blocks (3+ consecutive lines)

## Step 4 — Output

### Project summary
```
## Dead Code Scan — {project or directory}

Language: {language + framework}
Files scanned: {N}
Total dead code items: {N}

| Category            | Count | Lines Removable | Action       |
|---------------------|-------|-----------------|--------------|
| Unused imports      |       |                 | Safe now     |
| Unused functions    |       |                 | Verify first |
| Unused classes      |       |                 | Verify first |
| Unused endpoints    |       |                 | Coordinate   |
| Unreachable code    |       |                 | Safe now     |
| Unused tasks        |       |                 | Verify first |
| Unused env vars     |       |                 | Coordinate   |
| Commented-out code  |       |                 | Safe now     |
| Total               |       |                 |              |
```

### Per-finding block (required for every item)

```
---
### Finding #N — [{CATEGORY}] · Confidence: {HIGH | MEDIUM | LOW}
**{Title}**
`{file}:{line}`
**Action**: {Safe now | Verify first | Needs coordination}

**Confidence explanation**
{What was confirmed: searched project-wide, checked for dynamic usage, etc.}

**Why it's dead**
{One sentence}

**Verify**
```bash
{exact search command — grep, rg, git grep — to confirm zero usages outside definition}
```

**Solution — remove these lines**
```{language}
# Lines {X}–{Y} in {file}:
{exact code to delete}
```

**After removal** _(include when surrounding code needs adjustment)_
```{language}
{file snippet after deletion}
```
```

### Confidence levels

**HIGH** — confirmed dead:
- Searched project-wide, found only the definition line
- Import symbol appears 0 times outside the import statement
- Code is after `return`/`throw`/`panic` — structurally unreachable

**MEDIUM** — likely dead but verify:
- Public/exported symbol — may be used by an external consumer
- Dynamic dispatch possible (`getattr`, `reflect`, string-based imports)
- Only appears in test files — behavior is tested but production path unused

**LOW** — investigate before deleting:
- Symbol name is common enough that a grep match could be coincidental
- Framework may auto-discover it (e.g. Spring component scan, Rails autoload)
- Part of a public API or SDK surface

### Fix priority order

After all findings, output:

```
## Recommended Fix Order

Safe to delete now:
1. Finding #N — {title} ({file}:{line})
...

Delete after verifying:
{N}. Finding #N — {title} ({file}:{line}) — run: {verify command}
...

Coordinate with team:
{N}. Finding #N — {title} ({file}:{line}) — {reason}
...
```