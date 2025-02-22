#!/bin/bash
uv-header () {
        cat <<'EOF'
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "ffmpeg-normalize",
# ]
# ///
EOF
}

uv-header
