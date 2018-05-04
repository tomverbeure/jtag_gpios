#!/usr/bin/env python3
"""
OpenOCD RPC example, covered by GNU GPLv3 or later
Copyright (C) 2014 Andreas Ortmann (ortmann@finf.uni-hannover.de)

Modified for jtag_gpios example
Copyright (C) 2018 Tom Verbeure

Example output:
./ocd_rpc_example.py
"""

import socket
import itertools

def strToHex(data):
    return map(strToHex, data) if isinstance(data, list) else int(data, 16)

def hexify(data):
    return "<None>" if data is None else ("0x%08x" % data)

def compareData(a, b):
    for i, j, num in zip(a, b, itertools.count(0)):
        if i != j:
            print("difference at %d: %s != %s" % (num, hexify(i), hexify(j)))


class OpenOcd:
    COMMAND_TOKEN = '\x1a'
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.tclRpcIp       = "127.0.0.1"
        self.tclRpcPort     = 6666
        self.bufferSize     = 4096

        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    def __enter__(self):
        self.sock.connect((self.tclRpcIp, self.tclRpcPort))
        return self

    def __exit__(self, type, value, traceback):
        try:
            self.send("exit")
        finally:
            self.sock.close()

    def send(self, cmd):
        """Send a command string to TCL RPC. Return the result that was read."""
        data = (cmd + OpenOcd.COMMAND_TOKEN).encode("utf-8")
        if self.verbose:
            print("<- ", data)

        self.sock.send(data)
        return self._recv()

    def _recv(self):
        """Read from the stream until the token (\x1a) was received."""
        data = bytes()
        while True:
            chunk = self.sock.recv(self.bufferSize)
            data += chunk
            if bytes(OpenOcd.COMMAND_TOKEN, encoding="utf-8") in chunk:
                break

        if self.verbose:
            print("-> ", data)

        data = data.decode("utf-8").strip()
        data = data[:-1] # strip trailing \x1a

        return data

    def readVariable(self, address):
        raw = self.send("ocd_mdw 0x%x" % address).split(": ")
        return None if (len(raw) < 2) else strToHex(raw[1])

    def readMemory(self, wordLen, address, n):
        self.send("array unset output") # better to clear the array before
        self.send("mem2array output %d 0x%x %d" % (wordLen, address, n))

        output = self.send("ocd_echo $output").split(" ")

        return [int(output[2*i+1]) for i in range(len(output)//2)]

    def writeVariable(self, address, value):
        assert value is not None
        self.send("mww 0x%x 0x%x" % (address, value))

    def writeMemory(self, wordLen, address, n, data):
        array = " ".join(["%d 0x%x" % (a, b) for a, b in enumerate(data)])

        self.send("array unset 1986ве1т") # better to clear the array before
        self.send("array set 1986ве1т { %s }" % array)
        self.send("array2mem 1986ве1т 0x%x %s %d" % (wordLen, address, n))

if __name__ == "__main__":

    def show(*args):
        print(*args, end="")

    with OpenOcd() as ocd:
        ocd.send("reset")

        show(ocd.send("ocd_echo \"Hello from RPC example!\"")[:-1])

        show(ocd.send("ocd_gpios settings 0 1"))
        show(ocd.send("ocd_gpios settings 1 1"))

        for _ in range(20):
            show(ocd.send("ocd_gpios set_pin 0 1"))
            show(ocd.send("ocd_gpios set_pin 1 0"))
            show(ocd.send("ocd_sleep 100"))
            show(ocd.send("ocd_gpios set_pin 0 0"))
            show(ocd.send("ocd_gpios set_pin 1 1"))
            show(ocd.send("ocd_sleep 100"))

        value = ocd.send("ocd_gpios get_pin 0")
        print(value)
            
