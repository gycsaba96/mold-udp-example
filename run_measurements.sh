

BG_TIME=240
IPERF_TIME=200
PING_COUNT=150
SLEEP_TIME=400

function build_p4_code
{
    make code-gen
    make build
}


function check_connection
{
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at 'while [ $(ping -c 5 192.168.11.1 | grep icmp_seq | grep -c time) -ne "5" ]; do echo wait; done'
}

function load_p4_code
{
    cd test.p4app
    /opt/netronome/p4/bin/rtecli -r englewood.ct.univie.ac.at design-load -f simple_router.nffw -p out/pif_design.json
    ssh -tt gycsaba96@englewood.ct.univie.ac.at sudo ./setupiface.sh
    cd ..
    check_connection
    echo '# CODE LOADED'
}

function start_iperf_server
{
    # $1: test case
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -i 10 -t $IPERF_TIME -u -s 192.168.11.1 > measurement_output/$1_iperf_server.log
    echo '# IPERF SERVER FINISHED'
}

function start_iperf_client
{
    # $1: test case
    # $2: background traffic
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -P 1 -b $2 -i 10 -t $IPERF_TIME -u -c 192.168.11.1 > measurement_output/$1_iperf_client.log
    echo '# IPERF CLIENT FINISHED'
}

function start_5g_bg
{
    # $1: test case
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -p 5555 -l 10000 -i 10 -t $BG_TIME -u -s 192.168.11.1 > measurement_output/$1_bgiperf_server1.log &
    sleep 1
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -p 5555 -l 10000 -P 1 -b 5g -i 10 -t $BG_TIME -u -c 192.168.11.1 > measurement_output/$1_bgiperf_client1.log 
    echo '# BG_STOPPED'
}

function start_8g_bg
{
    # $1: test case
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -p 5555 -l 10000 -i 10 -t $BG_TIME -u -s 192.168.11.1 > measurement_output/$1_bgiperf_server1.log &
    sleep 1
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -p 5555 -l 10000 -P 1 -b 8g -i 10 -t $BG_TIME -u -c 192.168.11.1 > measurement_output/$1_bgiperf_client1.log 
    echo '# BG_STOPPED'
}

function start_10g_bg
{
    # $1: test case
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -p 5555 -l 10000 -i 10 -t $BG_TIME -u -s 192.168.11.1 > measurement_output/$1_bgiperf_server1.log &
    sleep 1
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -p 5555 -l 10000 -P 1 -b 10g -i 10 -t $BG_TIME -u -c 192.168.11.1 > measurement_output/$1_bgiperf_client1.log 
    echo '# BG_STOPPED'
}

function start_12g_bg
{
    # $1: test case
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -p 5555 -l 10000 -i 10 -t $BG_TIME -u -s 192.168.11.1  > measurement_output/$1_bgiperf_server1.log  &
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -p 5556 -l 10000 -i 10 -t $BG_TIME -u -s 192.168.11.1  > measurement_output/$1_bgiperf_server2.log  &

    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -p 5555 -l 10000 -P 1 -b 6g -i 10 -t $BG_TIME -u -c 192.168.11.1  > measurement_output/$1_bgiperf_client1.log &
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -p 5556 -l 10000 -P 1 -b 6g -i 10 -t $BG_TIME -u -c 192.168.11.1  > measurement_output/$1_bgiperf_client2.log 
    echo '# BG_STOPPED'
}

function start_20g_bg
{
    # $1: test case
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -p 5555 -l 10000 -i 10 -t $BG_TIME -u -s 192.168.11.1  > measurement_output/$1_bgiperf_server1.log  &
    ssh -tt gycsaba96@englewood.ct.univie.ac.at iperf -p 5556 -l 10000 -i 10 -t $BG_TIME -u -s 192.168.11.1  > measurement_output/$1_bgiperf_server2.log  &

    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -p 5555 -l 10000 -P 1 -b 10g -i 10 -t $BG_TIME -u -c 192.168.11.1  > measurement_output/$1_bgiperf_client1.log &
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at iperf -p 5556 -l 10000 -P 1 -b 10g -i 10 -t $BG_TIME -u -c 192.168.11.1  > measurement_output/$1_bgiperf_client2.log 
    echo '# BG_STOPPED'
}

