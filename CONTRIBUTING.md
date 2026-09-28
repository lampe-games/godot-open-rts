[CONTRIBUTING.md](https://github.com/user-attachments/files/32774121/CONTRIBUTING.md)# Contributing to Open RTS

Thanks for your interest in contributing to **Open RTS**, an open-source real-time strategy game made with Godot 4! 🎮

This project is not trying to compete with big commercial RTS games. Its goals are simplicity and clean design so that it can:

- showcase Godot 4 capabilities for RTS development
- serve as an open-source project template for RTS games
- educate game creators on RTS game mechanics

Please keep these goals in mind when proposing or making changes.

## Table of Contents

- [Ways to Contribute](#ways-to-contribute)
- [Before You Start](#before-you-start)
- [Getting Set Up](#getting-set-up)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Testing](#testing)
- [Commit Messages](#commit-messages)
- [Pull Request Checklist](#pull-request-checklist)
- [Assets and Licensing](#assets-and-licensing)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)
- [Code of Conduct](#code-of-conduct)

## Ways to Contribute

- **Fix bugs**: open a PR directly.
- **Refactor**: cleanups and refactoring are welcome; open a PR directly.
- **Add features**: please refer to an existing issue, or create one *before* starting implementation (see [Suggesting Features](#suggesting-features)).
- **Report bugs** and help triage issues.
- **Improve documentation**, including the README and this guide.
- **Test manually** and share your findings.

Areas the project would still benefit from (see the feature list in the README): swarm movement to unit, polished UI, sounds, music, and VFX.

## Before You Start

1. Search [existing issues](https://github.com/lampe-games/godot-open-rts/issues) and [pull requests](https://github.com/lampe-games/godot-open-rts/pulls) to avoid duplicated work.
2. For anything larger than a small fix, open an issue first (or comment on an existing one) so the approach can be discussed.
3. Keep changes focused. One PR should do one thing.

## Getting Set Up

1. **Fork** the repository and clone your fork:
   ```bash
   git clone https://github.com/<your-username>/godot-open-rts.git
   cd godot-open-rts
   ```
2. **Install Godot 4.3.** The `main` branch is compatible with Godot `4.3`. Older versions are supported on separate branches:
   - `godot-4.2-support`
   - `godot-4.1-support`
   - `godot-4.0-support`
3. Open the project in Godot by importing `project.godot`.
4. Run the project and make sure it works before you change anything.
5. Create a branch for your work:
   ```bash
   git checkout -b fix/short-description
   ```

## Project Structure

| Path | Purpose |
| --- | --- |
| `source/` | Game source code and scenes |
| `assets/` | Game assets (models, textures, etc.) |
| `media/` | Screenshots and other repository media |
| `build/` | Build-related files |
| `tests/manual/` | Manual test scenes |
| `.github/` | GitHub configuration and workflows |
| `makefile` | Helper commands for common tasks |
| `CHANGELOG.md` | Notable changes between releases |

## Development Workflow

1. Sync your fork with `main` before starting.
2. Make your changes in a feature branch (never commit directly to `main`).
3. Run the game and test your change manually.
4. Commit in small, logical steps.
5. Push to your fork and open a Pull Request against `main`.
6. Respond to review feedback and update your PR as needed.

If your change targets an older Godot version, mention it in the PR so the maintainers can decide which branch it belongs on.

## Code Style

- Follow the conventions already used in the codebase. When in doubt, look at nearby files.
- Follow the official [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
- Use the repository's formatting configuration (for example `.clang-format`) and the tools listed in the `makefile` where applicable.
- Keep code simple and readable. Clarity beats cleverness, since this project is meant for learning.
- Add comments where the *why* isn't obvious, but avoid commenting the obvious.
- Prefer small, single-purpose scripts and scenes over large ones.
- Don't commit unrelated formatting changes or generated files (`.godot/`, editor caches, etc.).

## Testing

The project uses manual test scenes located in `tests/manual/`.

- Run the game and verify your change works as intended.
- If you fix a bug or add a feature, add or update a manual test scene when it makes sense.
- Check that you haven't broken existing behavior (unit movement, fog of war, minimap, AI matches, player switching, etc.).
- Describe how you tested in your PR.

## Commit Messages

- Use the imperative mood and a short summary line (about 50 characters), for example: `Fix unit stuck on terrain edge`.
- Add a longer body if needed, explaining *what* and *why*.
- Reference related issues, for example `Fixes #123`.

## Pull Request Checklist

Before submitting, please make sure that:

- [ ] The PR is focused on a single change.
- [ ] A related issue exists (required for new features).
- [ ] The project opens and runs without new errors or warnings in Godot 4.3.
- [ ] Your change has been tested manually.
- [ ] Code follows the project's style.
- [ ] No unrelated files or formatting changes are included.
- [ ] `CHANGELOG.md` is updated for user-visible changes (if applicable).
- [ ] Any new assets are properly licensed and credited.

In the PR description, please explain:

1. What the change does and why.
2. How you tested it.
3. Screenshots or a short video for visual or gameplay changes.

## Assets and Licensing

- The project is released under the [MIT License](LICENSE). By contributing, you agree that your contributions are licensed under the same license.
- Only submit assets (models, textures, sounds, music, etc.) that you created yourself or that have a compatible license (for example CC0 or MIT).
- Always credit third-party assets and mention their source and license in your PR. The project already uses assets such as the 3D Space Kit by [Kenney](https://www.kenney.nl/assets/space-kit).
- Do not submit copyrighted material without permission.

## Reporting Bugs

Please [open an issue](https://github.com/lampe-games/godot-open-rts/issues) and include:

- A clear, descriptive title
- Steps to reproduce the problem
- Expected behavior vs. actual behavior
- Godot version and operating system
- Screenshots, videos, or error output if available

## Suggesting Features

1. Check whether a similar issue already exists.
2. If not, open a new issue describing the feature, the problem it solves, and how it fits the project's goals of simplicity and clean design.
3. Wait for feedback from the maintainers before investing significant time in implementation.

## Code of Conduct

Be respectful, patient, and constructive. Harassment, discrimination, and personal attacks are not acceptable. Assume good intent, give helpful feedback, and remember that everyone here is contributing their free time.

---

Thank you for helping make Open RTS better! 🚀

