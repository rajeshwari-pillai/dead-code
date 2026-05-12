---
name: dead-code
description: This skill should be used when the user asks to "find dead code", "find unused code", "remove unused functions", "clean up unused imports", "find unused endpoints", "find unused variables", "check for unused routes", "find orphaned code", "audit unused env vars", "find unused components", "find unused props", "find unused CSS classes", "find unused styles", or wants to identify code that is no longer referenced or reachable. Works with Python, Java, Go, JavaScript, TypeScript, Ruby, PHP, Kotlin, C#, React, Vue, Angular, CSS, SCSS, Tailwind.
version: 2.0.0
---

# Dead Code — Universal Unused Code Detector

Finds unused functions, classes, endpoints, imports, variables, env vars, routes, background tasks, config keys, React/Vue/Angular components, props, hooks, CSS classes, and styles. Works across all major languages and frameworks — backend and frontend.

---

## Step 1 — Detect Language & Framework

Identify language from file extensions and imports:

| Extension | Language | Common Frameworks |
|-----------|----------|-------------------|
| `.py` | Python | Django, Flask, FastAPI, Celery, SQLAlchemy |
| `.java` | Java | Spring Boot, Quarkus, Micronaut, JAX-RS |
| `.kt` | Kotlin | Spring Boot, Ktor |
| `.go` | Go | net/http, Gin, Echo, Fiber, Chi |
| `.js` / `.ts` | JS / TypeScript | Express, NestJS, Next.js, Fastify, Node |
| `.jsx` / `.tsx` | React | Next.js, Vite, CRA, Remix |
| `.vue` | Vue.js | Nuxt.js, Vite |
| `.component.ts` | Angular | Angular CLI |
| `.css` / `.scss` / `.sass` / `.less` | Styles | Any frontend framework |
| `.rb` | Ruby | Rails, Sinatra, Hanami |
| `.php` | PHP | Laravel, Symfony, CodeIgniter |
| `.cs` | C# | ASP.NET Core, .NET |
| `.rs` | Rust | Actix-web, Axum |

**Framework detection:**

| Signal | Framework |
|--------|-----------|
| `urls.py` + `apiviews/` | Django REST Framework |
| `@app.route` / `@router.get` | Flask / FastAPI |
| `@RestController` / `@GetMapping` | Spring Boot |
| `router.HandleFunc` / `gin.Default()` | Go HTTP / Gin |
| `@Controller` / `@Get` | NestJS |
| `resources :model` / `routes.rb` | Rails |
| `Route::get` / `Route::post` | Laravel |
| `[HttpGet]` / `[ApiController]` | ASP.NET Core |
| `import React` / `from 'react'` / `.tsx` | React |
| `defineComponent` / `.vue` / `<template>` | Vue.js |
| `@Component` / `@NgModule` / `angular.json` | Angular |
| `pages/` dir + `next.config` | Next.js |
| `app/` dir + `layout.tsx` | Next.js App Router |
| `createStore` / `createSlice` / `useSelector` | Redux / Redux Toolkit |
| `create(` from `zustand` | Zustand |
| `defineStore` from `pinia` | Pinia (Vue) |

---

## Step 2 — Language-Specific Dead Code Patterns

### Python

**Unused imports:**
```python
import json                        # dead if `json` never used in file body
from datetime import timedelta     # dead if `timedelta` never referenced
from typing import Optional        # dead if not used in type hints
```
Exceptions: `__all__` re-exports, `TYPE_CHECKING` blocks, `__init__.py` public APIs.

**Unused functions / methods:**
```python
def format_legacy_response(data):  # dead if no callers in project
    ...
```
Check: `grep -r "format_legacy_response" .` — only definition line should appear.

**Unreachable code:**
```python
def get_user(id):
    return db.query(User).get(id)
    logger.info("done")   # dead — after return
```

**Unused variables:**
```python
result = expensive_call()   # dead if result never read below
return other_value
```

**Unused class attributes / constants:**
```python
class Config:
    OLD_TIMEOUT = 30   # dead if never accessed
```

---

### Java

**Unused imports:**
```java
import java.util.ArrayList;     // dead if ArrayList never used
import com.example.OldService;  // dead if OldService never referenced
```

