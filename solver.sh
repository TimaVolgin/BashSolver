#!/bin/bash

key1=$(tsk -k $1 2>&1 | grep Key | awk '{print $2}')

echo $key1

rm -f ~/-r

key2=$(tsk -s 1 -k $key1 -c 2>&1 | grep Key | awk '{print $2}')

echo $key2

for filename in /var/log/loggen/*.log
do
        while IFS=' ' read -r f1 f2 f3 file_name f5
        do
                if [[ $f1 = '[404]' ]]; then
                        permission=$(echo $f3 | sed 's/://1')
                        size=$(echo $f5 | sed 's/=//1')
                        sudo dd if=/dev/zero of=$file_name bs=$size count=1 status=none
                        sudo chmod $permission $file_name
                fi
        done < $filename
done

key3=$(tsk -s 2 -k $key2 -c 2>&1 | grep Key | awk '{print $2}')

echo $key3

PID=$(tsk -s 3 -k $key3 2>&1 | grep -m 1 -o 'PID=[[:digit:]]*' | cut -c5-)

# echo $PID

echo 'kill -s SIGUSR1 $1 && kill -s SIGUSR2 $1 && kill -s SIGINT $1' > solver_tmp.sh
chmod +x solver_tmp.sh
bash ./solver_tmp.sh $PID
rm -f solver_tmp.sh

ln -sf /var/log/challenge/* ~/

key4=$(tsk -s 3 -k $key3 -c 2>&1 | grep Key | awk '{print $2}')

echo $key4

request_id=$(tsk -s 4 -k $key4 2>&1 | grep -m 1 'X-Request-ID' | awk '{print $6}')
cred=$(curl -v --header "X-Request-ID:%{request_id}" localhost:9182/task1 2>&1 | grep -m 1 'X-Credentials:' | awk '{print $3}')
redirects_number=$(curl -L -v localhost:9182/task2  --form "credentials=${cred::-1}" 2>&1 | grep 307 -c)
curl -X DELETE localhost:9182/task3/$redirects_number --silent --output /dev/null

key5=$(tsk -s 4 -k $key4 -c 2>&1 | grep Key | awk '{print $2}')

echo $key5
