#!/bin/bash

startDate=$(date -d "`date +%Y%m01` -1 month" +%Y-%m-%d)
lastDate=$(date -d "-$(date +%d) days" +%Y-%m-%d)
startCW=`date -d "$startDate" +"%U"`
endCW=`date -d "$lastDate" +"%U"`
echo $startDate > dates.txt

for i in {1..29}
do
        date +%Y-%m-%d -d "${startDate} +${i} days" >> dates.txt
done

cat dates.txt
calendarWeek=$(date -d "`date +%Y%m01` -1 month" | cut -d " " -f2)
mkdir $calendarWeek
prefix=$(date -d "`date +%Y%m01` -1 month" +%Y-%m-)

for((i=$startCW;i<=$endCW;i++))
do
        cp CW${i}/*${prefix}* $calendarWeek/
done

echo "core_WallClock_Hrs,JobCount,combined" > mean.csv
echo "CPU_Requested,JobCount,combined" > mean_CPU.csv


for i in `cat dates.txt`
do
        less /users/sthirumo/scripts/results/${calendarWeek}/result_${i}.txt | cut -d "," -f5 > ${i}.csv
        jobCount=`less /users/sthirumo/scripts/results/${calendarWeek}/result_${i}.txt | wc -l`
        python calculateMean.py ${i}.csv $jobCount Core_Wall-Clock_Time ${i} >> mean.csv

        #python calculateMean.py ${i}.csv $jobCount "Core_Wall-Clock_Time_Used(in Hrs)" ${i} >> mean.csv
        #cat mean_actual.csv | sed -r 's/(\w+)(.*)$/\1\|'"${i}"'\2/' >> mean.csv
        sleep 5

        if [ $i == "2021-05-12" ]
        then
                cut -f21 -d$'\t' /users/sthirumo/scripts/results/${calendarWeek}/performance_Metrics_${i}.csv > cpu${i}.csv
        elif [ $i == "2021-06-19" ] || [ $i == "2021-06-20" ] || [ $i == "2021-06-21" ] || [ $i == "2021-06-22" ] || [ $i == "2021-06-23" ] || [ $i == "2021-06-24" ] || [ $i == "2021-06-25" ] || [ $i == "2021-06-26" ] || [ $i == "2021-06-27" ] || [ $i == "2021-06-28" ] || [ $i == "2021-06-29" ] || [ $i == "2021-06-30" ]
        then
                less /users/sthirumo/scripts/results/${calendarWeek}/performance_Metrics_${i}.csv | cut -d "," -f22 > cpu${i}.csv
        else

                less /users/sthirumo/scripts/results/${calendarWeek}/performance_Metrics_${i}.csv | cut -d "," -f21 > cpu${i}.csv
        fi
        python calculateMean.py cpu${i}.csv $jobCount CPU_Allocated ${i} >> mean_CPU.csv

        #cat mean_CPU_actual.csv | sed -r 's/(\w+)(.*)$/\1\|'"${i}"'\2/' >> mean_CPU.csv
        sleep 5
done

cat mean.csv
cat mean_CPU.csv

python newGraph.py mean.csv ${calendarWeek}.png "Average core_Wallclock Hrs-${calendarWeek}" "Average core Wall Clock Hrs" core_WallClock_Hrs JobCount combined
python newGraph.py mean_CPU.csv CPU_${calendarWeek}.png "Average CPU Requested-${calendarWeek}" "Average CPU Requested" CPU_Requested JobCount combined

#python generate_graph.py mean.csv CW${calendarWeek}.png "Average core_Wallclock Hrs-CW${calendarWeek}" "Average core Wall Clock Hrs"
#python generate_graph.py mean_CPU.csv CPU_CW${calendarWeek}.png "Average CPU Requested - CW${calendarWeek}" "Average CPU Requested"

cp ${calendarWeek}.png ${calendarWeek}/

cd /users/sthirumo/scripts/results/${calendarWeek}
mkdir data
cp performance_Metrics_* data/
zip -r data_${calendarWeek}.zip data/
cd -

sort -k1 -n -r -t, mean.csv > mean_Final.csv
sed -i 1i"core_WallClock_Hrs,JobCount,combined" mean_Final.csv

sort -k1 -n -r -t, mean_CPU.csv > mean_CPU_Final.csv
sed -i 1i"CPU_Requested,JobCount,combined" mean_CPU_Final.csv

#echo "This Data is for dates from Monday to Sunday in calendar week $calendarWeek" >> mean.csv
mail -a ${calendarWeek}.png -a /users/sthirumo/scripts/results/${calendarWeek}/data_${calendarWeek}.zip -s "Average Core Wall Clock Hours - ${calendarWeek}" aaa@gmail.com < "mean_Final.csv"

#echo "This Data is for dates from Monday to Sunday in calendar week $calendarWeek" >> mean_CPU.csv
mail -a CPU_${calendarWeek}.png -a /users/sthirumo/scripts/results/${calendarWeek}/data_${calendarWeek}.zip -s "Average CPU Requested [Nodes*Cores per Node] - ${calendarWeek}" aaa@gmail.com < "mean_CPU_Final.csv"


rm mean.csv,mean_actual.csv,mean_Final.csv,mean_CPU_Final.csv
rm "mean_CPU.csv",mean_CPU_actual.csv


for i in `cat dates.txt`
do
        rm ${i}.csv
        rm cpu${i}.csv
done

rm dates.txt
cd /users/sthirumo/scripts/results/${calendarWeek}
rm -rf data
rm data_${calendarWeek}.zip
cd -

mv ${calendarWeek}.png /users/sthirumo/scripts/results/${calendarWeek}/
mv CPU_${calendarWeek}.png /users/sthirumo/scripts/results/${calendarWeek}/
