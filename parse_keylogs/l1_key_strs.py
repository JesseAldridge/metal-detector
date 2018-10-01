import glob, os, json

import l0_keycodes

with open(os.path.expanduser("~/.keylogger")) as f:
  text = f.read()
config_dict = json.loads(text)
username = config_dict['username']

for path in glob.glob(os.path.expanduser("~/Dropbox/keylogs/{}/*-*-*.log".format(username)))[-5:]:
  with open(path) as f:
    lines = f.read().splitlines()

  keys_str = ''
  for line in lines[1:]:
    try:
      timestamp, keycode, modifiers = (int(x) for x in line.split())
    except ValueError:
      continue

    for char, mask in l0_keycodes.mod_masks.iteritems():
      if mask & modifiers:
        keys_str += char
    char = l0_keycodes.key_chars[keycode]
    keys_str += char
  print keys_str
