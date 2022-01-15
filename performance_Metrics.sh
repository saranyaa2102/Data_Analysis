#!/bin/bash

#currentDate=`date +%Y-%m-%d -d"yesterday"`
#i=`date +%Y-%m-%d -d"yesterday"`
currentDate="Quarterly"
i="Quarterly"

startTime="00:00:00"
endTime="23:59:59"
sacct -a -s COMPLETED --starttime=${currentDate}T${startTime} --endtime=${currentDate}T${endTime} -o jobid,state,start,end | sed '/\./d' | cut -d " " -f1 > /tmp/${currentDate}.txt
sed -i '/^$/d' /tmp/${currentDate}.txt
sed '1d' /tmp/${currentDate}.txt > /tmp/${currentDate}_2.txt
grep -v "+" /tmp/${currentDate}_2.txt > /tmp/${currentDate}_3.txt

jobcount=`less /tmp/${currentDate}_3.txt | wc -l`
echo $jobcount
sreport cluster utilization -t percent > starlight_cluster_${currentDate}.txt
rm /tmp/${currentDate}.txt
echo "User,Job_name,Partition,Job_id,Group,College,Department,Account,Node_Requested,Cores_Requested_Per_Node,Requested_Wall-Clock_Time,Jobs_Used_Wall-Clock_Time,Core_Wall-Clock_Time_Used(in Hrs),Core_Wall-ClockTime_Wasted(in Hrs),Submit_Date,Submit_Time,Start_Date,Start_Time,End_Date,End_Time,Wait_Time(Seconds),CPU_Allocated,CPU_Used,Percentage_Of_CPU_Used,Memory_Requested,Memory_Utilized,Percentage_Of_Memory_Used,State" >> result.txt

