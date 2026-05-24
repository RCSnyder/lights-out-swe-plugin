---
name: init
description: Scaffold the Lights Out SWE harness (copilot-instructions.md, preferences.md, LIGHTS-OUT-SWE.md, scaffolding/, docs/input/, .gitignore) into the current repo. Run once to set up a new repository before starting the pipeline.
disable-model-invocation: true
---

Bootstrap the **Lights Out SWE** harness into the current repository. After this command runs, the user should be able to say "build me X" and the pipeline (EXPAND > DESIGN > ANALYZE > BUILD > REVIEW > RECONCILE > VERIFY > DEPLOY) will engage.

This skill ships a bundled `init.sh` script alongside a `templates/` directory containing the exact files a new project needs. There is **no network fetch** — every file copied is shipped with the plugin and matches the plugin's structure.

## Preconditions

1. **Refuse if the harness is already installed.** If `.github/copilot-instructions.md` exists in the workspace root, stop. Print:

   > `.github/copilot-instructions.md` already exists. Delete it (and any other harness files you want refreshed) before re-running `/lo-swe:init`.

   Do **not** overwrite. Exit without making any changes. (`init.sh` enforces this too — exit code `1`.)

## Steps

1. **Locate the script.** It lives next to this `SKILL.md`. The absolute path is the directory containing this file plus `/init.sh`.

2. **Run the script** in the workspace root:

   ```bash
   bash <absolute-path-to-skill-dir>/init.sh
   ```

   On Windows, run it from Git Bash (which is on PATH in this environment). Do not attempt to translate the script to PowerShell or `cmd` — the `.sh` is the source of truth.

   If the workspace is not the intended target, pass the target directory as the first argument:

   ```bash
   bash <absolute-path-to-skill-dir>/init.sh /path/to/target
   ```

3. **Read the script's output.** It reports, per file:
   - `+` written — newly created
   - `=` skipped — already existed, left untouched

   It also prints the next steps for the user.

4. **Surface the summary** to the user as a clean markdown list (one section for `written`, one for `skipped`), then tell them:

   > Commit these files, then say "build me X" to start the pipeline. The first phase will be **EXPAND**, which writes `scaffolding/scope.md`.

## Verification

After the script runs, confirm the following exist in the repository root:

- `.github/copilot-instructions.md`
- `preferences.md`
- `LIGHTS-OUT-SWE.md`
- `scaffolding/` (with at least `.gitkeep` inside)
- `docs/input/` (with `README.md` inside)
- `.gitignore`

If any are missing, report which ones and why. Do not silently succeed on a partial install.

## What gets installed

The `templates/` directory next to this skill contains the canonical set:

```
templates/
  .github/copilot-instructions.md   # pipeline loop + discipline rules (auto-loaded by Copilot)
  .gitignore                         # standard ignores for Python / Rust / Node / Go / IDE noise
  LIGHTS-OUT-SWE.md                  # user-facing guide to the harness
  preferences.md                     # stack + conventions (user customizes)
  docs/input/README.md               # placeholder explaining what goes in docs/input/
  scaffolding/.gitkeep               # keeps the empty scaffolding/ dir under git
```

These are the **only** files this skill writes into the user's repo. The plugin's agents, skills, and prompts (including the phase prompts like `/lo-swe:expand`) are provided by the plugin itself and do not get copied into the user's repo.

## Notes

- This skill writes user-project files only. It must never modify files under `agents/`, `skills/`, `prompts/`, or `.claude-plugin/` (those are plugin-owned).
- Once written, the user owns the installed files. Edit `preferences.md` per project. Re-running `/lo-swe:init` refuses by design.
- If you ever need to refresh the harness for a new plugin version, delete the files you want refreshed (at minimum `.github/copilot-instructions.md`) and re-run `/lo-swe:init`.
