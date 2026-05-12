---
description: Find all unreachable code blocks (statements after return/throw/raise/panic/exit) and dead conditional branches across Python, Java, Go, TypeScript, Ruby, PHP, C#. Provides exact deletion blocks with confidence levels.
---

Find all unreachable code in: $ARGUMENTS

## What counts as unreachable

### After a terminal statement

Any statement that can never execute because a terminal statement always runs first:

**Python:**
```python
def get_user(id):
    return db.query(User).get(id)
    logger.info("fetched user")     # unreachable — after return
    raise ValueError("not found")  # unreachable — after return
```

**Java:**
```java
public String getStatus() {
    return "active";
    logger.info("returned");  // unreachable — after return
}

public void process() {
    throw new RuntimeException("not implemented");
    cleanup();  // unreachable — after throw
}
```

**Go:**
```go
func getUser(id int) *User {
    return db.First(id)
    log.Printf("fetched")  // unreachable — after return
}

func validate(s string) {
    panic("not implemented")
    cleanup()  // unreachable — after panic
}
```

**TypeScript / JavaScript:**
```ts
function getUser(id: string) {
    return db.findOne(id);
    console.log("done");     // unreachable — after return
}

function validate(s: string): never {
    throw new Error("invalid");
    cleanup();  // unreachable — after throw
}
```

**Ruby:**
```ruby
def get_user(id)
    return User.find(id)
    puts "fetched"  # unreachable — after return
end
```

**PHP:**
```php
function getUser($id) {
    return User::find($id);
    echo "fetched";  // unreachable — after return
}
```

**C#:**
```csharp
public User GetUser(int id) {
    return _db.Users.Find(id);
    _logger.Log("done");  // unreachable — after return
}
```

### Dead conditional branches

```python
# Python — always-false condition
if False:
    do_something()   # unreachable

# Always-true condition makes else dead
if True:
    return value
else:
    do_other()       # unreachable

# Constant comparison
VERSION = "v2"
if VERSION == "v1":
    use_legacy()     # unreachable — VERSION is always "v2"
```

```java
// Java
if (false) {
    doSomething();   // unreachable
}

// Constant string comparison
static final String VERSION = "v2";
if (VERSION.equals("v1")) {
    useLegacy();     // unreachable
}
```

```go
// Go — build tag controlled
const IsLegacy = false
if IsLegacy {
    useLegacy()      // unreachable at runtime
}
```

### Empty catch / exception swallowing after unreachable

```python
try:
    return result
except Exception:
    pass   # never reached if return always succeeds
```

```java
try {
    return result;
} catch (Exception e) {
    // never reached
}
```

## Step 1 — Scan every function

For each function/method in the target:
1. Find the first terminal statement (`return`, `raise`, `throw`, `panic`, `exit`, `os.Exit`)
2. Flag any statement after it on the same scope level
3. Check conditional branches for constant conditions

## Step 2 — Output

### Summary
```
## Unreachable Code Report — {target}

Language: {language}
Functions scanned: {N}
Unreachable blocks found: {N}
Lines removable: {N}

| # | Confidence | Type | File | Lines | Reason |
|---|-----------|------|------|-------|--------|
```

### Per-finding block

```
---
### Finding #N — [UNREACHABLE] · Confidence: {HIGH | MEDIUM | LOW}
**Dead code after `{return | throw | raise | panic}` in `{function_name}`**
`{file}:{line_range}`
**Action**: Safe now

**Confidence explanation**
{Structural — the terminal statement on line X makes all code after it unreachable / Conditional — VALUE is a constant defined at line Y}

**Why it's dead**
{`return` on line {X} always executes before line {Y}}

**Current code** _(full function for context)_
```{language}
{function body — mark the terminal statement and the dead lines}
```

**Solution — delete dead lines**
```{language}
# DELETE lines {X}–{Y} in {file}:
{exact lines to remove}
```

**After removal**
```{language}
{function body after deletion — should be clean}
```
```

### Confidence levels for unreachable code

**HIGH** — structurally unreachable (no runtime dependency):
- Code is on the line immediately after `return` / `throw` / `raise` / `panic`
- The terminal statement is unconditional (not inside an `if`)
- Constant condition is a literal `True`/`False` or `true`/`false`

**MEDIUM** — reachable in some code paths not obvious from this file:
- Terminal statement is inside an `if` block that appears always-true from imports
- Constant value is defined in another file — may be overridden in tests

**LOW** — possible edge case:
- Dead code is inside a `finally` block — may be reachable from certain exception paths
- Language has unusual control flow (generators, coroutines, metaclasses)
- Constant is set by a decorator or metaprogramming at runtime