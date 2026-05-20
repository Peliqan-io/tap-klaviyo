# tap-klaviyo — Python 3.11 Regression Tests

Before/after parity test for the Python 3.9 → 3.11 migration.

## Strategy

1. **Capture** baseline on pre-migration `master` + Python 3.9 — discover, select target streams, sync, record schemas / state-key names / record field names.
2. **Compare** on migration branch + Python 3.11 — assert schemas unchanged, no streams dropped, all baseline fields still present.

## Files

| File | Purpose |
| --- | --- |
| `conftest.py` | Config builder, catalog filtering, sync runner, message parser |
| `capture.py` | Standalone — run once on Python 3.9 to write `baseline/` |
| `test_regression.py` | pytest suite — run on Python 3.11 |
| `run_capture.sh` / `run_tests.sh` | Docker wrappers (`python:3.9-slim` / `python:3.11-slim`) |
| `baseline/` | Committed reference output |

## Usage

Required env vars:

```bash
export TAP_KLAVIYO_API_KEY=pk_...                              # Klaviyo Private API key
export TAP_KLAVIYO_INCLUDE_STREAMS=lists,global_exclusions     # comma-separated, default
export TAP_KLAVIYO_START_DATE=2024-01-01T00:00:00Z             # optional
```

### Capture baseline (pre-migration code on Python 3.9)

```bash
git worktree add /tmp/tap-klaviyo-master master
cp -r tests/regression /tmp/tap-klaviyo-master/tests/regression
cd /tmp/tap-klaviyo-master
bash tests/regression/run_capture.sh
cp -r tests/regression/baseline /path/to/migration-branch/tests/regression/
git worktree remove --force /tmp/tap-klaviyo-master
```

### Run tests (migration branch on Python 3.11)

```bash
bash tests/regression/run_tests.sh
```

## Notes

- The CHANGELOG entry for v1.0.0 already notes "Updates for python 3.11.7" — this regression test confirms it.
- `lists` and `global_exclusions` are both `FULL_TABLE` streams, so no STATE messages are emitted (state-keys test is `skipped`, which is expected).
- For broader coverage of incremental streams, extend `TAP_KLAVIYO_INCLUDE_STREAMS` to include `events`, `campaigns`, etc. — note that incremental streams require a populated Klaviyo account.
