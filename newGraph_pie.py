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
