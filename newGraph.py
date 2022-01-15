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

#fig = plt.figure()
f=sys.argv[1]
data = pd.read_csv(f,delimiter=",")
df = pd.DataFrame(data)
plt.style.use('seaborn')
plt.rcParams['figure.figsize'] = (130, 290)
plt.figure(figsize=(130,290))
plt.rcParams["patch.force_edgecolor"] = True
colors = sns.color_palette('husl', n_colors=len(df))
p = sns.barplot(x=sys.argv[5], y=sys.argv[6], data=df, hue=sys.argv[5], dodge=False,ci=None)
p.legend(loc='left left', borderaxespad=0, fontsize=9)
handles, labels = p.get_legend_handles_labels()
p.legend(handles[::-1], labels[::-1], loc='upper right')
p.set_xticklabels('')
plt.title(sys.argv[3], pad=20, fontstyle='italic',fontsize=22,weight=900)
plt.xlabel(sys.argv[4], size=20, fontstyle='italic', weight=900)
plt.ylabel('Job Count', size=20, fontstyle='italic', weight=900)
f1=sys.argv[2]
plt.savefig(f1)
plt.show()
