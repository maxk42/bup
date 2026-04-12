# bup - Backup utility that creates compressed tarballs of directories

## INSTALLATION

### Using make
```bash
sudo make install                # install to /usr/local
make install PREFIX=~/.local     # install to ~/.local (no sudo needed)
sudo make uninstall              # remove
```

### Using install.sh
```bash
sudo ./install.sh                      # install to /usr/local
./install.sh --prefix ~/.local         # install to ~/.local (no sudo needed)
sudo ./install.sh --uninstall          # remove
```

### Manual
```bash
sudo cp bup /usr/local/bin/
sudo cp man/bup.1 /usr/local/share/man/man1/
```

### Dependencies
**Required:** bash, tar, coreutils (realpath, mktemp, du, date)

**Optional:** gpg (encryption), bzip2, xz, zstd (alternate compression)

### Running tests
```bash
make test        # or: ./test-bup
```

## USAGE
bup <directory...> [OPTIONS]

## ARGUMENTS
- `directory...` - One or more directories to backup

## OPTIONS
- `-o output_directory` - Specify alternative directory to store the
tarball (default: current directory)
- `-x, --exclude pattern` - Exclude files matching the given pattern (can be
used multiple times). Patterns are passed to tar's --exclude
- `--exclude-vcs` - Exclude version control system files (.git, .svn, etc.)
- `--exclude-artifacts` - Exclude common build outputs, dependency directories,
caches, and IDE files
- `--exclude-secrets` - Exclude common secrets, credentials, private keys,
and environment files
- `--exclude-dev` - Exclude both artifacts and secrets (shorthand for
`--exclude-artifacts --exclude-secrets`)
- `--show-excludes` - Print all exclusion patterns and exit
- `--show-excluded` - Preview which files would be excluded from the backup
(no backup is created)
- `-v, --verbose` - Enable verbose output and set BUP_VERBOSE environment
variable for pre/post scripts
- `-n, --dry-run` - Show what would happen without creating a backup
- `--combined` - Bundle multiple directories into a single tarball
- `-z, --compress algo` - Choose compression algorithm: `gzip` (default),
`bzip2`, `xz`, `zstd`
- `-e, --encrypt` - Encrypt tarball with GPG (symmetric, prompts for
passphrase)
- `--recipient KEY` - Use asymmetric GPG encryption with KEY (implies `-e`)
- `--keep N` - After backup, keep only the N most recent backups per
directory and delete the rest
- `--prune N` - Standalone: delete old backups, keep N most recent (no new
backup is created)
- `--list` - List existing backups in the output directory
- `-L, --list-verbose` - List backups with detailed info (file count)
- `-s, --save-script` - Generate an executable backup script that re-runs bup
with the same arguments (default: `./backup.sh`)
- `-S, --script-name name` - Use `name` instead of `backup.sh` (implies
`--save-script`)
- `-d, --script-dir directory` - Write the script to `directory` instead of
the current directory (implies `--save-script`)
- `--no-scripts` - Skip automatic execution of `.bup-pre.sh` and
`.bup-post.sh` scripts
- `--include-backups` - Include prior backup files when the output directory
is inside the directory being backed up (by default they are excluded)
- `-V, --version` - Show version number and exit
- `-h, --help` - Show this help message

## DESCRIPTION
Creates a compressed tarball of the specified directory with automatic
naming:
bak.[directory_name].[YYYY-mm-dd].tgz

If a file with the same name exists, a numeric suffix is added:
bak.[directory_name].[YYYY-mm-dd].1.tgz

The file extension varies by compression algorithm: `.tgz` (gzip),
`.tbz2` (bzip2), `.txz` (xz), `.tzst` (zstd). Encrypted backups
additionally have a `.gpg` suffix.

## MULTIPLE DIRECTORIES
Multiple directories can be specified to back up each one individually:
```bash
bup /home/user/projA /home/user/projB -o /backup
```

Use `--combined` to bundle them into a single tarball:
```bash
bup /home/user/projA /home/user/projB --combined -o /backup
```
The combined tarball is named `bak.projA+projB.[date].tgz`.

## COMPRESSION
The default compression algorithm is gzip. Use `-z` to choose an
alternative:
```bash
bup /home/user/project -z bzip2    # produces .tbz2
bup /home/user/project -z xz       # produces .txz
bup /home/user/project -z zstd     # produces .tzst
```

## ENCRYPTION
Use `-e` for symmetric GPG encryption (prompts for a passphrase):
```bash
bup /home/user/project -e
```

Use `--recipient` for asymmetric encryption with a specific GPG key:
```bash
bup /home/user/project --recipient alice@example.com
```

Encrypted files have a `.gpg` suffix (e.g., `.tgz.gpg`).

## RETENTION
Use `--keep N` to automatically delete older backups after creating a
new one, keeping only the N most recent:
```bash
bup /home/user/project --keep 5 -o /backup
```

Use `--prune N` as a standalone command to delete old backups without
creating a new one:
```bash
bup /home/user/project --prune 3 -o /backup
```

