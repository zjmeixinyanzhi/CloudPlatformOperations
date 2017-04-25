#!/bin/sh
WHILE_FLAG=0

wait_start(){
  while [ $WHILE_FLAG -lt 20 ]
  do
    echo -ne "=>\033[s" 
    echo -ne "\033[40;-20H"$((WHILE_FLAG*5*100/100))%"\033[u\033[1D" 
    let WHILE_FLAG++
    sleep 2
  done
}
echo "Wait All Pcs Resource Start"
wait_start
