#!/bin/bash

#calendarWeek=`date +%U -d "1 week ago"`
calendarWeek="38"

#cat performance_Metrics_2021-09-06.csv performance_Metrics_2021-09-07.csv performance_Metrics_2021-09-08.csv performance_Metrics_2021-09-09.csv performance_Metrics_2021-09-10.csv performance_Metrics_2021-09-11.csv performance_Metrics_2021-09-12.csv > performance_Metrics_CW36.csv

cat *.csv > performance_Metrics_${calendarWeek}.csv

grep -v "User,Job_name,Partition,Job_id,Group,College,Department" performance_Metrics_${calendarWeek}.csv > performance_Metrics_${calendarWeek}_1.csv

sed -i '1i User,Job_name,Partition,Job_id,Group,College,Department,Account,Node_Requested,Cores_Requested_Per_Node,Requested_Wall-Clock_Time,Jobs_Used_Wall-Clock_Time,Core_Wall-Clock_Time_Used(in Hrs),Core_Wall-ClockTime_Wasted(in Hrs),Submit_Date,Submit_Time,Start_Date,Start_Time,End_Date,End_Time,Wait_Time(Seconds),CPU_Allocated,CPU_Used,Percentage_Of_CPU_Used,Memory_Requested,Memory_Utilized,Percentage_Of_Memory_Used,State' performance_Metrics_${calendarWeek}_1.csv

mv performance_Metrics_${calendarWeek}_1.csv performance_Metrics_${calendarWeek}_2.csv
cut -d "," -f22 performance_Metrics_${calendarWeek}_2.csv > performance_Metrics_${calendarWeek}_3.csv
cut -d "," -f13 performance_Metrics_${calendarWeek}_2.csv > performance_Metrics_${calendarWeek}_4.csv
sort -n performance_Metrics_${calendarWeek}_3.csv > performance_Metrics_${calendarWeek}_5.csv
sort -n performance_Metrics_${calendarWeek}_4.csv > performance_Metrics_${calendarWeek}_6.csv
grep -v "Core_Wall-Clock_Time_Used(in Hrs)" performance_Metrics_${calendarWeek}_6.csv > performance_Metrics_${calendarWeek}_7.csv
sed -i '1i Core_WallClockHrs' performance_Metrics_${calendarWeek}_7.csv
sed 's/$/,1/' performance_Metrics_${calendarWeek}_5.csv > performance_Metrics_${calendarWeek}_9.csv
sed 's/$/,1/' performance_Metrics_${calendarWeek}_7.csv > performance_Metrics_${calendarWeek}_10.csv
grep -v "Core_WallClockHrs" performance_Metrics_${calendarWeek}_10.csv > performance_Metrics_${calendarWeek}_11.csv
sed -i '1i CoreHrs,JobCount' performance_Metrics_${calendarWeek}_11.csv
grep -v "CPU" performance_Metrics_${calendarWeek}_9.csv > performance_Metrics_${calendarWeek}_12.csv
sed -i '1i CPU_Allocated,JobCount' performance_Metrics_${calendarWeek}_12.csv

mv performance_Metrics_${calendarWeek}_11.csv CoreWallHrs.csv
mv performance_Metrics_${calendarWeek}_12.csv CPU.csv
rm performance_Metrics_${calendarWeek}*
mv CoreWallHrs.csv ..
mv CPU.csv ..

cd ..

python Histogram_CoreHrs.py CoreWallHrs.csv CoreHrs_$calendarWeek.png 'Core Wallclock Hrs requested'
python Histogram_CPU.py CPU.csv CPU_$calendarWeek.png 'CPU Requested'

mail -a CPU_$calendarWeek.png -a CPU.csv -s "Weekly report CPU - CW$calendarWeek" cmaher9@uncc.edu,sthirumo@uncc.edu < /dev/null
mail -a CoreHrs_$calendarWeek.png -a CoreWallHrs.csv -s "Weekly report Core WallClock - CW$calendarWeek" cmaher9@uncc.edu,sthirumo@uncc.edu < /dev/null

rm CPU_$calendarWeek.png CoreHrs_$calendarWeek.png CPU.csv CoreWallHrs.csv
