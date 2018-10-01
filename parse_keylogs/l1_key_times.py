import glob, os, json
from datetime import datetime, timedelta

import pytz

import l0_keycodes

# with open(os.path.expanduser("~/.keylogger")) as f:
#   text = f.read()
# config_dict = json.loads(text)
# username = config_dict['username']
username = 'airbnb laptop'

COLOR_PINK, COLOR_BLUE, COLOR_GREEN, COLOR_YELLOW, COLOR_RED = (
  '\033[95m', '\033[94m', '\033[92m', '\033[93m', '\033[91m'
)
COLOR_END = '\033[0m'

CONTEXT_BEFORE = 0
CONTEXT_DURING = 1
CONTEXT_AFTER  = 2

target_dt = datetime.strptime('2018-01-08_05.31.06', '%Y-%m-%d_%H.%M.%S')
target_dt = target_dt.replace(tzinfo=pytz.timezone('UTC'))

start_dt = target_dt - timedelta(seconds=100)
end_dt = target_dt + timedelta(seconds=100)

state = CONTEXT_BEFORE
paths = glob.glob(os.path.expanduser("~/Dropbox/keylogs/{}/*-*-*.log".format(username)))
print 'paths:', paths
for path in sorted(paths)[-5:]:
  print 'path:', path
  with open(path) as f:
    lines = f.read().splitlines()

  keys_str = ''
  for line in lines[1:]:
    try:
      timestamp, keycode, modifiers = (int(x) for x in line.split())
    except ValueError:
      continue

    key_dt = datetime.utcfromtimestamp(timestamp)
    key_dt = key_dt.replace(tzinfo=pytz.timezone('UTC'))
    print 'key_dt:', key_dt
    if key_dt >= start_dt and key_dt < end_dt and state == CONTEXT_BEFORE:
      state = CONTEXT_DURING
      keys_str += COLOR_RED
    elif key_dt > end_dt and state == CONTEXT_DURING:
      keys_str += COLOR_END

    for char, mask in l0_keycodes.mod_masks.iteritems():
      if mask & modifiers:
        keys_str += char
    char = l0_keycodes.key_chars[keycode]
    keys_str += char
  print keys_str

print 'target_dt:', target_dt

