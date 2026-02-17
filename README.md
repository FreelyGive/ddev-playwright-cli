[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/FreelyGive/ddev-playwright-cli/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/FreelyGive/ddev-playwright-cli/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/FreelyGive/ddev-playwright-cli)](https://github.com/FreelyGive/ddev-playwright-cli/commits)
[![release](https://img.shields.io/github/v/release/FreelyGive/ddev-playwright-cli)](https://github.com/FreelyGive/ddev-playwright-cli/releases/latest)

# DDEV Playwright Cli

## Overview

This add-on integrates Playwright CLI into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get FreelyGive/ddev-playwright-cli
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command                       | Description                               |
|-------------------------------|-------------------------------------------|
| `ddev playwright-cli`         | Execute the Playwright CLI from the host. |

## Credits

**Contributed and maintained by [@FreelyGive](https://github.com/FreelyGive)**
