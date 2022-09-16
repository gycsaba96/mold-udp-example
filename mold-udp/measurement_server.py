import socket
import struct
import threading
import time
import subprocess
import sys

MCAST_IP = '192.168.11.2'
MCAST_PORT = 5555

RETR_IP = '192.168.11.2'
RETR_PORT = 7777

SCENARIO = sys.argv[1]

def create_message_block(msg):
    return struct.pack('!H{}s'.format(len(msg)),len(msg),msg)

def pack_messages(session_id,start_seq_num,messages):
    msg_blocks = b''.join([ create_message_block(msg) for msg in messages  ])
    data = struct.pack('!10sQH{}s'.format(len(msg_blocks))
                        ,session_id
                        ,start_seq_num
                        ,len(messages)
                        ,msg_blocks)
    return data


class SimpleMoldUDPSrever:
    def __init__(self) -> None:
        # (not) multicast socket for broadcasting
        self.mcast = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.mcast.bind((MCAST_IP,MCAST_PORT))
    
        # unicast socket for retransmission
        self.retr = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.retr.bind((RETR_IP,RETR_PORT))

        # set internal state
        self.session_id=b'testdata  '
        self.next_id = 1
        self.messge_buffer = dict()

        # other technical variables 
        self.clients = []
        self.halt = False

    def send(self,messages,drop=False):
        data = pack_messages(b'testdata  ',self.next_id,messages)

        for msg in messages:
            print('#',self.next_id,msg)
            self.messge_buffer[self.next_id]=msg
            self.next_id+=1

        if not drop:
            for addr in self.clients:
                self.mcast.sendto(data,addr)

    def start_retransmitter(self):
        t = threading.Thread(target=self.run_retransmitter)
        t.start()

    def run_retransmitter(self):
        self.retr.settimeout(1)
        while not self.halt:
            try:
                data, addr = self.retr.recvfrom(256)
            except socket.timeout:
                continue

            if addr not in self.clients:
                self.clients.append(addr)
                continue

            _, first_id, count = struct.unpack('!10sQH',data)
            messages = []
            for seq_id in range(first_id,first_id+count):
                messages.append(self.messge_buffer[seq_id])

            self.retr.sendto(pack_messages(self.session_id,first_id,messages),addr)

        self.retr.close()

    def stop(self):
        self.halt=True
        self.mcast.close()


server = SimpleMoldUDPSrever()
server.start_retransmitter()

def start_tcpdump():
    subprocess.call('sudo true'.split())
    return subprocess.Popen('sudo tcpdump -w measurement_{}.pcap -i enp101s0np1 udp and port 5555 or 7777'.format(SCENARIO).split())

def send_packets():
    for i in range(100):
        server.send([('missing_'+str(i)).encode('utf-8')],drop=True)
        server.send([('data_'+str(i)).encode('utf-8')],drop=False)
        time.sleep(1)

while server.clients == []:
    time.sleep(1)
time.sleep(1)

tcpdump = start_tcpdump()
time.sleep(5)
send_packets()
time.sleep(5)

server.stop()