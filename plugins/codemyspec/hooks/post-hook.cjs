// Command hooks work for SessionStart as well as the other Claude lifecycle events.
const http = require('node:http');
const port = process.env.CMS_HARNESS_PORT || '4003';
const event = process.argv[2];
if (!/^\d+$/.test(port) || Number(port) < 1 || Number(port) > 65535 ||
    !/^[a-z-]+$/.test(event || '')) {
  console.error('Invalid CodeMySpec harness port or hook event');
  process.exit(1);
}

// Buffered, so the request carries a Content-Length rather than a chunked body.
const chunks = [];
process.stdin.on('data', chunk => chunks.push(chunk));
process.stdin.on('end', () => {
  const body = Buffer.concat(chunks);
  const request = http.request({
    hostname: '127.0.0.1', port, path: `/api/hooks/${event}`, method: 'POST',
    headers: {'Content-Type': 'application/json', 'Content-Length': body.length},
  }, response => {
    response.pipe(process.stdout);
    if (response.statusCode >= 400) process.exitCode = 1;
  });
  const timer = setTimeout(() => request.destroy(new Error('Harness hook timed out')), 30000);
  request.on('close', () => clearTimeout(timer));
  request.on('error', error => {
    console.error(`CodeMySpec harness on port ${port}: ${error.message}`);
    process.exitCode = 1;
  });
  request.end(body);
});
