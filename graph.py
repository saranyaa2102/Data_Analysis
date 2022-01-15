import pandas as pd
import matplotlib.pyplot as plt
csv_file='result_memory.csv'
data = pd.read_csv(csv_file)
Votes = data["Memory_Requested"]
Genre = data["Memory_Utilized"]
x=[]
y=[]
x=list(Genre)
y=list(Votes)
plt.pie(x,labels=y)
plt.xlabel('Genre->')
plt.ylabel('Total Votes->')
plt.title('Data')
plt.show()
