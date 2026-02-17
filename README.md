[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/FreelyGive/ddev-playwright-cli/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/FreelyGive/ddev-playwright-cli/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/FreelyGive/ddev-playwright-cli)](https://github.com/FreelyGive/ddev-playwright-cli/commits)
[![release](https://img.shields.io/github/v/release/FreelyGive/ddev-playwright-cli)](https://github.com/FreelyGive/ddev-playwright-cli/releases/latest)

# DDEV Playwright Cli

## Overview

This add-on integrates Playwright Cli into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get FreelyGive/ddev-playwright-cli
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Playwright Cli |
| `ddev logs -s playwright-cli` | Check Playwright Cli logs |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.playwright-cli --playwright-cli-docker-image="ddev/ddev-utilities:latest"
ddev add-on get FreelyGive/ddev-playwright-cli
ddev restart
```

Make sure to commit the `.ddev/.env.playwright-cli` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `PLAYWRIGHT_CLI_DOCKER_IMAGE` | `--playwright-cli-docker-image` | `ddev/ddev-utilities:latest` |

## Credits

**Contributed and maintained by [@FreelyGive](https://github.com/FreelyGive)**