**Unused private methods:**
```java
private String formatLegacy(String input) {  // dead if no callers in class
    return input.trim();
}
```
Note: Public methods may be called via reflection — flag as MEDIUM confidence.

**Unused fields:**
```java
private static final String OLD_URL = "...";  // dead if never read
private int unusedCounter;                     // dead if never read or written
```

**Unreachable code:**
```java
public String getStatus() {
    return "active";
    logger.info("returned");  // dead — after return
}
```

**Unused Spring beans / components:**
```java
@Service
public class LegacyPaymentService {   // dead if never @Autowired or injected
```
Check: `grep -r "LegacyPaymentService" src/` — only definition should appear.

**Unused REST endpoints:**
```java
@GetMapping("/v1/legacy/report")   // dead if no client calls this path
public ResponseEntity<> getLegacyReport() {
```

**Dead `@Configuration` beans:**
```java
@Bean
public OldDataSource oldDataSource() {  // dead if never injected
```

---

### Go

**Unused imports:**
```go
import (
    "fmt"       // dead if fmt.* never called in file
    "strings"   // dead if strings.* never called
)
```
Go compiler catches this — but cross-package unused exports are not caught.

**Unused exported functions (packages):**
```go
// package utils
func FormatLegacyResponse(data interface{}) string {  // dead if no other package imports it
```
Check: `grep -r "utils.FormatLegacyResponse" .`

**Unused unexported functions:**
```go
func formatInternal(s string) string {  // dead if never called in this package
```

**Unreachable code:**
```go
func getUser(id int) *User {
    return db.First(id)
    log.Printf("fetched")  // dead — after return
}
```

**Unused struct fields:**
```go
type Config struct {
    OldTimeout int    `json:"old_timeout"` // dead if never accessed
}
```

**Unused HTTP handlers:**
```go
func LegacyReportHandler(w http.ResponseWriter, r *http.Request) {
    // dead if never passed to router.HandleFunc or gin.GET
}
```
Check: `grep -r "LegacyReportHandler" .` — only definition should appear.

---

### JavaScript / TypeScript

**Unused imports:**
```ts
import { formatDate } from './utils';     // dead if formatDate never used
import type { OldConfig } from './types'; // dead if OldConfig never in type position
```

**Unused exported functions:**
```ts
export function formatLegacyResponse(data: any) {  // dead if no importer uses it
```
Check: `grep -r "formatLegacyResponse" src/`

**Unused React components:**
```tsx
export const LegacyWidget = () => <div />;  // dead if never rendered
```
Check: `grep -r "LegacyWidget" src/`

**Unused NestJS providers / controllers:**
```ts
@Injectable()
export class LegacyService {   // dead if not in any module's providers array
```

**Unreachable code:**
```ts
function getUser(id: string) {
    return db.findOne(id);
    console.log("done");  // dead — after return
}
```

**Unused interface / type:**
```ts
interface OldUserPayload {   // dead if never used in type positions or extends
    legacyId: string;
}
```

**Dead Express / Fastify routes:**
```ts
router.get('/v1/legacy/report', handler);  // dead if router never mounted
app.get('/legacy', handler);               // dead if never documented or tested
```

---

### React

**Unused components:**
```tsx
// components/LegacyBanner.tsx
export const LegacyBanner = () => <div>...</div>;
// dead if <LegacyBanner /> never appears in any .tsx/.jsx file
```
Check: `grep -r "LegacyBanner" src/` — only definition and export should appear.

**Unused props:**
```tsx
interface CardProps {
  title: string;
  subtitle: string;   // dead if never read inside Card body
  legacyId: string;   // dead if never destructured or accessed
}
export const Card = ({ title }: CardProps) => <h1>{title}</h1>;
```

**Unused custom hooks:**
```tsx
// hooks/useLegacyData.ts
export function useLegacyData() { ... }
// dead if never called as useLegacyData() in any component
```
Check: `grep -r "useLegacyData" src/`

**Unused context:**
```tsx
export const LegacyContext = createContext(null);
// dead if <LegacyContext.Provider> never rendered AND useContext(LegacyContext) never called
```

**Unused Redux actions / selectors:**
```ts
// store/legacySlice.ts
export const selectLegacyData = (state) => state.legacy.data;  // dead if never used in useSelector
export const { setLegacyData } = legacySlice.actions;          // dead if never dispatched
```

