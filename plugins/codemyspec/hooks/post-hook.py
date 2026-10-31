#!/usr/bin/env python3
"""Forward a Claude command hook to the local harness without requiring Node."""
import os
import pathlib
import re
import sys
import urllib.error
import urllib.request


def main():
    port = os.environ.get('CMS_HARNESS_PORT')
    if not port:
        try:
            port = (pathlib.Path.home() / '.codemyspec/harness.port').read_text().strip()
        except FileNotFoundError:
            port = '4003'
    event = sys.argv[1] if len(sys.argv) == 2 else ''
    if not port.isdecimal() or not 1 <= int(port) <= 65535 or not re.fullmatch(r'[a-z-]+', event):
        print('Invalid CodeMySpec harness port or hook event', file=sys.stderr)
        return 1

    payload = sys.stdin.buffer.read()
    request = urllib.request.Request(
        f'http://127.0.0.1:{port}/api/hooks/{event}',
        data=payload,
        headers={'Content-Type': 'application/json'},
        method='POST',
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            sys.stdout.buffer.write(response.read())
        return 0
    except urllib.error.HTTPError as error:
        sys.stdout.buffer.write(error.read())
        return 1
    except (urllib.error.URLError, TimeoutError) as error:
        print(f'CodeMySpec harness on port {port}: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
