# Repository Guidelines

## Project Structure & Module Organization

This repository stores personal shell configuration, environment setup, and small hardware/debug utilities. Root-level dotfiles and `bashrc.*` variants are linked into `$HOME` by `install_home.sh`. Helper commands live in `bin/`; environment snippets live in `dev_envs/`; AWK log parsing utilities live under `scripts/awk/`; `grcat.configs/` contains color configuration files for log output. Raspberry Pi hardware scripts are in `raspbian/`, and C conversion experiments are in `mytest/`. LTIB compatibility material is isolated in `ltib-ubuntu-10.04-patch/`.

## Build, Test, and Development Commands

- `bash install_home.sh`: interactively installs or links supported config files into the current user home directory.
- `bash -n install_home.sh bin/*.sh dev_envs/*.sh`: checks shell scripts for syntax errors.
- `python3 -m py_compile raspbian/*.py`: verifies Python scripts parse before running them on target hardware.
- `gcc -Wall -Wextra -o /tmp/test_temp_adc_conversion mytest/test_temp_adc_conversion.c && /tmp/test_temp_adc_conversion`: builds and runs the ADC/temperature conversion test without modifying tracked files.

Run hardware scripts directly only on systems with the expected devices and permissions, for example `python3 raspbian/test_serial.py /dev/ttyUSB0 115200`.

## Coding Style & Naming Conventions

Shell scripts use `bash`, tabs are common in existing control blocks, and variables are generally lowercase or descriptive uppercase for exported environment values. Keep scripts POSIX-friendly where practical, but preserve Bash features when editing existing Bash files. Python scripts target Python 3 and currently use compact procedural style; prefer clear function names and avoid adding framework dependencies. C code follows the existing kernel-adjacent style with tabs, uppercase constants, and `i`-prefixed integer locals.

## Testing Guidelines

There is no central test runner. For each change, run the syntax or compile command relevant to the touched language. For hardware-facing scripts in `raspbian/`, document the device, board, and command used for manual verification in the pull request. Keep ad hoc test binaries outside the repository, preferably in `/tmp`.

## Commit & Pull Request Guidelines

Recent history uses short, imperative summaries such as `add hwtcon.conf` and `remove .ssh/id_rsa`. Follow that style: one concise subject line, lower-case when natural, focused on the changed file or behavior. Pull requests should explain why the change is needed, list the verification commands run, and mention any host-specific or hardware-specific assumptions.

## Security & Configuration Tips

Do not commit private keys, credentials, generated key archives, or machine-local secrets. Review changes to `.ssh*`, `keypairs/`, and email or VPN configuration files carefully before publishing.
