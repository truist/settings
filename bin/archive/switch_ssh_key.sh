#!/usr/bin/env bash

set -e

REMOTE="$1"

OLD_KEY="$HOME/.ssh/id_rsa_old"
NEW_KEY="$HOME/.ssh/id_ed25519.pub"

cat "$NEW_KEY" | ssh -i "$OLD_KEY" "$REMOTE" "cat >> ~/.ssh/authorized_keys"

ssh "$REMOTE"