**Dead Next.js pages (Pages Router):**
```
pages/legacy-report.tsx   // dead if no <Link href="/legacy-report"> and no direct navigation
```
Check: `grep -r "legacy-report" src/` and check `_app.tsx` nav links.

**Dead Next.js routes (App Router):**
```
app/legacy/page.tsx       // dead if no Link, redirect, or navigation points to /legacy
```

**Unused `useEffect` with empty deps:**
```tsx
useEffect(() => {
  legacySync();
}, []);
// flag if legacySync is itself dead code
```

---

### Vue.js

**Unused components:**
```vue
<!-- components/LegacyCard.vue -->
<script setup>
// dead if <LegacyCard /> never appears in any .vue template
</script>
```
Check: `grep -r "LegacyCard" src/`

**Unused props:**
```vue
<script setup>
const props = defineProps<{
  title: string;
  legacyId: string;  // dead if props.legacyId never accessed in template or script
}>();
</script>
```

**Unused computed properties:**
```vue
<script setup>
const legacyLabel = computed(() => `${props.title} (legacy)`);
// dead if legacyLabel never used in template or returned
</script>
```

**Unused emits:**
```vue
<script setup>
const emit = defineEmits(['legacy-click', 'submit']);
// 'legacy-click' is dead if emit('legacy-click') never called
</script>
```

**Unused Pinia store:**
```ts
// stores/legacyStore.ts
export const useLegacyStore = defineStore('legacy', () => { ... });
// dead if useLegacyStore() never called in any component
```
Check: `grep -r "useLegacyStore" src/`

**Dead Nuxt.js pages:**
```
pages/legacy.vue   // dead if no NuxtLink to /legacy and not in nav
```

---

### Angular

**Unused components:**
```ts
@Component({ selector: 'app-legacy-banner', ... })
export class LegacyBannerComponent { }
// dead if <app-legacy-banner> never used in any template
// AND never in any module's declarations + exports
```

**Unused services:**
```ts
@Injectable({ providedIn: 'root' })
export class LegacyDataService { }
// dead if never injected via constructor(private svc: LegacyDataService)
```
Check: `grep -r "LegacyDataService" src/`

**Unused pipes:**
```ts
@Pipe({ name: 'legacyFormat' })
export class LegacyFormatPipe { }
// dead if | legacyFormat never appears in any template
```
Check: `grep -r "legacyFormat" src/`

**Unused directives:**
```ts
@Directive({ selector: '[appLegacyHighlight]' })
export class LegacyHighlightDirective { }
// dead if appLegacyHighlight never appears in any template
```

**Unused NgModule imports:**
```ts
@NgModule({
  imports: [LegacyModule, SharedModule]  // LegacyModule dead if no component from it is used
})
```

**Unused `@Input()` / `@Output()`:**
```ts
@Input() legacyId: string;             // dead if never passed from parent template
@Output() legacyClick = new EventEmitter();  // dead if (legacyClick) never bound in template
```

---

### CSS / SCSS / Less

**Unused class selectors:**
```css
.legacy-banner { color: red; }   /* dead if .legacy-banner never in any HTML/JSX/template */
.old-card__title { ... }         /* dead if BEM block removed */
```
Check: `grep -r "legacy-banner" src/`

**Unused SCSS variables:**
```scss
$legacy-color: #ff0000;   // dead if $legacy-color never referenced in this or any @use file
$old-spacing: 12px;       // dead if never used
```

**Unused SCSS mixins:**
```scss
@mixin legacy-shadow() { ... }   // dead if @include legacy-shadow never called
```

**Unused CSS custom properties (variables):**
```css
:root {
  --legacy-primary: #123456;   /* dead if var(--legacy-primary) never referenced */
}
```

**Unused @keyframes:**
```css
@keyframes legacyFadeIn { ... }   /* dead if animation: legacyFadeIn never used */
```

**Unused media query breakpoints (SCSS):**
```scss
$breakpoint-legacy: 480px;   // dead if never used in @media queries
```

**Tailwind — unused custom utilities in `tailwind.config`:**
```js
// tailwind.config.js
theme: {
  extend: {
    colors: {
      'legacy-brand': '#ff0000',  // dead if text-legacy-brand / bg-legacy-brand never in templates
    }
  }
}
```
Check: `grep -r "legacy-brand" src/`

