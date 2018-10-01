'use strict';

const fs = require('fs');

const Hapi = require('hapi');
const Glob = require('glob');
const ExpandHomeDir = require('expand-home-dir');

function parse_keystrokes() {
  const username = 'personal macbook 2012, felix';

  const MINUTE = 1, HOUR = 2;
  const resolution = MINUTE;

  const minute_to_keycount = {};
  const paths = Glob.sync(ExpandHomeDir(`~/Dropbox/keylogs/${username}/*-*-*.log`));
  for(let ipath = 0; ipath < paths.length; ipath++) {
    const path = paths[ipath];
    console.log('path:', path);

    const text = fs.readFileSync(path, 'utf8');
    const lines = text.split('\n')

    let keys_str = '';
    for(let iline = 1; iline < lines.length; iline++) {
      const vals = lines[iline].split(' ');
      for(var i = 0; i < vals.length; i++)
        vals[i] = parseInt(vals[i]);
      const timestamp = vals[0], keycode = vals[1], modifiers = vals[2];
      if(!timestamp)
        continue;
      const key_dt = new Date(timestamp * 1000);
      const dt_bucket = key_dt;
      dt_bucket.setSeconds(0);
      if(resolution == HOUR)
        dt_bucket.setMinutes(0);

      const dt_bucket_ms = dt_bucket.getTime();
      if(minute_to_keycount[dt_bucket_ms] === undefined)
        minute_to_keycount[dt_bucket_ms] = 0;
      minute_to_keycount[dt_bucket_ms] += 1
    }
  }

  return minute_to_keycount;
}

const init = async () => {
  const minute_to_keycount = parse_keystrokes();

  const server = Hapi.server({
    port: 3000,
    host: 'localhost'
  });

  await server.register(require('inert'));

  server.route({
    method: 'GET',
    path: '/minute_to_keycount',
    handler: (request, h) => {
      return minute_to_keycount;
    }
  });

  server.route({
    method: 'GET',
    path: '/',
    handler: (request, h) => {
      return fs.readFileSync('index.html', 'utf8');
    }
  });

  await server.start();

  console.log(`Server running at: ${server.info.uri}`);
};

process.on('unhandledRejection', (err) => {
  console.log(err);
  process.exit(1);
});

init();
