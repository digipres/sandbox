#!/bin/bash
# Experimenting with mounting remote corpora, doesn't seem to work without raised container priviledges:
mkdir -p ./ipres-pantry
rclone mount --vfs-cache-mode full pantry: ./ipres-pantry 2>&1 > rclone-mount.log &

