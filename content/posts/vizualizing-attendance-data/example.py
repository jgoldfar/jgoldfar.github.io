import pandas
from datetime import datetime

# Pandas can guess the date format, but let's be explicit about it.
# The first row is a header row, but we'll go ahead and skip the header
# and set "niceer" column names.
df = pandas.read_csv('Swipes-Time-Only.csv', sep=',', header=None, skiprows=1, names=['TimeIn', 'TimeOut'])

# Trim unnecessary characters
df['TimeIn'] = [v.strip(' "') for v in df['TimeIn']]

# Extract hour from datetime represented in the given string if possible
def validHourOrNegative(val):
  try:
    return datetime.strptime(val, '%Y-%m-%d %H:%M:%S').hour
  except:
    return -1

df['TimeInHour'] = [validHourOrNegative(v) for v in df['TimeIn']]

# Aggregate/group by the value in the 'TimeInHour' field and count the members
# of each segment. The invalid hours appear as -1, which we drop.
NumberOfVisitors = df.groupby('TimeInHour').count().drop(-1)

import matplotlib.pyplot as plt

fig = plt.figure(figsize=(6.4, 6.4))
p = plt.bar(NumberOfVisitors.index, NumberOfVisitors.values[:, 1])
plt.ylabel('Number of Visitors')
plt.xlabel('Hour of Day')

fig.savefig('Busy-Hours-Python.png', dpi=80)
