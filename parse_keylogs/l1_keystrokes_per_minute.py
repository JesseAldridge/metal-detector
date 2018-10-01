import glob, os, json
from datetime import datetime, timedelta

import pytz
from matplotlib import pyplot
import matplotlib.dates as mdates

import l0_keycodes

username = 'airbnb laptop'

MINUTE, HOUR = 1, 2
resolution = MINUTE

paths = glob.glob(os.path.expanduser("~/Dropbox/keylogs/{}/*-*-*.log".format(username)))
min_to_keycount = {}
min_dt, max_dt = None, None
# for path in sorted(paths)[-10:]:
for path in sorted(paths)[-1:]:
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
    dt_bucket = key_dt.replace(second=0, microsecond=0, tzinfo=pytz.timezone('UTC'))
    if resolution == HOUR:
      dt_bucket = dt_bucket.replace(minute=0)
    print 'dt_bucket:', dt_bucket
    min_to_keycount.setdefault(dt_bucket, 0)
    min_to_keycount[dt_bucket] += 1

    if min_dt is None:
      min_dt = dt_bucket
    max_dt = dt_bucket

xs, ys = [], []
dt = min_dt
td = {MINUTE: timedelta(minutes=1), HOUR: timedelta(hours=1)}[resolution]
while dt <= max_dt:
  keycount = min_to_keycount.get(dt, 0)
  xs.append(dt)
  ys.append(keycount)

  print 'dt:', dt, keycount

  dt += td
print 'plotting {} values...'.format(len(xs))
bar_width = 1. / len(xs) * 4
fig = pyplot.figure()
ax = fig.add_subplot(111)
myFmt = mdates.DateFormatter('%a, %m/%d %I:%M %p', tz=pytz.timezone('US/Pacific'))
ax.xaxis.set_major_formatter(myFmt)
ax.xaxis_date(tz=pytz.timezone('US/Pacific'))
pyplot.xticks(rotation=70)
pyplot.gcf().subplots_adjust(bottom=0.3)

# ax.bar(xs, ys, bar_width)
ax.plot(xs, ys)
pyplot.show()
