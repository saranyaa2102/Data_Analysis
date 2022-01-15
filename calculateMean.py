import sys
import matplotlib as plt
import pandas as pd


#fig = plt.figure()
f=sys.argv[1]
data = pd.read_csv(f)
df = pd.DataFrame(data)
mean = df[sys.argv[3]].mean()
mean1 = round(mean)
#print(mean1,sys.argv[4],sep='|',end=',')
#print(sys.argv[2])
print(mean1,sys.argv[2],mean1,sep=',',end='|')
print(sys.argv[4])
