---
description: Find unused environment variables and config keys across Python, Java, Go, Node, Ruby, PHP, C#. Cross-checks code references against .env.example, application.yml, appsettings.json. Provides removal steps with confidence levels.
---

Find unused environment variables and config keys in: $ARGUMENTS

## Step 1 — Collect all config key definitions

Search for keys defined in config files:

**Python / Django:**
```python
# settings.py
OLD_PAYMENT_URL = os.environ.get('OLD_PAYMENT_URL')
LEGACY_SECRET = config('LEGACY_SECRET')
```
```
# .env / .env.example
OLD_PAYMENT_URL=https://old-payments.example.com
LEGACY_SECRET=abc123
```

**Java / Spring:**
```yaml
# application.yml
legacy:
  payment-url: ${LEGACY_PAYMENT_URL}
  secret: ${LEGACY_SECRET}
```
```properties
# application.properties
legacy.payment-url=${LEGACY_PAYMENT_URL}
```

**Go:**
```go
os.Getenv("LEGACY_PAYMENT_URL")
viper.GetString("legacy_payment_url")
```
```
# .env
LEGACY_PAYMENT_URL=...
```

**Node / TypeScript:**
```ts
process.env.LEGACY_PAYMENT_URL
config.get('LEGACY_PAYMENT_URL')
```
```
# .env
LEGACY_PAYMENT_URL=...
```

**Ruby / Rails:**
```ruby
ENV['LEGACY_PAYMENT_URL']
Rails.application.credentials.legacy_secret
```
```
# .env (dotenv gem)
LEGACY_PAYMENT_URL=...
```

**PHP / Laravel:**
```php
env('LEGACY_PAYMENT_URL')
config('services.legacy.url')
$_ENV['LEGACY_PAYMENT_URL']
```
```
# .env
LEGACY_PAYMENT_URL=...
```

**C# / .NET:**
```csharp
Environment.GetEnvironmentVariable("LEGACY_PAYMENT_URL")
Configuration["Legacy:PaymentUrl"]
_config.GetValue<string>("LEGACY_PAYMENT_URL")
```
```json
// appsettings.json
{
  "Legacy": {
    "PaymentUrl": ""
  }
}
```

## Step 2 — Collect all code references

For each key found in config files, search the entire codebase:

```bash
# Python
grep -rn "LEGACY_PAYMENT_URL\|legacy_payment_url" . --include="*.py"

# Java
grep -rn "LEGACY_PAYMENT_URL\|legacy.payment-url" . --include="*.{java,kt,yml,properties}"

# Go
grep -rn "LEGACY_PAYMENT_URL" . --include="*.go"

# Node
grep -rn "LEGACY_PAYMENT_URL" . --include="*.{ts,js}"

# Ruby
grep -rn "LEGACY_PAYMENT_URL" . --include="*.rb"
```

## Step 3 — Classify each key

| Status | Condition | Action |
|--------|-----------|--------|
| **Dead** | Defined in config, 0 references in code | Remove from config |
| **Missing** | Referenced in code, not in config | Add to `.env.example` / document |
| **Stale** | Only referenced in commented-out code | Remove from config + code |
| **Duplicate** | Same value defined under two different key names | Consolidate |

## Step 4 — Output

### Summary
```
## Environment / Config Key Audit — {target}

Language: {language + framework}
Config files scanned: {list}
Keys defined: {N}
Keys referenced in code: {N}

| Status    | Count |
|-----------|-------|
| Dead      | {N}   |
| Missing   | {N}   |
| Stale     | {N}   |
| Duplicate | {N}   |
| Healthy   | {N}   |
```

### Per-finding block

```
---
### Key #N — [{STATUS: Dead | Missing | Stale | Duplicate}] · Confidence: {HIGH | MEDIUM | LOW}
**`{KEY_NAME}`**
**Action**: Needs coordination

**Confidence explanation**
{Searched all source files, config files, and deployment scripts — found N references}

**Why it's dead / missing / stale**
{Defined in .env.example but grep returns 0 code references / etc.}

**Verify**
```bash
grep -rn "{KEY_NAME}" . --include="*.{py,java,go,ts,js,rb,php,cs}"
grep -rn "{KEY_NAME}" . --include="*.{yml,yaml,json,properties,env}"
grep -rn "{KEY_NAME}" .github/ Makefile deploy/ scripts/ 2>/dev/null
```

**Solution**

For **Dead** keys — remove from all config files:
```bash
# Files to update:
# 1. .env.example — DELETE: {KEY_NAME}=...
# 2. {settings_file}:{line} — DELETE: {KEY_NAME} = os.environ.get('{KEY_NAME}')
# 3. Deployment config / CI secrets — remove from {CI_FILE} if present
```

For **Missing** keys — add to config:
```bash
# Add to .env.example:
{KEY_NAME}=    # {description of what this key does}

# Also document in: {relevant README or deployment doc}
```

For **Stale** keys — remove code reference + config:
```{language}
# In {file}:{line} — DELETE commented reference:
# old_url = settings.{KEY_NAME}   ← delete this line

# In .env.example — DELETE:
{KEY_NAME}=...
```

For **Duplicate** keys — consolidate:
```{language}
# Keep: {KEY_TO_KEEP}
# Remove: {KEY_TO_REMOVE} — replace all usages with {KEY_TO_KEEP}
```
```

### Confidence levels for env vars

**HIGH** — searched all source files + config files + CI/CD + scripts, 0 references:
- Key in `.env.example` but grep across all files returns 0 hits
- Key only appears in a commented-out line

**MEDIUM** — likely dead but deployment pipeline uncertain:
- Key not in source code but may be used in Docker/K8s config not in this repo
- Key referenced in a file that was recently deleted (check git log)

**LOW** — external usage possible:
- Key may be read by a sidecar, init container, or external deployment script
- Key name is generic (`SECRET_KEY`, `DATABASE_URL`) — could be used by framework internals
- Key was recently added — may be intentionally unused during rollout