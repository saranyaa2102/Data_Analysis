import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sys

def plot_histogram_01():
    df= pd.read_csv(sys.argv[1])
    df.head()
    np.random.seed(1)
    values_A = df.CPU_Allocated
    values_B = df.JobCount
    values_A_to_plot = [31 if i > 30 else i for i in values_A]
    bins=[0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32]
    fig, ax = plt.subplots(figsize=(9, 5))
    _, bins, patches = plt.hist([values_A_to_plot],
                                bins=bins,
                                weights=df.JobCount,
                                color=['#3782CC'],
                                label=['CPU_Allocated'])
    xlabels = np.array(bins[1:], dtype='|S4')
    xlabels[-1] = '32+'
    N_labels = len(xlabels)
    plt.xticks(2 * np.arange(N_labels) + 2)
    ax.set_xticklabels(xlabels)
    plt.yticks()

    plt.title(sys.argv[3])
    plt.ylabel('Job Count')
    plt.setp(patches, linewidth=0)
    plt.legend()
    f1=sys.argv[2]
    plt.savefig(f1,bbox_inches = 'tight')
plot_histogram_01()