---

### Ruby (Rails)

**Unused methods:**
```ruby
def format_legacy_response(data)  # dead if no callers
  data.to_json
end
```

**Unused routes:**
```ruby
# routes.rb
get '/legacy/report', to: 'legacy#report'  # dead if controller action removed
resources :old_payments                     # dead if OldPaymentsController removed
```

**Unused ActiveRecord scopes:**
```ruby
scope :legacy_active, -> { where(type: 'LEGACY') }  # dead if never called
```

**Dead gems in Gemfile:**
```ruby
gem 'legacy_pdf_gen'  # dead if never required in code
```

---

### PHP (Laravel)

**Unused use statements:**
```php
use App\Services\LegacyPaymentService;  // dead if never instantiated or injected
use Illuminate\Support\Facades\Cache;   // dead if Cache:: never called
```

**Unused routes:**
```php
Route::get('/legacy/report', [LegacyController::class, 'report']);
// dead if LegacyController or report() method removed
```

**Unused service providers:**
```php
// config/app.php
App\Providers\LegacyServiceProvider::class,  // dead if provider does nothing
```

**Unused Artisan commands:**
```php
class GenerateLegacyReport extends Command {  // dead if not in $commands or scheduler
```

---

### C# (.NET)

**Unused using directives:**
```csharp
using System.Collections.Generic;  // dead if no List<T>/Dictionary/etc used
using OldNamespace.Legacy;         // dead if no types from it used
```

**Unused private methods:**
```csharp
private string FormatLegacy(string input)  // dead if no callers in class
```

**Unused fields:**
```csharp
private readonly string _oldApiUrl = "...";  // dead if never read
```

**Dead API endpoints:**
```csharp
[HttpGet("legacy/report")]
public IActionResult GetLegacyReport()  // dead if no client calls it
```

---

## Step 3 — Framework-Specific Dead Code

### Django / DRF
- View class not referenced in any `urls.py`
- URL pattern pointing to a non-existent view
- Cerberus schema dict defined but not used in any view
- `@receiver` signal never sent anywhere in the project
- Management command never called in CI, cron, or docs
- Middleware class that always calls `get_response` with no logic

### Spring Boot (Java)
- `@Service` / `@Component` / `@Repository` never `@Autowired` or constructor-injected
- `@Bean` in a `@Configuration` class never injected
- `@EventListener` for an event type never published
- `@Scheduled` method whose cron is disabled or task removed from config
- `@RestController` endpoint path that was versioned out (`/v1/` replaced by `/v2/`) but old version never removed

### NestJS (TypeScript)
- `@Injectable()` service not in any module's `providers` array
- `@Controller()` not in any module's `controllers` array
- DTO class defined but never used as a parameter type in any controller
- Guard / interceptor / pipe defined but never applied globally or per-route

### React / Next.js
- Component exported but `<ComponentName />` never appears in any `.tsx`/`.jsx`
- Custom hook exported but `useHookName()` never called in any component
- Context created but `<Context.Provider>` never rendered or `useContext(Context)` never called
- Redux action exported but never dispatched; selector never used in `useSelector`
- Next.js page in `pages/` with no `<Link href>`, redirect, or direct navigation pointing to it
- Next.js App Router page in `app/` with no `Link`, `redirect()`, or `router.push()` to its path
- `useEffect` whose only call is to a dead function

### Vue.js / Nuxt.js
- `.vue` component never imported in any other `.vue` or registered in any plugin/router
- `defineProps` field never accessed in template or script body
- `computed` property defined but never referenced in template or returned
- `emit` event name never called via `emit('name')`
- Pinia store never called via `useStoreName()` in any component
- Nuxt page in `pages/` with no `NuxtLink` or `navigateTo` pointing to its path

### Angular
- `@Component` selector never in any template as `<app-selector>`
- `@Injectable` service never constructor-injected
- `@Pipe` name never used as `| pipeName` in any template
- `@Directive` selector never applied in any template
- `@Input()` property never bound from parent template
- `@Output()` emitter never subscribed from parent template
- `NgModule` imports array entry whose exported components/directives/pipes are never used

