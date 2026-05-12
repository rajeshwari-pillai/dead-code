---
description: Find all unused imports, using statements, require calls, and use declarations across any language. Provides exact lines to delete with confidence levels.
---

Find all unused imports in: $ARGUMENTS

## What counts as an unused import (per language)

**Python**
```python
import json                           # unused if `json.` never called in file
from datetime import timedelta        # unused if `timedelta` never referenced
from typing import Optional, List     # each symbol checked independently
from sqlalchemy.sql import func, case # `case` unused if never called
```
Exceptions: `__all__` re-exports, `TYPE_CHECKING` guarded imports, `__init__.py` public API.

**Java**
```java
import java.util.ArrayList;           // unused if ArrayList never used
import org.springframework.stereotype.Service;  // unused if @Service never applied
import com.example.OldRepository;     // unused if OldRepository never referenced
```

**Go**
```go
import (
    "fmt"       // unused if fmt.Println / fmt.Sprintf etc never called
    "strings"   // unused if strings.* never called
    "log"       // unused if log.* never called
)
```
Note: Go compiler already catches unused imports — but this command finds them before compilation and also catches cross-package unused exports.

**TypeScript / JavaScript**
```ts
import { formatDate } from './utils';       // unused if formatDate never called
import type { OldConfig } from './types';   // unused if OldConfig never in type position
import React from 'react';                 // check if JSX present before flagging
const { something } = require('./lib');    // unused if something never used
```

**Ruby**
```ruby
require 'json'                   # unused if JSON never called
require_relative '../old_helper' # unused if nothing from it used
```

**PHP**
```php
use App\Services\LegacyService;         // unused if never instantiated or type-hinted
use Illuminate\Support\Facades\Cache;   // unused if Cache:: never called
```

**C#**
```csharp
using System.Collections.Generic;  // unused if List<T>/Dictionary etc never used
using OldNamespace.Legacy;         // unused if no types from it used
```

## Step 1 — Scan every file in the target

For each file:
1. Extract all import/using/use/require statements with line numbers
2. For each imported symbol, search the rest of the file body for any reference
3. If zero references found → flag as unused

## Step 2 — Check for exceptions before flagging

Do NOT flag:
- `__all__` re-exports in Python `__init__.py`
- `import 'side-effect-only'` (no binding) in JS/TS
- `import _ "pkg"` blank identifier imports in Go (side effects)
- Type-only imports used only in generic constraints (TS)
- Java wildcard imports if any class from the package is used

## Step 3 — Output

### Summary table
```
## Unused Imports Report — {target}

Language: {language}
Files scanned: {N}
Unused imports found: {N}
Estimated lines removable: {N}

| File | Line | Import | Symbol | Safe to Remove? |
|------|------|--------|--------|----------------|
```

### Per-finding block

```
---
### Import #N — Confidence: {HIGH | MEDIUM | LOW}
**Unused: `{import statement}`**
`{file}:{line}`
**Action**: Safe now

**Confidence explanation**
{e.g. "Searched entire file — `timedelta` appears 0 times outside import line"}

**Why it's dead**
{Symbol never referenced / only appears in the import line}

**Verify**
```bash
grep -n "{symbol}" {file}   # should return only line {N} (the import itself)
```

**Solution — delete this line**
```{language}
# DELETE line {N}:
{exact import line}
```

**After removal** _(show when removing changes adjacent import block)_
```{language}
# Lines {X}–{Y} after fix:
{remaining imports}
```
```

### Confidence levels for imports

**HIGH** — searched file, symbol never appears outside import:
- `import json` and `json` appears 0 times in rest of file
- `from sqlalchemy.sql import case` and `case(` appears 0 times

**MEDIUM** — symbol might be used dynamically:
- Symbol name is a common English word (e.g. `List`, `Map`) — grep may miss dynamic usage
- Import is a type used only in string annotations (`"Optional[str]"`)
- Java import from a framework package — might be used via annotation processor

**LOW** — structural exception possible:
- Import in `__init__.py` — may be a public API re-export
- Wildcard import in Java (`import com.example.*`) — cannot confirm all usages
- `import type` in TypeScript — may be needed for `declare module` augmentation