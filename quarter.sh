#!/bin/bash

#startDir=$1
#endDir=$2

#for i in $(seq ${startDir} ${endDir})
#do
#       cd CW${i}
ls | grep "result_2021" > result.txt
ls | grep "performance_Metrics_2021" > performance.txt
#mv result_CW${i}.txt ..
#mv performance_CW${i}.txt ..
#cd ..

for j in `cat result.txt`
do
        cat $j >> result_quarterly.txt
done

for j in `cat performance.txt`
do
        cat $j >> performance_quarter.txt
done

#rm result_CW${i}.txt
#rm performance_CW${i}.txt
#done

grep -v "User,Job_id,College,Department,Core_Wall-Clock_Time" result_quarterly.txt > result_Quarterly.txt
sed  -i '1i User,Job_id,College,Department,Core_Wall-Clock_Time' result_Quarterly.txt

grep -v "User,Job_name,Partition,Job_id,Group,College,Department,Account,Node_Requested,Cores_Requested_Per_Node,Requested_Wall-Clock_Time,Jobs_Used_Wall-Clock_Time,Core_Wall-Clock_Time,Submit_Date,Submit_Time,Start_Date,Start_Time,End_Date,End_Time,Wait_Time(Seconds),CPU_Allocated,CPU_Used,Percentage_Of_CPU_Used,Memory_Requested,Memory_Utilized,Percentage_Of_Memory_Used,State" performance_quarter.txt > performance_Quarterly.txt

sed -i '1i User,Job_name,Partition,Job_id,Group,College,Department,Account,Node_Requested,Cores_Requested_Per_Node,Requested_Wall-Clock_Time,Jobs_Used_Wall-Clock_Time,Core_Wall-Clock_Time,Submit_Date,Submit_Time,Start_Date,Start_Time,End_Date,End_Time,Wait_Time(Seconds),CPU_Allocated,CPU_Used,Percentage_Of_CPU_Used,Memory_Requested,Memory_Utilized,Percentage_Of_Memory_Used,State' performance_Quarterly.txt

rm result_quarterly.txt performance_quarter.txt