### CSS / SCSS / Tailwind
- Class selector never referenced in any template, JSX, or HTML
- SCSS variable (`$name`) never interpolated or used in value
- SCSS mixin (`@mixin`) never `@include`d
- CSS custom property (`--name`) never referenced via `var(--name)`
- `@keyframes` name never used in `animation:` or `animation-name:`
- Tailwind custom color/spacing/font key never referenced in a utility class in templates

### Celery (Python) / Sidekiq (Ruby) / Bull (Node)
- Task decorated with `@shared_task` / `@app.task` never called via `.delay()`, `.apply_async()`, or `perform_async`
- Beat schedule entry pointing to a task path that was deleted
- Worker queue defined but no tasks ever enqueue to it

### Go (Gin / Echo)
- Handler never passed to `router.GET/POST/PUT/DELETE`
- Middleware function never passed to `router.Use()` or group-level `Use()`
- Exported package function never imported by any other package in the project

---

## Step 4 — Config & Environment Dead Code (All Languages)

### Strategy
1. Collect all env var reads from code:
   - Python: `os.environ.get('KEY')`, `os.getenv('KEY')`, `config('KEY')`, `Settings.KEY`
   - Java: `System.getenv("KEY")`, `@Value("${KEY}")`
   - Go: `os.Getenv("KEY")`
   - Node: `process.env.KEY`
   - Ruby: `ENV['KEY']`
   - PHP: `env('KEY')`, `$_ENV['KEY']`
   - C#: `Environment.GetEnvironmentVariable("KEY")`, `Configuration["KEY"]`

2. Collect all keys defined in: `.env`, `.env.example`, `application.yml`, `application.properties`, `config/environments/*.rb`, `appsettings.json`

3. Report:
   - Key in config but never read in code → candidate for removal
   - Key read in code but not in config → missing / undocumented
   - Key only referenced in commented-out code → stale

---

## Step 5 — Verify Before Flagging

Before marking anything dead, verify across the whole project:

1. **Search all files** — not just the current file
2. **Dynamic dispatch** — `getattr(obj, fn_name)`, `importlib.import_module`, `eval`, string-based task names, `reflect.Value`
3. **Framework auto-registration** — decorators, `INSTALLED_APPS`, module providers arrays, `routes.rb`, `RouteServiceProvider`
4. **Test files** — code only called in tests is NOT dead
5. **External consumers** — exported/public symbols may be called by other services
6. **CI / scripts / Makefiles** — shell-level callers

---

## Step 6 — Output Format

Summary table first, then full finding blocks with solutions.

### Summary table
```
## Dead Code Report

Project: {name}
Language: {language + framework}
Files scanned: {N}

| Category            | Count | Lines Removable | Action       |
|---------------------|-------|-----------------|--------------|
| Unused imports      | {N}   | {N}             | Safe now     |
| Unused functions    | {N}   | ~{N}            | Verify first |
| Unused endpoints    | {N}   | ~{N}            | Coordinate   |
| Unreachable code    | {N}   | {N}             | Safe now     |
| Unused env vars     | {N}   | {N}             | Coordinate   |
| Commented-out code  | {N}   | ~{N}            | Safe now     |
| Total               | {N}   | ~{N} lines      |              |
```

### Per-finding block (required for every item)

```
---
### Finding #N — [CATEGORY] · Confidence: {HIGH | MEDIUM | LOW}
**{Title}**
`{file}:{line}`
**Action**: {Safe now | Verify first | Needs coordination}

**Confidence explanation**
{Why this confidence — what was confirmed, what is uncertain}

**Why it's dead**
{One sentence: no callers found / after return / never imported / etc.}

**Verify**
```bash
{exact grep / search command to confirm zero usages}
```

**Solution — remove these lines**
```{language}
# REMOVE lines {X}–{Y}:
{exact code to delete}
```

**After removal** _(optional — show when nearby code needs adjustment)_
```{language}
{what the file looks like after the fix}
```
```

### Action levels

| Action | When | What to do |
|--------|------|-----------|
| **Safe now** | No risk | Delete immediately |
| **Verify first** | Possible dynamic usage | Run the verify grep, confirm 0 hits, then delete |
| **Needs coordination** | External consumers or migration required | Flag for team |