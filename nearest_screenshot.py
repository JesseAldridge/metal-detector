import subprocess, os, time, glob
from datetime import datetime, timedelta

import pytz

date_to_check = datetime.now()
date_to_check += timedelta(days=-1)
today_str = date_to_check.strftime('%m-%d-%Y')
DESIRED_LOCAL_TIME_STR = '{} 11:58 pm'.format(today_str)

# DESIRED_LOCAL_TIME_STR = '08-04-2018 3:09 pm'

print 'looking for screenshot from:', DESIRED_LOCAL_TIME_STR

dt = datetime.strptime(DESIRED_LOCAL_TIME_STR, '%m-%d-%Y %I:%M %p')
tz = pytz.timezone('US/Pacific')
dt = tz.localize(dt)
dt_utc = dt.astimezone(pytz.timezone('UTC'))
dt_str = dt_utc.strftime('%Y-%m-%d_%H.%M.%S')

print 'finding first screenshot after:', dt_str

for path in sorted(glob.glob(os.path.join(os.path.expanduser('~/screenshots'), '*.png'))):
  filename = os.path.basename(path)
  if filename > dt_str:
    break

def applescript(script):
    p = subprocess.Popen(['osascript', '-e', script],
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# Reveal the screenshot in finder
print 'revealing:', path
script = '''
set thePath to POSIX file "{}"
tell application "Finder" to reveal thePath
'''.format(path)
applescript(script)

time.sleep(2)
