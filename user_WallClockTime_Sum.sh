#!/bin/bash
#currentDate=`date +%Y-%m-%d`
currentDate="Quarterly"
interval1="Quarterly"
#calendarWeek=`date +%U -d "1 week ago"`
calendarWeek="Quarterly"

for i in "$interval1"
do
        originalFile="result_${i}.txt"
        outputwith2clmns="user1_${i}.csv"
        output="user_${i}.csv"
        userList="user_list_${i}.txt"
        departmentList="Department_Finaldata_${i}.csv"
        CollegeList="College_Finaldata_${i}.csv"
        #startDate=`date +%Y-%m-%d -d "${i}"`

        tr ' ' ',' < "$originalFile" > "$outputwith2clmns"
        sed 's/^.//' "$outputwith2clmns" > "$output"
        awk -F, '{a[$1];}END{for (i in a)print i;}' "$output" > "$userList"

        awk -F, '{print $1","$NF}' "user_${i}.csv" > "user_Finaldata_${i}.csv"
        awk -F, '{print $(NF-1)","$NF}' "$originalFile" > "$departmentList"
        awk -F, '{print $(NF-2)","$NF}' "$originalFile" > "$CollegeList"

        sed -i 's/^,/Unknown,/g' "$departmentList"
        sed -i 's/^,/Unknown,/g' "$CollegeList"
        awk -F, '{a[$1];}END{for (i in a)print i;}' "Department_Finaldata_${i}.csv" > "Department_list_${i}.txt"
        awk -F, '{a[$1];}END{for (i in a)print i;}' "College_Finaldata_${i}.csv" > "College_list_${i}.txt"
        less "Department_list_${i}.txt" | cut -d '(' -f1 | awk '{$1=$1;print}' > "Department_list1_${i}.txt"
        less "College_list_${i}.txt" | cut -d '(' -f1 | awk '{$1=$1;print}' > "College_list1_${i}.txt"

        for j in `cat "$userList"`
        do
                VAR=$j
                awk -F, -v inp=$VAR '$1==inp{x+=$2;}END{print inp,x}' OFS=, "user_Finaldata_${i}.csv" >> "user_clock_hrs_${i}.csv"
        done

        awk -F, '{a[$1]+=$2;}END{for(i in a)print i", "a[i];}' OFS=, "Department_Finaldata_${i}.csv" >> "department_clock_hrs_${i}.csv"
        awk -F, '{a[$1]+=$2;}END{for(i in a)print i", "a[i];}' OFS=, "College_Finaldata_${i}.csv" >> "College_clock_hrs_${i}.csv"
        sed -i '/^Department\b/d' "department_clock_hrs_${i}.csv"
        grep -v "College," "College_clock_hrs_${i}.csv" > "College_clock_hrs_${i}1.csv"
        sort -k2 -n -t, "user_clock_hrs_${i}.csv" | tail -20 > "user_clock_hrs_data_${i}.csv"
        sort -k2 -n -t, "department_clock_hrs_${i}.csv" | tail -20 > "department_clock_hrs_data_${i}.csv"
        sort -k2 -n -t, "College_clock_hrs_${i}1.csv" | tail -20 > "College_clock_hrs_data_${i}.csv"
        sed -i -e 's/(Dpt)//g' "department_clock_hrs_data_${i}.csv"
        sed -i -e 's/(Col)//g' "College_clock_hrs_data_${i}.csv"

        rm "$outputwith2clmns" "$output" "$userList" "$departmentList" "$CollegeList" "user_Finaldata_${i}.csv" "Department_list_${i}.txt" "College_list_${i}.txt" "Department_list1_${i}.txt" "College_list1_${i}.txt" "user_clock_hrs_${i}.csv" "department_clock_hrs_${i}.csv" "College_clock_hrs_${i}.csv" "College_clock_hrs_${i}1.csv"

        sed -i 1i"Users,Hrs" /users/sthirumo/scripts/"user_clock_hrs_data_${i}.csv"
        sed -i 1i"College,Hrs" /users/sthirumo/scripts/"College_clock_hrs_data_${i}.csv"
        sed -i 1i"Department,Hrs" /users/sthirumo/scripts/"department_clock_hrs_data_${i}.csv"

        python newGraph.py /users/sthirumo/scripts/"user_clock_hrs_data_${i}.csv" /users/sthirumo/scripts/"TopUsers_${i}.png" "Top Users - Wallclock Hours" Users Users Hrs
        sleep 3

        python newGraph.py /users/sthirumo/scripts/"College_clock_hrs_data_${i}.csv" /users/sthirumo/scripts/"TopCollege_${i}.png" "Top College - Wallclock Hours" College College Hrs
        sleep 3

        python newGraph.py /users/sthirumo/scripts/"department_clock_hrs_data_${i}.csv" /users/sthirumo/scripts/"TopDepartment_${i}.png" "Top Department - Wallclock Hours" Department Department Hrs
        sleep 3

        mv "/users/sthirumo/scripts/result_${i}_user.csv" "/users/sthirumo/scripts/result_${currentDate}.csv"
        #sh finalReport.sh > Finalreport.csv

        mail -a "performance_Metrics_${currentDate}.csv" -a "highWastedCpuHrs_${currentDate}.csv" -a "lowCpuUtilization_${currentDate}.csv" -a "lowMemoryUtilization_${currentDate}.csv" -a "/users/sthirumo/scripts/"performance_Metrics_${currentDate}.csv"" -s "Performance Metrics ${currentDate} " sthirumo@uncc.edu < starlight_cluster_${currentDate}.txt

        mail -a "/users/sthirumo/scripts/TopUsers_${i}.png" -s "Top Utilization- Wall Clock Hours-Users-${currentDate}" sthirumo@uncc.edu < "user_clock_hrs_data_${i}.csv" < /dev/null
        sleep 2
        mail -a "/users/sthirumo/scripts/TopCollege_${i}.png" -s "Top Utilization- Wall Clock Hours-College-${currentDate}" sthirumo@uncc.edu < "College_clock_hrs_data_${i}.csv" < /dev/null
        sleep 2
        mail -a "/users/sthirumo/scripts/TopDepartment_${i}.png" -s "Top Utilization- Wall Clock Hours-Department-${currentDate}" sthirumo@uncc.edu < "department_clock_hrs_data_${i}.csv" < /dev/null

        mv /users/sthirumo/scripts/"result_${i}_user.txt" /users/sthirumo/scripts/results/CW${calendarWeek}/"result_${currentDate}.txt"
        rm "user_clock_hrs_data_${i}.csv" "College_clock_hrs_data_${i}.csv" "department_clock_hrs_data_${i}.csv"
done

rm lowCpuUtilization_${currentDate}.csv
        rm lowMemoryUtilization_${currentDate}.csv
        rm highCpuWaitTime_${currentDate}.csv
        rm memory.txt memoryf.txt memory1.csv memory2.csv memory3.csv
        #rm "performance_Metrics_${currentDate}.csv"
