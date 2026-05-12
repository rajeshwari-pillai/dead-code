<div align="center">

![Dead Code Banner](https://img.shields.io/badge/🧹_Dead_Code-Universal_Unused_Code_Detector-orange?style=for-the-badge)

# dead-code

### Universal Unused Code Detector — Backend + Frontend

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](../LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/rajeshwari-p/claude-skills/releases)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](https://claude.ai/code)
[![Languages](https://img.shields.io/badge/languages-12-blue.svg)](#language-support)
[![Commands](https://img.shields.io/badge/commands-10-orange.svg)](#commands)

**10 commands. 12 languages. Backend + Frontend. Finds unused imports, functions, endpoints, tasks, env vars, components, props, CSS classes, and unreachable code. Every finding includes a complete removal solution with confidence rating.**

[Quick Start](#quick-start) |
[Commands](#commands) |
[Confidence Levels](#confidence-levels) |
[Language Support](#language-support) |
[What It Finds](#what-it-finds)

</div>

---

## Overview

`dead-code` scans your codebase for code that exists but is never used. It auto-detects your language and framework, applies framework-aware rules to avoid false positives, and outputs exact removal steps for every finding — rated with 3 confidence levels.

---

## Quick Start

### Install

```bash
cp -r dead-code ~/.claude/skills/
```

Or install from repo root:

```bash
curl -sSL https://raw.githubusercontent.com/rajeshwari-p/claude-skills/main/install.sh | bash
```

---

## Commands

10 commands covering all dead code scenarios — backend and frontend.

### Backend commands

| Command | What it finds |
|---------|--------------|
| [`scan`](#scan) | All dead code — full project sweep |
| [`scan-imports`](#scan-imports) | Unused imports, using, require, use statements |
| [`scan-functions`](#scan-functions) | Unused functions, methods, classes |
| [`scan-endpoints`](#scan-endpoints) | Unused API routes and orphaned handlers |
| [`scan-tasks`](#scan-tasks) | Unused background tasks and orphaned schedule entries |
| [`scan-env`](#scan-env) | Unused env vars and dead config keys |
| [`scan-unreachable`](#scan-unreachable) | Code after return/throw/raise/panic, dead branches |

### Frontend commands

| Command | What it finds |
|---------|--------------|
| [`scan-components`](#scan-components) | Unused React / Vue / Angular components |
| [`scan-props`](#scan-props) | Unused React props, Vue props, Angular @Input/@Output |
| [`scan-styles`](#scan-styles) | Unused CSS classes, SCSS variables/mixins, Tailwind tokens |

---

### `scan`

Full project sweep — finds all categories of dead code, ranks by action level.

```bash
/dead-code-scan
/dead-code-scan payments/
/dead-code-scan forms/
```

**Output**: Category summary table → per-finding blocks with solutions → fix priority list (safe now / verify first / coordinate).

---

### `scan-imports`

Finds unused import statements across all languages. Checks each imported symbol independently against the file body.

```bash
/dead-code-scan-imports forms/helpers/query_helpers/
/dead-code-scan-imports src/services/
/dead-code-scan-imports .
```

**Per language:**

| Language | What it scans |
|----------|--------------|
| Python | `import X`, `from X import Y`, per-symbol check |
| Java | `import com.example.X`, wildcard imports |
| Go | all entries in `import (...)` block |
| TypeScript/JS | `import { X }`, `import type`, `require()` |
| Ruby | `require`, `require_relative` |
| PHP | `use App\X`, `use Illuminate\X` |
| C# | `using System.X`, `using Namespace.X` |

**Output**: Table of unused imports → per-finding blocks with exact line to delete.

---

### `scan-functions`

Finds unused functions, methods, and classes. Searches project-wide before flagging. Respects framework auto-registration patterns to avoid false positives.

```bash
/dead-code-scan-functions payments/helpers/
/dead-code-scan-functions src/
/dead-code-scan-functions .
```

**Will NOT flag (framework-registered):**
- Django: `APIView`, `@shared_task`, `@receiver` decorated functions
- Spring: `@Service`, `@Component`, `@EventListener`, `@Scheduled`
- NestJS: `@Injectable()`, `@Controller()`, `@Get/Post/Put/Delete`
- Rails: controller actions in `routes.rb`, ActiveRecord callbacks
- Go: `http.HandlerFunc` signature functions, `init()`

**Output**: Per-finding blocks with project-wide grep command to verify + exact line range to delete.

---

### `scan-endpoints`

Finds unused or broken API routes — handlers that no longer exist, paths never referenced in tests or frontend, and versioned-out endpoints.

```bash
/dead-code-scan-endpoints .
/dead-code-scan-endpoints src/routes/
```

**Frameworks covered:**

| Framework | Route detection |
|-----------|----------------|
| Django DRF | `urls.py` path/re_path/router.register |
| FastAPI / Flask | `@router.get/post`, `@app.route` |
| Spring Boot | `@GetMapping`, `@PostMapping`, `@RequestMapping` |
| Express / Fastify | `router.get/post/put/delete` |
| NestJS | `@Get()`, `@Post()`, `@Controller()` |
| Rails | `routes.rb` resources, get/post/put |
| Laravel | `Route::get/post/apiResource` |
| ASP.NET | `[HttpGet]`, `app.MapGet` |

**Output**: Route table with handler existence check → per-finding blocks with route + handler removal steps.

---

### `scan-tasks`

Finds background tasks never enqueued and orphaned schedule entries pointing to deleted task paths.

```bash
/dead-code-scan-tasks .
/dead-code-scan-tasks workers/
```

**Task systems covered:**

| System | Language | Detection |
|--------|----------|-----------|
| Celery | Python | `@shared_task`, `.delay()`, `.apply_async()` |
| Sidekiq | Ruby | `include Sidekiq::Worker`, `.perform_async` |
| Bull / BullMQ | Node | `new Queue()`, `new Worker()`, `.add()` |
| Quartz | Java | `implements Job`, `@DisallowConcurrentExecution` |
| Spring Scheduler | Java | `@Scheduled` |
| Go cron | Go | `cron.AddFunc`, `cron.New()` |
| .NET Background | C# | `IHostedService`, `BackgroundService` |

**Output**: Task table with enqueue-call count → per-finding blocks with task deletion + schedule entry removal.

---

### `scan-env`

Cross-checks environment variables and config keys between code references and config files. Finds dead keys, missing documentation, stale references, and duplicates.

```bash
/dead-code-scan-env .
/dead-code-scan-env gqinstitute_backend/settings.py
```

**Config files scanned:**

| Language | Config files |
|----------|-------------|
| Python | `.env`, `.env.example`, `settings.py` |
| Java | `application.yml`, `application.properties`, `.env` |
| Go | `.env`, `config.yaml`, `config.go` |
| Node | `.env`, `.env.example`, `config/` |
| Ruby | `.env`, `config/environments/*.rb`, `credentials.yml.enc` |
| PHP | `.env`, `config/services.php`, `.env.example` |
| C# | `appsettings.json`, `appsettings.*.json`, `.env` |

**Output**: Key status table (dead / missing / stale / duplicate) → per-finding blocks with all files to update.

---

### `scan-unreachable`

Finds code after `return`/`throw`/`raise`/`panic`/`exit` and dead conditional branches (constant conditions).

```bash
/dead-code-scan-unreachable payments/helpers/
/dead-code-scan-unreachable src/
/dead-code-scan-unreachable .
```

**Detects:**
- Statements after unconditional `return` / `raise` / `throw` / `panic`
- `if False:` / `if (false)` / constant-condition branches
- `if True:` else blocks
- Code after `os.Exit()` / `System.exit()` / `process.exit()`
- Unreachable `catch` blocks after always-returning `try`

**Output**: Per-finding blocks with full function context, exact lines to delete, and cleaned-up function after removal.

---

### `scan-components`

Finds unused React, Vue, and Angular components — exported but never rendered, imported, or registered.

```bash
/dead-code-scan-components src/components/
/dead-code-scan-components .
```

**Detects:**
- React: exported component never used as `<ComponentName />` in any `.tsx`/`.jsx`
- Vue: `.vue` file never imported or registered globally
- Angular: `@Component` selector never in any template
- Next.js pages with no `<Link>` or navigation pointing to them
- Nuxt.js pages with no `NuxtLink` or `navigateTo`

**Output**: Component table → per-finding blocks with grep verify command + file deletion steps.

---

### `scan-props`

Finds unused props — defined in a component interface but never read inside the component body, or never passed from any parent.

```bash
/dead-code-scan-props src/components/
/dead-code-scan-props src/components/PaymentCard.tsx
```

**Detects:**
- React: `interface Props` field never destructured or accessed
- Vue: `defineProps` field never used in template or script
- Angular: `@Input()` never bound from parent; `@Output()` emitter never called

**Two-level check**: unused inside component body (HIGH) + never passed from any parent (MEDIUM).

**Output**: Props table → per-finding blocks with current interface, cleaned-up interface, and verify grep.

---

### `scan-styles`

Finds unused CSS classes, SCSS variables/mixins, CSS custom properties, keyframes, and Tailwind custom tokens.

```bash
/dead-code-scan-styles src/styles/
/dead-code-scan-styles src/
/dead-code-scan-styles tailwind.config.js
```

**Detects:**
- CSS/SCSS class selectors never in `className`, `class=`, or `:class`
- SCSS `$variables` never interpolated or used in values
- SCSS `@mixin` never `@include`d
- CSS `--custom-properties` never referenced via `var(--name)`
- `@keyframes` name never used in `animation:`
- Tailwind `theme.extend` keys never used as utility classes in templates

**Output**: Style table → per-finding blocks with exact line ranges to delete.

---

## Confidence Levels

Every finding is rated before a solution is written.

| Level | Meaning | What to do |
|-------|---------|-----------|
| **HIGH** | Confirmed dead — searched project-wide, 0 usages found | Delete immediately |
| **MEDIUM** | Likely dead — pattern matches but dynamic usage or external caller possible | Run verify command, then delete |
| **LOW** | Suspicious — framework auto-discovery or external consumer possible | Investigate before deleting |

### How confidence is assigned

**HIGH** when:
- Searched entire project, only definition line found
- Code is structurally after `return`/`throw` (unreachable)
- Import symbol appears 0 times outside import line
- Beat schedule entry points to non-existent task path

**MEDIUM** when:
- Public/exported symbol — external service might call it
- Dynamic dispatch possible (`getattr`, `reflect`, string-based names)
- Only called from test files — production dead but tested
- Framework might auto-register (Spring component scan, Rails autoload)

**LOW** when:
- Symbol name is generic — grep results unreliable
- External monitoring or third-party integration might use it
- Recently added — may not be wired up yet

---

## Language Support

### Backend

| Language | Imports | Functions | Endpoints | Tasks | Env Vars | Unreachable |
|----------|---------|-----------|-----------|-------|----------|-------------|
| Python | ✓ | ✓ | ✓ Django/FastAPI/Flask | ✓ Celery | ✓ | ✓ |
| Java | ✓ | ✓ | ✓ Spring Boot/JAX-RS | ✓ Quartz/Scheduler | ✓ | ✓ |
| Go | ✓ | ✓ | ✓ Gin/Echo/net/http | ✓ Go cron | ✓ | ✓ |
| TypeScript | ✓ | ✓ | ✓ Express/NestJS/Next.js | ✓ Bull/BullMQ | ✓ | ✓ |
| JavaScript | ✓ | ✓ | ✓ Express/Fastify | ✓ Bull | ✓ | ✓ |
| Ruby | ✓ | ✓ | ✓ Rails/Sinatra | ✓ Sidekiq | ✓ | ✓ |
| PHP | ✓ | ✓ | ✓ Laravel/Symfony | ✓ Horizon | ✓ | ✓ |
| C# | ✓ | ✓ | ✓ ASP.NET Core | ✓ .NET Background | ✓ | ✓ |

### Frontend

| Framework | Components | Props | Styles | Hooks | Routes |
|-----------|-----------|-------|--------|-------|--------|
| React | ✓ | ✓ | ✓ CSS Modules | ✓ custom hooks | ✓ |
| Next.js | ✓ | ✓ | ✓ | ✓ | ✓ Pages + App Router |
| Vue.js | ✓ | ✓ defineProps | ✓ scoped styles | ✓ composables | ✓ |
| Nuxt.js | ✓ | ✓ | ✓ | ✓ | ✓ pages/ + app/ |
| Angular | ✓ | ✓ @Input/@Output | ✓ | ✓ services | ✓ |
| CSS/SCSS | — | — | ✓ variables/mixins/keyframes | — | — |
| Tailwind | — | — | ✓ custom tokens | — | — |

---

## What It Finds

| Category | Examples |
|----------|---------|
| Unused imports | `import json` — json never used |
| Unreachable code | Any line after `return` / `raise` / `throw` |
| Unused functions | Defined but 0 callers in project |
| Unused classes | Never instantiated, extended, or imported |
| Unused API routes | Handler missing or path never called |
| Unused tasks | `@shared_task` never `.delay()`d |
| Orphaned schedule entries | Beat / cron entry pointing to deleted task |
| Unused env vars | In `.env.example` but never read in code |
| Missing env docs | Read in code but not in `.env.example` |
| Unused constants | Defined but never referenced |
| Commented-out code | 3+ consecutive lines of commented code |

---

## File Structure

```
dead-code/
  SKILL.md              # Core skill — all language patterns + solution format
  README.md             # This file
  install.sh            # Install to ~/.claude/skills/dead-code/
  uninstall.sh          # Remove from ~/.claude/skills/
  commands/
    scan.md             # Full project sweep — all categories
    scan-imports.md     # Unused imports across all languages
    scan-functions.md   # Unused functions, methods, classes
    scan-endpoints.md   # Unused API routes and orphaned handlers
    scan-tasks.md       # Unused background tasks and schedule entries
    scan-env.md         # Unused env vars and dead config keys
    scan-unreachable.md # Code after return/throw/raise, dead branches
```

---

## License

MIT License — see [LICENSE](../LICENSE) for details.