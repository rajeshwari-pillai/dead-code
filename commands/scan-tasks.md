---
description: Find unused background tasks across Celery (Python), Sidekiq (Ruby), Bull/BullMQ (Node), Quartz (Java), and Go goroutine workers. Detects orphaned beat/cron schedule entries too. Provides removal steps with confidence levels.
---

Find all unused background tasks in: $ARGUMENTS

## Step 1 — Detect task system

Identify which task/job system is in use:

| Signal | System |
|--------|--------|
| `@shared_task` / `@app.task` / `celery` import | Celery (Python) |
| `include Sidekiq::Worker` / `perform_async` | Sidekiq (Ruby) |
| `Queue` / `Worker` from `bull` or `bullmq` | Bull / BullMQ (Node) |
| `@Job` / `implements Job` / `Quartz` | Quartz (Java) |
| `@Scheduled` / `ScheduledExecutorService` | Spring Scheduler (Java) |
| `cron.New()` / `cron.AddFunc` | Go cron |
| `BackgroundService` / `IHostedService` | .NET Background Service |

## Step 2 — Collect all task definitions

**Celery (Python):**
```python
@shared_task
def send_payment_reminder(payment_id):  # collect name: "send_payment_reminder"

@app.task(name='payments.tasks.generate_report')
def generate_report():  # collect explicit name
```

**Sidekiq (Ruby):**
```ruby
class PaymentReminderWorker
    include Sidekiq::Worker
    def perform(payment_id)  # worker: PaymentReminderWorker
```

**Bull / BullMQ (Node):**
```ts
const paymentQueue = new Queue('payment-reminders');
worker = new Worker('payment-reminders', processor);
```

**Spring @Scheduled (Java):**
```java
@Scheduled(cron = "0 0 * * * *")
public void generateDailyReport() {  # collect method name
```

**Go cron:**
```go
c.AddFunc("@daily", generateReport)   // collect: generateReport
```

## Step 3 — Check each task for callers

For each task search the entire project:

**Celery:**
```bash
grep -rn "task_name.delay\|task_name.apply_async\|send_task.*task_name" . --include="*.py"
```
Also check beat schedule:
```python
CELERYBEAT_SCHEDULE = {
    'task-name': {
        'task': 'app.tasks.task_name',  # does this path still exist?
    }
}
```

**Sidekiq:**
```bash
grep -rn "WorkerName.perform_async\|WorkerName.perform_in\|WorkerName.perform_at" . --include="*.rb"
```

**Bull:**
```ts
paymentQueue.add('jobName', data)  // does this queue have a worker?
```

**Spring @Scheduled:**
- Always runs — check if the cron is disabled or if the method body is empty/commented

Flag as dead if:
- Task function exists but is never called via `.delay()`, `.apply_async()`, `perform_async`, `.add()`
- Beat/cron schedule entry points to a task path that no longer exists
- `@Scheduled` method body is empty or only logs "deprecated"
- Queue is defined but no producer ever enqueues to it

## Step 4 — Output

### Summary
```
## Unused Tasks Report — {target}

Task system: {Celery | Sidekiq | Bull | Quartz | Spring Scheduler | Go cron}
Tasks defined: {N}
Unused tasks: {N}
Orphaned schedule entries: {N}

| # | Confidence | Task name | Defined at | Last enqueued | Action |
|---|-----------|-----------|-----------|---------------|--------|
```

### Per-finding block

```
---
### Task #N — Confidence: {HIGH | MEDIUM | LOW}
**`{task_name}` — never enqueued**
`{file}:{line}`
**Action**: {Safe now | Verify first | Needs coordination}

**Confidence explanation**
{Searched project-wide for .delay() / perform_async / .add() calls — found N}

**Why it's dead**
{No enqueue calls found / beat schedule removed / method empty}

**Verify**
```bash
# Python/Celery
grep -rn "{task_name}" . --include="*.py" | grep -v "def {task_name}"

# Ruby/Sidekiq
grep -rn "{WorkerName}.perform" . --include="*.rb"

# Node/Bull
grep -rn "queue.add\|'{queue_name}'" . --include="*.{ts,js}"
```

**Solution — remove task definition**
```{language}
# DELETE in {file}, lines {start}–{end}:
{full task/worker function body}
```

**Also remove beat schedule entry** _(if applicable)_
```{language}
# In {settings_file}, DELETE:
'{task_key}': {
    'task': '{task_path}',
    ...
},
```

**Note** _(if imports reference this task)_
{e.g. "remove import in tasks/__init__.py:14"}
```

### Confidence levels for tasks

**HIGH** — confirmed no enqueue calls:
- Searched all files, `.delay()` / `perform_async` / `.add()` calls for this task = 0
- Beat schedule entry points to a non-existent task path (broken reference)
- `@Scheduled` method body is empty or only logs

**MEDIUM** — likely dead but dynamic dispatch possible:
- Task name constructed dynamically (`send_task(task_name_var)`)
- Called from a script or management command not in main source tree
- Beat schedule was recently removed but task code still exists

**LOW** — uncertain:
- Task is triggered by an external system via `send_task()` with a string name
- Task name follows a pattern that suggests it may be registered by a plugin
- New task added recently — may not have been wired up yet vs. truly orphaned