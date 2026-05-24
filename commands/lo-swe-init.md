---
name: "Lights Out SWE: Init"
description: "Scaffold the Lights Out SWE harness (copilot-instructions.md, preferences.md, scaffolding/, .gitignore) into the current repo."
agent: "agent"
---

Bootstrap the **Lights Out SWE** harness into the current repository. After this command runs, the user should be able to say "build me X" and the pipeline (EXPAND > DESIGN > ANALYZE > BUILD > REVIEW > RECONCILE > VERIFY > DEPLOY) will engage.

This command is the install-based equivalent of cloning [`RCSnyder/lights-out-swe`](https://github.com/RCSnyder/lights-out-swe) as a template.

## Preconditions

1. **Refuse if the harness is already installed.** If `.github/copilot-instructions.md` exists, stop. Print:

   > `.github/copilot-instructions.md` already exists. Delete it (and any other harness files you want refreshed) before re-running `/lo-swe-init`.

   Do **not** overwrite. Exit without making any changes.

## Steps

1. **Fetch canonical harness files** from `https://raw.githubusercontent.com/RCSnyder/lights-out-swe/main/`:
   - `.github/copilot-instructions.md` → write to `.github/copilot-instructions.md`
   - `preferences.md` → write to `preferences.md`
   - `README.md` → offer to write to `LIGHTS-OUT-SWE.md` (do **not** overwrite the user's own `README.md`). If `LIGHTS-OUT-SWE.md` also exists, skip it and note in the summary.

   If any fetch fails, abort and report which URL failed. Do not partially install.

2. **Create empty placeholders** (only if missing — never overwrite):
   - `scaffolding/.gitkeep` (empty file)
   - `docs/input/README.md` containing exactly:

     ```
     Drop client briefs, API specs, and reference materials here.
     ```

3. **Create `.gitignore`** only if no `.gitignore` already exists. Use the default block from the **First Commit** section of the just-fetched `.github/copilot-instructions.md`. If you cannot locate that section, fall back to a minimal sensible default that covers OS noise (`.DS_Store`), logs (`*.log`), and the user's chosen stack's standard ignores (node_modules, target/, **pycache**, etc.).

4. **Report a summary**. Print a table or list showing, for each file:
   - `written` — newly created by this command
   - `skipped (exists)` — left untouched
   - `failed` — fetch or write error

   Then tell the user:

   > Commit these files, then say "build me X" to start the pipeline. The first phase will be **EXPAND**, which writes `scaffolding/scope.md`.

## Verification

After running, confirm the following exist in the repository root:

- `.github/copilot-instructions.md`
- `preferences.md`
- `scaffolding/` (with at least `.gitkeep` inside)
- `docs/input/` (with `README.md` inside)
- `.gitignore` (either pre-existing or newly written)

If any are missing, report which ones and why. Do not silently succeed on a partial install.

## Notes

- This command writes user-project files only. It must never modify files under `agents/`, `skills/`, `commands/`, or `.claude-plugin/` (those are plugin-owned).
- The fetched `copilot-instructions.md`, `preferences.md`, and `LIGHTS-OUT-SWE.md` are the user's editable harness. Once written, the user owns them — re-running `/lo-swe-init` refuses by design.
