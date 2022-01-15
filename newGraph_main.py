import matplotlib.pyplot as plt
import pandas as pd
import sys
import numpy as np

x = np.char.array(['Public Health Sciences'])
y = np.array([12884])

colors = ['#77DD77','#E4BF58','#F13C59','#6CA0DC','#A9A9A9','#D52DB7','#B1907F']
porcent = 100.*y/y.sum()
patches, texts = plt.pie(y, colors=colors, startangle=90, radius=0.9,shadow=True)
labels = ['{0} - {1:1.2f} %'.format(i,j) for i,j in zip(x, porcent)]

sort_legend = True
if sort_legend:
    patches, labels, dummy =  zip(*sorted(zip(patches, labels, y),
                                          key=lambda x: x[2],
                                          reverse=True))

plt.legend(patches, labels, loc='lower left', bbox_to_anchor=(1, 0),fontsize=24)
plt.subplots_adjust(left=0.0, bottom=0.1, right=0.45)
plt.title('College of Health & Human Svc Clock Hrs - All Partitions as of Oct, 2021',fontsize=24,x=1.0,y=0.9)
plt.show()

[sthirumo@str-i1 scripts]$ cat newGraph.py
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import sys
from matplotlib import cm
from matplotlib.patches import Patch
import plotly.express as px
from skimage import data
import matplotlib.pylab as pylab

f=sys.argv[1]
data = pd.read_csv(f,delimiter=",")
df = pd.DataFrame(data)
plt.style.use('seaborn')
plt.rcParams['figure.figsize'] = (11, 8)
#plt.figure(figsize=(130,290))
plt.figure(figsize=(11,8))
plt.rcParams["patch.force_edgecolor"] = True
colors = sns.color_palette('husl', n_colors=len(df))
p = sns.barplot(x=sys.argv[5], y=sys.argv[6], data=df, hue=sys.argv[5], dodge=False)
p.legend(loc='upper left', borderaxespad=0, fontsize=9)
handles, labels = p.get_legend_handles_labels()
p.legend(handles[::-1], labels[::-1], loc='upper left')
p.set_xticklabels('')
plt.title(sys.argv[3], pad=20, fontstyle='italic',fontsize=22,weight=900)
plt.xlabel(sys.argv[4], size=20, fontstyle='italic', weight=900)
plt.ylabel('Core WallClock hrs', size=20, fontstyle='italic', weight=900)
f1=sys.argv[2]
plt.savefig(f1,bbox_inches = 'tight')
plt.show()
