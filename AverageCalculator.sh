#!/bin/bash

#startDate=`date --date "last sunday"  +"%F"`
startDate=2021-07-05
#calendarWeek=`date +%U -d "1 week ago"`
calendarWeek=27

echo $startDate > dates.txt

for i in {1..6}
do
        date +%Y-%m-%d -d "${startDate} +${i} days" >> dates.txt
done

cat dates.txt
echo "core_WallClock_Hrs,JobCount,combined" > mean.csv
echo "CPU_Requested,JobCount" > mean_CPU.csv


for i in `cat dates.txt`
do
        less /users/sthirumo/scripts/results/CW${calendarWeek}/result_${i}.txt | cut -d "," -f5 > ${i}.csv
        jobCount=`less /users/sthirumo/scripts/results/CW${calendarWeek}/result_${i}.txt | wc -l`
        #python calculateMean.py ${i}.csv $jobCount Core_Wall-Clock_Time >> mean.csv
        python calculateMean.py ${i}.csv $jobCount "Core_Wall-Clock_Time_Used(in Hrs)" ${i} >> mean.csv
        #cat mean_actual.csv | sed -r 's/(\w+)(.*)$/\1\|'"${i}"'\2/' >> mean.csv
        sleep 5

        if [ $i == "2021-05-12" ]
        then
                cut -f21 -d$'\t' /users/sthirumo/scripts/results/CW${calendarWeek}/performance_Metrics_${i}.csv > cpu${i}.csv
        else
                less /users/sthirumo/scripts/results/CW${calendarWeek}/performance_Metrics_${i}.csv | cut -d "," -f22 > cpu${i}.csv
        fi
        python calculateMean.py cpu${i}.csv $jobCount CPU_Allocated ${i} >> mean_CPU.csv
        #cat mean_CPU_actual.csv | sed -r 's/(\w+)(.*)$/\1\|'"${i}"'\2/' >> mean_CPU.csv
        sleep 5
done

cat mean.csv
cat mean_CPU.csv

python newGraph.py mean.csv CW${calendarWeek}.png "Average core_Wallclock Hrs-CW${calendarWeek}" "Average core Wall Clock Hrs" core_WallClock_Hrs JobCount
python newGraph.py mean_CPU.csv CPU_CW${calendarWeek}.png "Average CPU Requested - CW${calendarWeek}" "Average CPU Requested" CPU_Requested JobCount

#python generate_graph.py mean.csv CW${calendarWeek}.png "Average core_Wallclock Hrs-CW${calendarWeek}" "Average core Wall Clock Hrs"
#python generate_graph.py mean_CPU.csv CPU_CW${calendarWeek}.png "Average CPU Requested - CW${calendarWeek}" "Average CPU Requested"

cp CW${calendarWeek}.png CW${calendarWeek}/

cd /users/sthirumo/scripts/results/CW${calendarWeek}
mkdir data
cp performance_Metrics_* data/
zip -r data_CW${calendarWeek}.zip data/
cd -

#echo "This Data is for dates from Monday to Sunday in calendar week $calendarWeek" >> mean.csv
#mail -a CW${calendarWeek}.png -a /users/sthirumo/scripts/results/CW${calendarWeek}/data_CW${calendarWeek}.zip -s "Average Core Wall Clock Hours - CW${calendarWeek}" aaa@gmail.com < "mean.csv"

#echo "This Data is for dates from Monday to Sunday in calendar week $calendarWeek" >> mean_CPU.csv
#mail -a CPU_CW${calendarWeek}.png -a /users/sthirumo/scripts/results/CW${calendarWeek}/data_CW${calendarWeek}.zip -s "Average CPU Requested [Nodes*Cores per Node] - CW${calendarWeek}" aaa@gmail.com < "mean_CPU.csv"

rm mean.csv,mean_actual.csv
rm "mean_CPU.csv",mean_CPU_actual.csv


for i in `cat dates.txt`
do
        rm ${i}.csv
        rm cpu${i}.csv
done

rm dates.txt
cd /users/sthirumo/scripts/results/CW${calendarWeek}
rm -rf data
rm data_CW${calendarWeek}.zip
cd -

mv CW${calendarWeek}.png /users/sthirumo/scripts/results/CW${calendarWeek}/
mv CPU_CW${calendarWeek}.png /users/sthirumo/scripts/results/CW${calendarWeek}/
