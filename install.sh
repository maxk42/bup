#!/bin/bash

# install.sh — Install or uninstall bup

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
MANDIR="${MANDIR:-$PREFIX/share/man/man1}"

show_help() {
    cat << 'EOF'
install.sh — Install or uninstall bup

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    --prefix DIR    Set install prefix (default: /usr/local)
    --uninstall     Remove bup from the system
    -h, --help      Show this help message

ENVIRONMENT:
    PREFIX          Override install prefix (default: /usr/local)
    BINDIR          Override binary directory (default: PREFIX/bin)
    MANDIR          Override man page directory (default: PREFIX/share/man/man1)

EXAMPLES:
    ./install.sh                          # install to /usr/local
    sudo ./install.sh                     # install to /usr/local (with permissions)
    ./install.sh --prefix ~/.local        # install to ~/.local
    PREFIX=~/.local ./install.sh          # same as above
    ./install.sh --uninstall              # remove bup

EOF
}

do_install() {
    echo "Installing bup to $BINDIR..."

    # Check source files exist
    if [ ! -f "$SCRIPT_DIR/bup" ]; then
        echo "Error: bup not found in $SCRIPT_DIR" >&2
        exit 1
    fi
    if [ ! -f "$SCRIPT_DIR/man/bup.1" ]; then
        echo "Error: man/bup.1 not found in $SCRIPT_DIR" >&2
        exit 1
    fi

    # Create directories if needed
    if [ ! -d "$BINDIR" ]; then
        mkdir -p "$BINDIR" || { echo "Error: Cannot create $BINDIR (try with sudo?)" >&2; exit 1; }
    fi
    if [ ! -d "$MANDIR" ]; then
        mkdir -p "$MANDIR" || { echo "Error: Cannot create $MANDIR (try with sudo?)" >&2; exit 1; }
    fi

    # Check write permissions
    if [ ! -w "$BINDIR" ]; then
        echo "Error: No write permission for $BINDIR (try with sudo?)" >&2
        exit 1
    fi
    if [ ! -w "$MANDIR" ]; then
        echo "Error: No write permission for $MANDIR (try with sudo?)" >&2
        exit 1
    fi

    # Install files
    cp "$SCRIPT_DIR/bup" "$BINDIR/bup"
    chmod 755 "$BINDIR/bup"
    echo "  Installed $BINDIR/bup"

    cp "$SCRIPT_DIR/man/bup.1" "$MANDIR/bup.1"
    chmod 644 "$MANDIR/bup.1"
    echo "  Installed $MANDIR/bup.1"

    echo ""
    echo "Done. Run 'bup --version' to verify."

    # Check if BINDIR is on PATH
    case ":$PATH:" in
        *":$BINDIR:"*) ;;
        *)
            echo ""
            echo "Note: $BINDIR is not in your PATH."
            echo "Add it with: export PATH=\"$BINDIR:\$PATH\""
            ;;
    esac
}

do_uninstall() {
    echo "Removing bup..."

    if [ -f "$BINDIR/bup" ]; then
        rm -f "$BINDIR/bup"
        echo "  Removed $BINDIR/bup"
    else
        echo "  $BINDIR/bup not found (skipped)"
    fi

    if [ -f "$MANDIR/bup.1" ]; then
        rm -f "$MANDIR/bup.1"
        echo "  Removed $MANDIR/bup.1"
    else
        echo "  $MANDIR/bup.1 not found (skipped)"
    fi

    echo ""
    echo "Done."
}

# Parse arguments
UNINSTALL=false

while [ $# -gt 0 ]; do
    case $1 in
        --prefix)
            [ $# -lt 2 ] && { echo "Error: --prefix requires a directory" >&2; exit 1; }
            PREFIX="$2"
            BINDIR="$PREFIX/bin"
            MANDIR="$PREFIX/share/man/man1"
            shift 2
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            echo "Use -h or --help for detailed information" >&2
            exit 1
            ;;
    esac
done

if [ "$UNINSTALL" = true ]; then
    do_uninstall
else
    do_install
fi
