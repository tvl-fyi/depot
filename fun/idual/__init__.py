#!/usr/bin/env python
# -*- coding: utf-8 -*-

import base64
import broadlink
import time

commands = {
    # system commands
    'on'       : 'JgBIAAABK5AVERQ2FBEUERQSFBEUERQSFBEUNhQ2FDUUNhQ2FDYUNRU1FBIUERQRFBIUERQRFBIUERQ2FDYUNRQ2FDYUNhQ1FQANBQ==',
    'off'      : 'JgBIAAABLJAUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDUVNRQ2FDYUNhQRFDYUERQSFBEUERQSFBEUNhQRFDYUNhQ2FDUUNhQ2FAANBQ==',
    'darker'   : 'JgBIAAABLI8VERQ2FBEUERURFBEUEhQRFBEUNhQ2FDYUNRU1FDYUNhQRFBIUERQRFDYUEhQRFBEVNRQ2FDYUNhQRFDYUNhQ1FQANBQ==',
    'brighter' : 'JgBIAAABLI8VERQ2FBEUERQSFBEUEhQRFBEUNhQ2FDUVNRQ2FDYUNRU1FBIUERQ2FBEUEhQRFBEUEhQ1FTUUEhQ1FTUUNhQ2FAANBQ==',

    # presets
    'candle'   : 'JgBQAAABKZISExI4EhMSFBITEhQRFBITEhQROBI4EjgSOBE4EjgSOBI4ERQSExIUEjgRFBITEhQSExI4EjgROBIUEjcSOBI4EgAFJgABKUkSAA0FAAAAAAAAAAA=',
    'bulb'     : 'JgBYAAABK5AUERQ2FBEVERQRFBEVERQRFBEVNRQ2FDYUNRU1FDYUNhQRFDYUNRURFBEUEhQRFBEUNhQRFREUNhQ1FDYUNhQ2FAAFIwABKkgVAAxOAAErRxUADQU=',
    'sun'      : 'JgBQAAABLI8VERQ2FBEUERURFBEUEhQRFBEUNhQ2FDYUNRU1FTUUNhQSFDUUEhQ2FBEUERURFBEUNhQSFDUUEhQ2FDUVNRQ2FAAFJQABK0cVAA0FAAAAAAAAAAA=',
    'cold'     : 'JgBQAAABK5AUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDYUNRQ2FDYUNhQ1FTUUEhQRFBEUEhQRFBIUERQRFDYUNhQ2FDYUNRQ2FAAFJAABK0cVAA0FAAAAAAAAAAA=',
    'eve_dark' : 'JgBQAAABK5AUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDYUNRU1FDYUNhQRFDYUERQSFDUUEhQRFBIUNRQSFDUUNhQSFDUUNhQ2FAAFIwABLEYVAA0FAAAAAAAAAAA=',
    'eve_fade' : 'JgBIAAABK5AUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDYUNRQ2FDYUNhQ1FDYUNhQRFDYUERQSFBEUEhQRFBEUNhQSEzYUNhQ2FAANBQ==',
    'reading'  : 'JgBQAAABK5AUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDUVNRQ2FDYUNhQ1FDYUEhQ1FBIUERQRFBIUERQSFDUUEhQ1FTUUNhQ2FAAFJAABK0YVAA0FAAAAAAAAAAA=',
    'yoga'     : 'JgBYAAABLI8VERQ1FREUERQSFBEUERURFBEUNhQ1FTUUNhQ2FDYUNRURFBEUNhQRFBIUERMSExMTNxM2ExMTNxM2EzcTNxM3EwAFJQABKkgTAAxRAAErRxUADQU=',
    'morning'  : 'JgBQAAABK5AUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDUVNRQ2FDYUNRU1FDYUERURFDUVERQRFBIUERQRFTUUNhQRFDYUNhQ2FAAFIwABK0cVAA0FAAAAAAAAAAA=',
    'colours'  : 'JgBQAAABLI8VERQ2FBEUERQSFBEUERURFBEUNhQ1FTUUNhQ2FDYUNRQSFBEUERQ2FDYUERQSFBEUNhQ1FTUUEhQRFDYUNRU1FAAFJAABKkcVAA0FAAAAAAAAAAA=',
    'random'   : 'JgBQAAABK5AUEhQ1FREUERQSFBEUERQSExIUNhQ1EzcTNxM3EzYTNxMTEhMTNxM2ExMTEhMSExMTNxM2ExMTEhM3EzcTNhM3EwAFJQABK0cVAA0FAAAAAAAAAAA=',
    'island'   : 'JgBQAAABK5AUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDUVNRQ2FDYUNRU1FBIUNRURFBEUEhQRFBEUEhQ1FREUNhQ1FDYUNhQ2FAAFIwABK0cVAA0FAAAAAAAAAAA=',
    'forest'   : 'JgBQAAABK5AUEhQ1FREUERQSFBEUERQSFBEUNhQ1FTUUNhQ2FDUVNRQSFBEUNhQRFDYUERQSFBEUNhQ2FBEUNhQRFDYUNhQ1FQAFIwABK0cVAA0FAAAAAAAAAAA=',
    'ocean'    : 'JgBQAAABK5AUEhQ1FREUERQSFBEUERQRFREUNhQ1FTUUNhQ2FDUVNRQ2FBEUEhQ1FTUUEhQRFBEUEhQ1FTUUEhQRFDYUNRU1FAAFJAABK0cVAA0FAAAAAAAAAAA=',
    'fire'     : 'JgBQAAABK5AUERQ2FBEUEhQRFBEUEhQRFBEUNhQ2FDUVNRQ2FDYUNRU1FBIUNRU1FBIUERQRFBIUERQ2FBEUEhQ1FTUUNhQ2FAAFIwABLEYVAA0FAAAAAAAAAAA=',
    'love'     : 'JgBQAAABL5AUEhQ1FREUERQSFBEUERQSFBEUNhQ1FDYUNhQ2FDUVNRQSFDUUNhQSFBEUERQSFBEUNhQRFBIUNRQ2FDYUNhQ1FAAFJAABK0cVAA0FAAAAAAAAAAA=',

    # colour commands
    'red'        : 'JgBIAAABK5AUERQ2FBEUEhQRFBEVERQRFBEUNhQ2FDYUNRU1FDYUNhQRFDYUNhQ1FREUERQSFBEUNhQRFBIUERQ2FDUVNRQ2FAANBQ==',
    'yellow'     : 'JgBIAAABLI8UEhQ2FBEUERQSFBEUEhMSFBEUNhQ2FDUUNhQ2FDYUNRQ2FDYUNhQRFBIUERQRFBIUERQSExIUNhQ1FDYUNhQ2FAANBQ==',
    'green'      : 'JgBIAAABK5AUEhQ1FREUERQSFBEUERQSFBEUNhQ1FDYUNhQ2FDUVNRQSFBEUERQ2FBIUERQRFBIUNRU1FDYUERQ2FDYUNhQ1FQANBQ==',
    'blue'       : 'JgBIAAABK5AUERQ2FBEUEhQRFBITEhQRFBEUNhQ2FDYUNRQ2FDYUNhQ2ExIUNhQRFDYUERQSExIUERQ2FBEUNhQSEzYUNhQ2FAANBQ==',
    'saturate'   : 'JgBIAAABK5AUERQ2FBEUEhQRFBIUERQRFBEUNhQ2FDYUNRU1FDYUNhQRFDYUERQ2FDYUERQSFBEUNhQRFDYUERQSFDUUNhQ2FAANBQ==',
    'desaturate' : 'JgBIAAABLI8VERQ2FBEUERQSFBEUERURFBEUNhQ1FTUUNhQ2FDYUNRQ2FDYUNhQ1FREUERQSFBEUERQSFBEUERQ2FDYUNhQ1FQANBQ==',
}

class LightController:
    def __init__(self):
        devices = broadlink.discover(timeout=2, discover_ip_address='192.168.1.11')
        if devices == []:
            raise Exception('no devices found')
        devices[0].auth()
        self.device = devices[0]

    def send_cmd(self, name):
        packet = base64.b64decode(commands[name])
        self.device.send_data(packet)

    def lights_on(self):
        self.send_cmd('on')

    def lights_off(self):
        self.send_cmd('off')

if __name__ == "__main__":
    # Attempt to turn the lights on, in morning mode, 10 times.
    #
    # The command sending doesn't always work, hence this brute-force
    # approach.
    print('Initialising light controller')
    ctrl = LightController()

    print('Turning on the lights. Wakey, wakey!')
    for i in range(9):
        ctrl.send_cmd('morning')
        time.sleep(0.2)
        ctrl.lights_on()
        time.sleep(0.8)