## LISTING BACKUPS
Use `--list` to see existing backups in a table format:
```bash
bup --list -o /backup                    # list all backups
bup /home/user/project --list -o /backup # list backups for a specific directory
```

Use `-L` for verbose output including file counts:
```bash
bup /home/user/project -L -o /backup
```

## EXCLUDING DEVELOPMENT FILES

Use `--exclude-artifacts` to skip common build outputs, dependency
directories, caches, and IDE files:
```bash
bup /home/user/project --exclude-artifacts
```

Use `--exclude-secrets` to skip common secrets, credentials, and keys:
```bash
bup /home/user/project --exclude-secrets
```

Use `--exclude-dev` as shorthand for both:
```bash
bup /home/user/project --exclude-dev -o /backup
```

Use `--show-excludes` to see the full list of patterns for each category:
```bash
bup --show-excludes
```

Use `--show-excluded` to preview which files would actually be excluded
from a specific directory:
```bash
bup /home/user/project --exclude-dev --show-excluded
```

### Artifact Patterns

The following patterns match at any depth in the directory tree:

Dependency directories: `node_modules`, `bower_components`, `.bundle`,
`jspm_packages`

Build outputs: `cmake-build-*`, `*.egg-info`, `__pycache__`, `*.pyc`

Caches: `.cache`, `.parcel-cache`, `.next`, `.nuxt`, `.turbo`, `.angular`,
`.svelte-kit`, `.gradle`, `.sass-cache`, `.pytest_cache`, `.mypy_cache`,
`.ruff_cache`, `.tox`, `.nox`, `.venv`, `.eggs`, `.hypothesis`,
`.coverage`, `htmlcov`, `.phpunit.cache`, `.jest-cache`

IDE/editor: `.idea`, `.vs`, `.vscode`, `*.swp`, `*.swo`, `*~`, `.DS_Store`

Misc: `.terraform`, `.serverless`, `cdk.out`, `.aws-sam`, `.vagrant`

The following patterns have generic names that could match legitimate
project content, so they are **anchored to the top level** of the
backed-up directory only.  For example, a top-level `bin/` is excluded
but a nested `src/bin/` is preserved:

Top-level only: `vendor`, `packages`, `target`, `build`, `dist`, `out`,
`bin`, `obj`, `_build`, `venv`, `artifacts`

### Secret Patterns
Environment files: `.env`, `.env.*`, `appsettings.json`,
`appsettings.*.json`, `secrets.json`, `local.settings.json`

Credentials/keys: `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`,
`*.keystore`, `credentials.json`, `service-account*.json`, `*.gpg-key`,
`.npmrc`, `.pypirc`, `.docker/config.json`, `.netrc`, `.htpasswd`

Cloud/infra: `terraform.tfvars`, `*.tfvars`, `.aws/credentials`

SSH keys: `id_rsa`, `id_ed25519`, `id_ecdsa`

## DRY RUN
Use `-n` to see what would happen without actually creating any files:
```bash
bup /home/user/project -n -e -z xz --keep 3
```

## AUTOMATIC SCRIPT EXECUTION
If present, the following scripts are automatically executed:

### `.bup-pre.sh`
- Executed before creating the backup tarball
- Script runs in the target directory
- If script fails, backup is aborted
- Receives `BUP_VERBOSE=1` environment variable in verbose mode

### `.bup-post.sh`
- Executed after creating the backup tarball
- Script runs in the target directory
- If script fails, backup continues (warning issued)
- Receives `BUP_VERBOSE=1` environment variable in verbose mode

Use `--no-scripts` to disable automatic script execution entirely.

## ENVIRONMENT VARIABLES
- `BUP_VERBOSE` - Set to "1" when --verbose flag is used, available to
.bup-pre.sh and .bup-post.sh scripts
- `NO_COLOR` - Set to any value to disable colored output

## EXAMPLES
```bash
bup /home/user/project
bup /home/user/project -o /backup/location
bup /home/user/project --verbose
bup /home/user/project -o /backup -v
bup /home/user/project -x "*.log" -x "*.tmp"
bup /home/user/project --exclude-vcs
bup /home/user/project -x "node_modules" --exclude-vcs -o /backup
bup /home/user/project -o /backup -s
bup /home/user/project -o /backup -S my-backup.sh
bup /home/user/project -o /backup -s -d /usr/local/bin
bup /home/user/project -n
bup /home/user/projA /home/user/projB -o /backup
bup /home/user/projA /home/user/projB --combined -o /backup
bup /home/user/project -z xz -o /backup
bup /home/user/project -z zstd --exclude-vcs
bup /home/user/project -e
bup /home/user/project -e --recipient alice@example.com
bup /home/user/project --keep 5 -o /backup
bup /home/user/project --prune 3 -o /backup
bup --list -o /backup
bup /home/user/project -L -o /backup
bup /home/user/project --exclude-artifacts
bup /home/user/project --exclude-dev -o /backup
bup --show-excludes
bup /home/user/project --exclude-dev --show-excluded
```