for item in `cat /tmp/${currentDate}_3.txt`
do
       Job_Id=$item
        Job_name=`sacct --jobs=$item | sed '/\./d' | awk {'print $2'} | tail -n1`
        user=`seff $item | grep User | cut -d ':' -f2 | cut -d '/' -f1`
        group=`seff $item | grep User | cut -d ':' -f2 | cut -d '/' -f2`
        state=`sacct --jobs=$item | sed '/\./d' | awk {'print $6'} | tail -n1`
        partition=`sacct --jobs=$item | sed '/\./d' | awk {'print $3'} | tail -n1`
        account=`sacct --jobs=$item | sed '/\./d' | awk {'print $4'} | tail -n1`
        nodeRequested=`sacct -j $item -o NNodes | sed '/\./d' | awk 'NR==3{print $1; exit}'`
        coresRequestedPerNode=`seff $item | grep Cores | cut -d ":" -f2`
        wallClockTimeToCompleteJob=`seff $item | grep "Wall-clock time" | cut -d " " -f4`
        Requested_Wall_clock_Time=`sacct -j $item -o TimeLimit | awk 'NR==3{print $1; exit}'`
        cpuHrsUtilized=`seff $item | grep "CPU Utilized:" | cut -d " " -f3 | cut -d "-" -f1 | wc -l`
        memoryUtilized=`seff $item | grep "Memory Utilized" | cut -d "%" -f2 | cut -d ":" -f2`
        memoryRequested=`seff $item | grep "Memory Efficiency" | cut -d ":" -f2 | cut -d "f" -f2`
        percentageOfMemoryUtilized=`seff $item | grep "Memory Efficiency" | cut -d ":" -f2 | cut -d "%" -f1`
        CPUAllocated=`sacct -j $item -o NCPUS | sed '/\./d' | awk 'NR==3{print $1; exit}' | xargs`
        PercentageOfCpuUSed=`seff $item | grep "CPU Efficiency" | cut -d ":" -f2 | cut -d "%" -f1 | cut -d "." -f1 | xargs`
        College=`less org.txt | grep $user | cut -d "|" -f3`
        Department=`less org.txt | grep $user | cut -d "|" -f4`
        part1=$((CPUAllocated*PercentageOfCpuUSed))
        CPU_Used=$(echo "scale=2;$part1 / 100" | bc -l)
        StartTime=`sacct -j $item -o JobId,submit,start,end,state | sed '/\./d' | awk {'print $3'} | cut -d "T" -f2 | tail -n1`
        SubmitTime=`sacct -j $item -o JobId,submit,start,end,state | sed '/\./d' | awk {'print $2'} | cut -d "T" -f2 | tail -n1`
        Endtime=`sacct -j $item -o JobId,submit,start,end,state | sed '/\./d' | awk {'print $4'} | cut -d "T" -f2 | tail -n1`
        SubmitDate=`sacct -j $item -o JobId,submit,start,end,state | sed '/\./d' | awk {'print $2'} | cut -d "T" -f1 | tail -n1`


        if [ $Endtime == "Unknown" ] && [ $StartTime == "Unknown" ]
        then
                StartTime="Job is in Pending State. No StartTime Available right now"
                StartDate="Job is in Pending State. No Start Date  Available right now"
                Endtime="Job is in Pending State. No End Time / End Date Available right now"
                EndDate="Job is in Pending State. No End Time / End Date Available right now"
                WaitTime="NIL"
                WaitDate="NIL"

        elif [ $Endtime == "Unknown" ]
        then

                StartDate=`sacct -j $item -o JobId,submit,start,end,state | sed '/\./d' | awk {'print $3'} | cut -d "T" -f1 | tail -n1`
                Endtime="Job is in Running  State. No End Time / End Date Available right now"
                EndDate="Job is in Running State. No End Time / End Date Available right now"
                SEC1=`date +%s -d ${SubmitTime}`
                SEC2=`date +%s -d ${StartTime}`
                DIFFSEC=`expr ${SEC2} - ${SEC1}`
                WaitTime=`echo ${DIFFSEC} | sed 's/-//g'`
                echo $WaitTime
                WaitDate=$(($((`date +%s -d $StartDate`-`date +%s -d $SubmitDate`))/86400))

        else

                StartDate=`sacct -j $item -o JobId,submit,start,end,state | sed '/\./d' | awk {'print $3'} | cut -d "T" -f1 | tail -n1`
                EndDate=`sacct -j $item -o JobId,submit,start,end,state | sed '/\./d' | awk {'print $4'} | cut -d "T" -f1 | tail -n1`
                SEC1=`date +%s -d ${SubmitTime}`
                SEC2=`date +%s -d ${StartTime}`
                DIFFSEC=`expr ${SEC2} - ${SEC1}`
                WaitTime=`echo ${DIFFSEC} | sed 's/-//g'`
                echo $WaitTime
                WaitDate=$(($((`date +%s -d $StartDate`-`date +%s -d $SubmitDate`))/86400))

        fi

                isNodePresent=`seff $item | grep "Nodes" | cut -d " " -f2 | wc -l`

                if [ $isNodePresent -eq 0 ]
                then
                        totalCPU=`seff $item | grep "Cores:" | cut -d " " -f2`
                else
                        Node=`seff $item | grep "Nodes" | cut -d " " -f2`
                        coresPerNode=`seff $item | grep "node:" | cut -d " " -f4`
                        totalCPU=$((${Node}*${coresPerNode}))
                fi

                user=`seff $item | grep User | cut -d ':' -f2 | cut -d '/' -f1`
                wallClockTimeToCompleteJob=`seff $item | grep "Wall-clock time" | cut -d " " -f4`
                checkForDays=`echo "$wallClockTimeToCompleteJob" | grep - | wc -l`

                if [ $checkForDays -gt 0 ]
                then
                        days=`echo $wallClockTimeToCompleteJob | cut -d "-" -f1`
                        daystohr=`echo $((${days#0}*24))`

                else
                        days=0
                        daystohr=0

                fi

                hrs=`echo $wallClockTimeToCompleteJob | cut -d ":" -f1 | cut -d "-" -f2`
                mins=`echo $wallClockTimeToCompleteJob | cut -d ":" -f2 | cut -d "-" -f2`
                sec=`echo $wallClockTimeToCompleteJob | cut -d ":" -f3 | cut -d "-" -f2`
                echo $wallClockTimeToCompleteJob
                echo "days:  ${days#0}"
                echo ${hrs#0}
                echo ${mins#0}
                echo ${sec#0}

                echo "in sec"
                sectohr=`echo $((${sec#0}/3600))`
                mintohr=`echo $((${mins#0}/60))`
                #hrstosec=`echo $((${hrs#0}*3600))`

                jobWallClockInhr=$((${sectohr}+${mintohr}+${hrs#0}+${daystohr}))
                coreWallClockHrs=$((${totalCPU#0}*${jobWallClockInhr}))
                echo $sectohr,$mintohr,$hrs,$daystohr,$coreWallClockHrs

                memoryUtilized=`seff $item | grep "Memory Utilized" | cut -d "%" -f2 | cut -d ":" -f2 | cut -d " " -f2,3`
                isMB=`echo $memoryUtilized | cut -d " " -f2`

                val1=$(bc <<< "scale=2;100*($CPU_Used)")
                val2=$(bc <<< "scale=2;100*($CPUAllocated)")
                cpuDiff=$(bc <<< "$val2-$val1")
                cpuDiffDecimal=$(bc <<< "scale=2;$cpuDiff/100")
                clockHrsWasted=$(bc <<< "scale=2;${cpuDiffDecimal}*${coreWallClockHrs}")
                echo "wasted $clockHrsWasted"

        echo "$user,$Job_name,$partition,$Job_Id,$group,$College,$Department,$account,$nodeRequested,$coresRequestedPerNode,$Requested_Wall_clock_Time,$wallClockTimeToCompleteJob,$coreWallClockHrs,$clockHrsWasted,$SubmitDate,$SubmitTime,$StartDate,$StartTime,$EndDate,$Endtime,$WaitDate days $WaitTime sec,$CPUAllocated,$CPU_Used,$PercentageOfCpuUSed,$memoryRequested,$memoryUtilized,$percentageOfMemoryUtilized,$state" >> result.txt
        sleep 1
done

        mv result.txt "performance_Metrics_${currentDate}.csv"
        calendarWeek=`date +%U`
        mkdir /users/sthirumo/scripts/results/CW${calendarWeek}
        cp "performance_Metrics_${currentDate}.csv" /users/sthirumo/scripts/results/CW${calendarWeek}

#       i="todays"
        less "performance_Metrics_${currentDate}.csv" | cut -d "," -f1,4,6,7,13 > "result_${i}_user.txt"
        cp "result_${i}_user.txt" "result_${i}_user.csv"

        originalFile="result_${i}_user.txt"
        outputwith2clmns="user1_${i}.csv"
        output="user_${i}.csv"
        userList="user_list_${i}.txt"
        departmentList="Department_Finaldata_${i}.csv"
        CollegeList="College_Finaldata_${i}.csv"

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

        #echo "users,core_WallClock_Hrs" > "user_clock_hrs_data_${i}.csv"
        #echo "Department,core_WallClock_Hrs" > "department_clock_hrs_data_${i}.csv"
        #echo "College,core_WallClock_Hrs" > "College_clock_hrs_data_${i}.csv"

        sort -k2 -n -t, "user_clock_hrs_${i}.csv" | tail -20 >> "user_clock_hrs_data_${i}.csv"
        sort -k2 -n -t, "department_clock_hrs_${i}.csv" | tail -20 >> "department_clock_hrs_data_${i}.csv"
        sort -k2 -n -t, "College_clock_hrs_${i}1.csv" | tail -20 >> "College_clock_hrs_data_${i}.csv"
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

        echo "Reached send mail step"
       mail -a "TopUsers_${i}.png" -s "Top Utilization- Wall Clock Hours-Users-${currentDate}" sthirumo@uncc.edu,cmaher9@uncc.edu < /dev/null
        sleep 2
        mail -a "TopCollege_${i}.png" -s "Top Utilization- Wall Clock Hours-College-${currentDate}" sthirumo@uncc.edu,cmaher9@uncc.edu < /dev/null
        sleep 2
        mail -a "TopDepartment_${i}.png" -s "Top Utilization- Wall Clock Hours-Department-${currentDate}" sthirumo@uncc.edu,cmaher9@uncc.edu < /dev/null

        mv /users/sthirumo/scripts/"result_${i}_user.txt" /users/sthirumo/scripts/results/CW${calendarWeek}/"result_${currentDate}.txt"

       rm "TopUsers_${i}.png" "TopCollege_${i}.png" "TopDepartment_${i}.png" "result_${currentDate}.csv" "user_clock_hrs_data_${i}.csv" "College_clock_hrs_data_${i}.csv" "department_clock_hrs_data_${i}.csv"
        sleep 3

        less performance_Metrics_${currentDate}.csv | cut -d "," -f1,4,23 > cpu.txt
        sed '1d' cpu.txt > cpuF.txt
        sed 's/^.//' cpuF.txt > cpu1.txt
        mv cpu1.txt cpu1.csv
        sort -t"," -k3,3n cpu1.csv > cpu2.csv
        head -n 10 cpu2.csv | cut -d "," -f2 > cpu3.csv
        echo "User,Job_name,Partition,Job_id,Group,College,Department,Account,Node_Requested,Cores_Requested_Per_Node,Requested_Wall-Clock_Time,Jobs_Used_Wal-Clock_Time,Core_Wall-Clock_Time_Used(in Hrs),Core_Wall-ClockTime_Wasted(in Hrs),Submit_Date,Submit_Time,Start_Date,Start_Time,End_Date,End_Time,Wait_Time(Seconds),CPU_Allocated,CPU_Used,Percentage_Of_CPU_Used,Memory_Requested,Memory_Utilized,Percentage_Of_Memory_Used,State" >> lowCpuUtilization_${currentDate}.csv
        for i in `cat cpu3.csv`
        do
                less performance_Metrics_${currentDate}.csv | grep $i >> lowCpuUtilization_${currentDate}.csv
        done

        rm cpu.txt cpuF.txt cpu1.csv cpu2.csv cpu3.csv

        ####################################################

        less performance_Metrics_${currentDate}.csv | cut -d "," -f1,4,26 > memory.txt
        sed '1d' memory.txt > memoryf.txt
        sed 's/^.//' memoryf.txt > memory1.txt
        mv memory1.txt memory1.csv
        sort -t"," -k3,3n memory1.csv > memory2.csv
        head -n 10 memory2.csv | cut -d "," -f2 > memory3.csv

        echo "User,Job_name,Partition,Job_id,Group,College,Department,Account,Node_Requested,Cores_Requested_Per_Node,Requested_Wall-Clock_Time,Jobs_Used_Wal-Clock_Time,Core_Wall-Clock_Time_Used(in Hrs),Core_Wall-ClockTime_Wasted(in Hrs),Submit_Date,Submit_Time,Start_Date,Start_Time,End_Date,End_Time,Wait_Time(Seconds),CPU_Allocated,CPU_Used,Percentage_Of_CPU_Used,Memory_Requested,Memory_Utilized,Percentage_Of_Memory_Used,State" >> lowMemoryUtilization_${currentDate}.csv

        for i in `cat memory3.csv`
        do
                less performance_Metrics_${currentDate}.csv | grep $i >> lowMemoryUtilization_${currentDate}.csv
        done

        ######################################################

        less performance_Metrics_${currentDate}.csv | cut -d "," -f1,4,14 > wastedCoreTime.txt
        sed '1d' wastedCoreTime.txt > wastedCoreTimef.txt
        sed 's/^.//' wastedCoreTimef.txt > wastedCoreTime1.txt
        mv wastedCoreTime1.txt wastedCoreTime1.csv
        sort -t"," -k3,3n wastedCoreTime1.csv > wastedCoreTime2.csv
        tail -n 10 wastedCoreTime2.csv | cut -d "," -f2 > wastedCoreTime3.csv

echo "User,Job_name,Partition,Job_id,Group,College,Department,Account,Node_Requested,Cores_Requested_Per_Node,Requested_Wall-Clock_Time,Jobs_Used_Wal-Clock_Time,Core_Wall-Clock_Time_Used(in Hrs),Core_Wall-ClockTime_Wasted(in Hrs),Submit_Date,Submit_Time,Start_Date,Start_Time,End_Date,End_Time,Wait_Time(Seconds),CPU_Allocated,CPU_Used,Percentage_Of_CPU_Used,Memory_Requested,Memory_Utilized,Percentage_Of_Memory_Used,State" >> highWastedCpuHrs_${currentDate}.csv

        for i in `cat wastedCoreTime3.csv`
        do
                less performance_Metrics_${currentDate}.csv | grep $i >> highWastedCpuHrs_${currentDate}.csv
        done
        rm wastedCoreTime.txt wastedCoreTimef.txt wastedCoreTime1.txt wastedCoreTime1.csv wastedCoreTime2.csv wastedCoreTime3.csv

        #######################################################

        
        rm lowCpuUtilization_${currentDate}.csv
        rm lowMemoryUtilization_${currentDate}.csv
        rm highCpuWaitTime_${currentDate}.csv
        rm memory.txt memoryf.txt memory1.csv memory2.csv memory3.csv
        rm "performance_Metrics_${currentDate}.csv"
        rm highWastedCpuHrs_${currentDate}.csv
        mv starlight_cluster_${currentDate}.txt /users/sthirumo/scripts/results/starlight/
