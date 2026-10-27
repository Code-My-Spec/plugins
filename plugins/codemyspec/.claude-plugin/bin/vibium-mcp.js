#!/usr/bin/env node
// Give vibium's MCP server its own daemon session per working copy.
//
// `vibium mcp` defaults to one shared background daemon (one Chrome profile,
// one cookie jar, one "current page" pointer) for every caller on the
// machine — documented as issue 5ab088cc: concurrent QA sessions surface
// each other's logged-in accounts mid-flow, including mid-submit. vibium
// 26.8.21 added `--session <name>` for exactly this ("named daemon session
// for isolated concurrent use"); nothing was passing it, so every working
// copy on a box still shared the one default session.
//
// Node, not a shell script, because `vibium` itself only runs where Node
// already does (it ships as an npm package) — one file works on macOS,
// Linux and Windows instead of a bash/`.cmd` pair, the same trap
// `approve.cmd`/`hook.cmd` exist to work around elsewhere in this plugin.
//
// `working_copy_id` is the natural key — stable per checkout, already the id
// every other tool in this plugin resolves a working copy by. Scoped to the
// working copy, not the agent: several agents can share one checkout (a
// coding and a QA agent both running against the same worktree), and they
// still share a browser under this — narrower isolation would need a
// per-agent identity nothing on disk carries today.
//
// Same walk-up as `bin/hook`'s `harness_id()`: a working copy without
// `.cms_harness.json` (not yet onboarded) falls back to vibium's own
// default session rather than failing the MCP server outright.
'use strict';

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

function workingCopyId() {
  let dir = process.cwd();
  for (;;) {
    const file = path.join(dir, '.cms_harness.json');
    if (fs.existsSync(file)) {
      try {
        const data = JSON.parse(fs.readFileSync(file, 'utf8'));
        return typeof data.working_copy_id === 'string' ? data.working_copy_id : null;
      } catch {
        return null;
      }
    }
    const parent = path.dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

const id = workingCopyId();
const args = process.argv.slice(2);
if (id) args.push('--session', id);

const child = spawn('vibium', args, { stdio: 'inherit', shell: process.platform === 'win32' });
child.on('exit', (code, signal) => process.exit(signal ? 1 : code));
child.on('error', (err) => {
  console.error(`vibium-mcp: could not launch vibium: ${err.message}`);
  process.exit(1);
});