function start_pings
{
    # $1: test case
    sleep 20
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at ping -t 64  -i 0.200 -c $PING_COUNT 192.168.11.1 > measurement_output/$1_ping_original.log
    sleep 10
    ssh -tt gycsaba96@lakewood.ct.univie.ac.at ping -t 255 -i 0.200 -c $PING_COUNT 192.168.11.1 > measurement_output/$1_ping_autoresp.log
    echo '# PING FINISHED'
}

echo 'Make sure, that the P4RTE is up and running... (then press Enter)'
read

rm -r measurement_output
mkdir measurement_output

 # *** NO BACKGROUND TRAFFIC
 TEST_CASE='bg0'
 echo "~~~~~ $TEST_CASE ~~~~~"
 
 build_p4_code $TEST_CASE
 load_p4_code
 
 start_pings $TEST_CASE &
 
 sleep $SLEEP_TIME
 
 
 # *** 5Gbps BACKGROUND TRAFFIC
 TEST_CASE='bg5g'
 echo "~~~~~ $TEST_CASE ~~~~~"
 
 build_p4_code $TEST_CASE
 load_p4_code
 
 start_iperf_server $TEST_CASE &
 sleep 1
 start_iperf_client $TEST_CASE 5g &
 start_pings $TEST_CASE &
 
 sleep $SLEEP_TIME
 
 # *** 10Gbps BACKGROUND TRAFFIC
 TEST_CASE='bg10g'
 echo "~~~~~ $TEST_CASE ~~~~~"
 
 build_p4_code $TEST_CASE
 load_p4_code
 
 start_5g_bg $TEST_CASE &
 
 start_iperf_server $TEST_CASE &
 sleep 1
 start_iperf_client $TEST_CASE 5g &
 start_pings $TEST_CASE &
 
 sleep $SLEEP_TIME
 
 # *** 13Gbps BACKGROUND TRAFFIC
 TEST_CASE='bg13g'
 echo "~~~~~ $TEST_CASE ~~~~~"
 
 build_p4_code $TEST_CASE
 load_p4_code
 
 start_8g_bg $TEST_CASE &
 
 start_iperf_server $TEST_CASE &
 sleep 1
 start_iperf_client $TEST_CASE 5g &
 start_pings $TEST_CASE &
 
 sleep $SLEEP_TIME
 
 # *** 15Gbps BACKGROUND TRAFFIC
 TEST_CASE='bg15g'
 echo "~~~~~ $TEST_CASE ~~~~~"
 
 build_p4_code $TEST_CASE
 load_p4_code
 
 start_10g_bg $TEST_CASE &
 
 start_iperf_server $TEST_CASE &
 sleep 1
 start_iperf_client $TEST_CASE 5g &
 start_pings $TEST_CASE &
 
 sleep $SLEEP_TIME

# *** 17Gbps BACKGROUND TRAFFIC
TEST_CASE='bg17g'
echo "~~~~~ $TEST_CASE ~~~~~"

build_p4_code $TEST_CASE
load_p4_code

start_12g_bg $TEST_CASE &

start_iperf_server $TEST_CASE &
sleep 1
start_iperf_client $TEST_CASE 5g &
start_pings $TEST_CASE &

sleep $SLEEP_TIME

# *** 25Gbps BACKGROUND TRAFFIC

TEST_CASE='bg25g'
echo "~~~~~ $TEST_CASE ~~~~~"

build_p4_code $TEST_CASE
load_p4_code

start_20g_bg $TEST_CASE &

start_iperf_server $TEST_CASE &
sleep 1
start_iperf_client $TEST_CASE 5g &
start_pings $TEST_CASE &

sleep $SLEEP_TIME

echo "~~~~~~~~~~~ DONE ~~~~~~~~~~~"