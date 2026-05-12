---
description: Find all unused functions, methods, and classes across any language — Python, Java, Go, TypeScript, Ruby, PHP, C#. Searches project-wide for callers before flagging. Provides exact deletion blocks with confidence levels.
---

Find all unused functions, methods, and classes in: $ARGUMENTS

## Step 1 — Collect all definitions

Scan the target for every function / method / class definition:

**Python:** `def `, `async def `, `class `
**Java/Kotlin:** `public/private/protected [static] [return type] methodName(`, `class `, `interface `, `enum `
**Go:** `func `, `func (receiver) `, `type StructName struct`
**TypeScript/JS:** `function `, `const fn = `, `async function `, `class `, `export function `, `export const`
**Ruby:** `def `, `class `, `module `
**PHP:** `function `, `class `, `interface `
**C#:** `void `, `public/private/protected `, `class `, `interface `

For each definition record: name, file, start line, end line, visibility (public/private/exported).

## Step 2 — Search for callers

For each definition, search the **entire project** (not just the current file):

```bash
# Python
grep -rn "function_name(" . --include="*.py"

# Java
grep -rn "methodName(" . --include="*.java"

# Go
grep -rn "FunctionName(" . --include="*.go"

# TypeScript
grep -rn "functionName(" . --include="*.ts" --include="*.tsx"

# Ruby
grep -rn "method_name" . --include="*.rb"
```

A definition is dead if:
- Only the definition line appears (0 callers)
- Only test file callers appear (production dead, but tested)
- Only the file itself references it (private helper, no external use)

## Step 3 — Apply framework exceptions

Do NOT flag as dead:

**Python / Django:**
- Functions decorated with `@app.route`, `@router.get/post`, `@shared_task`, `@receiver`, `@login_required`
- Methods: `save()`, `clean()`, `__str__()`, `__repr__()`, `get_absolute_url()`
- Classes: any subclass of `APIView`, `ModelViewSet`, `TestCase`, `Model`, `Serializer`
- Anything in `__all__`

**Java / Spring:**
- `@RestController`, `@Controller`, `@Service`, `@Component`, `@Repository` — may be injected by Spring
- `@EventListener`, `@KafkaListener`, `@RabbitListener`, `@Scheduled`
- Methods matching interface contracts or abstract base class signatures
- Public methods in a `@Service` — may be called by other services (flag as MEDIUM, not HIGH)

**Go:**
- Functions matching `http.HandlerFunc` signature (`func(w http.ResponseWriter, r *http.Request)`)
- `init()` functions — always called by runtime
- Interface implementations — exported methods satisfying an interface

**TypeScript / NestJS:**
- Classes decorated with `@Injectable()`, `@Controller()`, `@Module()`
- `@Get()`, `@Post()`, `@Put()`, `@Delete()` decorated methods
- React component functions exported as default or named exports used in JSX

**Ruby / Rails:**
- Controller actions referenced in `routes.rb`
- ActiveRecord callbacks: `before_save`, `after_create`, `validate`
- Rake tasks, Sidekiq workers

**C# / ASP.NET:**
- `[HttpGet]`, `[HttpPost]`, `[Route]` decorated methods
- `IHostedService` implementations
- Entity Framework migrations

## Step 4 — Output

### Summary
```
## Unused Functions & Classes Report — {target}

Language: {language + framework}
Definitions scanned: {N}
Unused found: {N}

| # | Confidence | Type | Name | File | Lines | Action |
|---|-----------|------|------|------|-------|--------|
```

### Per-finding block

```
---
### Finding #N — [{TYPE: Function | Method | Class}] · Confidence: {HIGH | MEDIUM | LOW}
**`{name}` — never called**
`{file}:{start_line}–{end_line}`
**Action**: {Safe now | Verify first | Needs coordination}

**Confidence explanation**
{What was searched, what was found — "searched *.py project-wide, only definition line found"}

**Why it's dead**
{No callers in project / only test callers / framework does not auto-register it}

**Verify**
```bash
{exact grep command — should return only the definition line}
```

**Solution — delete this block**
```{language}
# DELETE lines {start}–{end} in {file}:
{full function/method/class body — copy exact lines}
```

**Note** _(if deletion has side effects)_
{e.g. "also remove the import of this class in other_file.py:12"}
```

### Confidence levels

**HIGH** — project-wide search returned only definition line, no framework registration:
- Private/unexported function with no callers
- Class not subclassed, not decorated, never instantiated

**MEDIUM** — possible hidden usage:
- Public/exported symbol — may be called by external service or consumer repo
- Name is generic (`process`, `handle`, `run`) — grep may be unreliable
- Spring/NestJS bean — container may inject it
- Called only in test files — production dead but tested

**LOW** — framework may auto-discover:
- Class name follows framework conventions (e.g. `*Controller`, `*Service`, `*Repository`)
- Function in a module `__init__.py`
- Method signature matches an interface or abstract base class