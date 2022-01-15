import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sys

def plot_histogram_01():
    df= pd.read_csv(sys.argv[1])
    df.head()
    np.random.seed(1)
    values_A = df.CoreHrs
    values_B = df.JobCount
    values_A_to_plot = [101 if i > 100 else i for i in values_A]
    #bins=[0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62]
    #bins = [0, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325]
    bins = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110]
    fig, ax = plt.subplots(figsize=(9, 5))
    _, bins, patches = plt.hist([values_A_to_plot],
                                bins=bins,
                                weights=df.JobCount,
                                color=['#3782CC'],
                                label=['Core_Wall_Clock_Hrs'])
    xlabels = np.array(bins[1:], dtype='|S4')
    xlabels[-1] = '100+'
    N_labels = len(xlabels)
    plt.xticks(10 * np.arange(N_labels) + 5)
    ax.set_xticklabels(xlabels)
    plt.yticks()
    plt.title(sys.argv[3])
    plt.ylabel('Job Count')
    plt.setp(patches, linewidth=0)
    plt.legend()
    f1=sys.argv[2]
    plt.savefig(f1,bbox_inches = 'tight')
plot_histogram_01()
