---
description: Find all unused or orphaned API endpoints and routes across Django, Spring Boot, FastAPI, Express, NestJS, Rails, Laravel, ASP.NET. Provides removal steps with confidence levels.
---

Find all unused API endpoints in: $ARGUMENTS

## Step 1 — Collect all route definitions

Scan for every registered route across all frameworks:

**Django REST Framework:**
```python
# urls.py
path('v1/payments/', PaymentView.as_view()),
re_path(r'^v1/legacy/', LegacyView.as_view()),
router.register(r'forms', FormViewSet)
```

**FastAPI / Flask:**
```python
@app.route('/v1/payments', methods=['GET'])
@router.get('/v1/payments')
@router.post('/v1/forms/{form_id}')
```

**Spring Boot (Java):**
```java
@GetMapping("/v1/payments")
@PostMapping("/v1/forms/{formId}")
@RequestMapping("/v1/legacy")
```

**Express / Fastify (Node):**
```js
router.get('/v1/payments', handler)
app.post('/v1/forms/:id', handler)
fastify.get('/v1/reports', handler)
```

**NestJS (TypeScript):**
```ts
@Get('payments')
@Post('forms/:id')
@Controller('v1/legacy')
```

**Rails:**
```ruby
get '/v1/payments', to: 'payments#index'
resources :forms
namespace :v1 do
  resources :payments
end
```

**Laravel:**
```php
Route::get('/v1/payments', [PaymentController::class, 'index']);
Route::apiResource('forms', FormController::class);
```

**ASP.NET Core:**
```csharp
[HttpGet("v1/payments")]
[Route("v1/legacy/report")]
app.MapGet("/v1/payments", handler);
```

## Step 2 — Check each endpoint for usage

For each route, check:
1. **Does the handler/view exist?** — is the referenced class/function still defined?
2. **Is it called anywhere?** — search for the path string in: frontend code, other backend services, API clients, tests, docs, Postman/Swagger files
3. **Is it versioned out?** — does a v2 or v3 version of the same path exist? Is the v1 still needed?
4. **Is it documented?** — does it appear in OpenAPI spec, README, or API docs?
5. **Is it tested?** — does any test call this endpoint path?

Flag as dead if:
- Handler/view class no longer exists (broken route)
- Path string appears nowhere outside the route definition
- Version is superseded and old version has no callers

## Step 3 — Output

### Summary
```
## Unused Endpoints Report — {target}

Framework: {framework}
Total routes found: {N}
Potentially unused: {N}
Broken (handler missing): {N}

| # | Confidence | Method | Path | Handler | Issue | Action |
|---|-----------|--------|------|---------|-------|--------|
```

### Per-finding block

```
---
### Endpoint #N — Confidence: {HIGH | MEDIUM | LOW}
**{METHOD} {path} → {handler}**
`{routes_file}:{line}`
**Action**: {Safe now | Verify first | Needs coordination}

**Confidence explanation**
{What was searched — frontend code, tests, other services, API docs}

**Issue**
{Handler missing / path never called in tests or frontend / versioned out}

**Verify**
```bash
# Search all code for this path
grep -rn "{path}" . --include="*.{py,ts,js,java,rb,php}"
grep -rn "{path}" . --include="*.{json,yaml,yml}"   # API docs, Postman collections
```

**Solution — remove these entries**
```{language}
# In {routes_file}, DELETE:
{exact route registration line(s)}

# Also delete the handler:
# {handler_file}:{start_line}–{end_line} — {HandlerClass or function}
```

**Note** _(if other files reference this)_
{e.g. "also remove from frontend API client at src/api/client.ts:88"}
```

### Confidence levels for endpoints

**HIGH** — confirmed dead:
- Handler class/function no longer exists (broken route — definitely remove)
- Path string found nowhere in frontend, tests, or other services
- Endpoint is an old version (`/v1/`) and a newer version (`/v2/`) handles all traffic

**MEDIUM** — likely dead but external callers possible:
- Path not found in this repo's code, but external services may call it
- Path only appears in commented-out test code
- Endpoint was recently versioned out — old clients may still use it

**LOW** — usage uncertain:
- Path is short and generic (`/status`, `/health`) — external monitoring may call it
- No access logs available to confirm zero traffic
- Endpoint is part of a third-party integration (webhook receiver, OAuth callback)