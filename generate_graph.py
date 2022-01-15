import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random
import sys

fig = plt.figure()
f=sys.argv[1]
data = pd.read_csv(f, sep=',')
df = pd.DataFrame(data)
plt.rcParams.update({'font.size': 7})

y = list(df.iloc[:, 1])
x = list(df.iloc[:, 0])
plt.xticks(rotation=20)
plt.yticks(rotation=90)

#plt.bar(sys.argv[5])
#plt.bar(sys.argv[6])

plt.legend()
plt.bar(x, y, color='g')

plt.title(sys.argv[3])
plt.xlabel(sys.argv[4])
plt.ylabel("Job Count")

# Show the plot
#plt.show()
f1=sys.argv[2]
fig.savefig(f1)
plt.show()
