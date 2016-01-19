#!/usr/bin/env ruby

require 'optparse'
require 'json'
require 'socket'
require 'stringio'

### Global Parameters

$json = false
$csv = false
$csv_no_header = false
$file = false

### Global Variables

$ios_values = {}
$jira_custom_fields_values_map = {}
$headers = ""
$values = ""
$user = ENV['USER']
$hostname = Socket.gethostname
$ip = Socket.ip_address_list[4].ip_address

### IOS Device Map Hash. Matches Product Type and the "human known iOS Name"
$ios_device_map = {
    'iPhone1,1'	=> 'iPhone',
    'iPhone1,2'	=> 'iPhone 3G',
    'iPhone2,1'	=> 'iPhone 3GS',
    'iPhone3,1'	=> 'iPhone 4 (GSM)',
    'iPhone3,3'	=> 'iPhone 4 (CDMA)',
    'iPhone4,1'	=> 'iPhone 4S',
    'iPhone5,1'	=> 'iPhone 5 (A1428)',
    'iPhone5,2'	=> 'iPhone 5 (A1429)',
    'iPhone5,3'	=> 'iPhone 5c (A1456/A1532)',
    'iPhone5,4'	=> 'iPhone 5c (A1507/A1516/A1529)',
    'iPhone6,1'	=> 'iPhone 5s (A1433/A1453)',
    'iPhone6,2'	=> 'iPhone 5s (A1457/A1518/A1530)',
    'iPhone7,1'	=> 'iPhone 6 Plus',
    'iPhone7,2'	=> 'iPhone 6',
    'iPad1,1' => 'iPad',
    'iPad2,1' => 'iPad 2 (Wi-Fi)',
    'iPad2,2' => 'iPad 2 (GSM)',
    'iPad2,3' => 'iPad 2 (CDMA)',
    'iPad2,4' => 'iPad 2 (Wi-Fi, revised)',
    'iPad2,5' => 'iPad mini (Wi-Fi)',
    'iPad2,6' => 'iPad mini (A1454)',
    'iPad2,7' => 'iPad mini (A1455)',
    'iPad3,1' => 'iPad (3rd gen, Wi-Fi)',
    'iPad3,2' => 'iPad (3rd gen, Wi-Fi+LTE Verizon)',
    'iPad3,3' => 'iPad (3rd gen, Wi-Fi+LTE AT&T)',
    'iPad3,4' => 'iPad (4th gen, Wi-Fi)',
    'iPad3,5' => 'iPad (4th gen, A1459)',
    'iPad3,6' => 'iPad (4th gen, A1460)',
    'iPad4,1' => 'iPad Air (Wi-Fi)',
    'iPad4,2' => 'iPad Air (Wi-Fi+LTE)',
    'iPad4,3' => 'iPad Air (Rev)',
    'iPad4,4' => 'iPad mini 2 (Wi-Fi)',
    'iPad4,5' => 'iPad mini 2 (Wi-Fi+LTE)',
    'iPad4,6' => 'iPad mini 2 (Rev)',
    'iPad4,7' => 'iPad mini 3 (Wi-Fi)',
    'iPad4,8' => 'iPad mini 3 (A1600)',
    'iPad4,9' => 'iPad mini 3 (A1601)',
    'iPad5,3' => 'iPad Air 2 (Wi-Fi)',
    'iPad5,4' => 'iPad Air 2 (Wi-Fi+LTE)',
    'iPod1,1' => 'iPod touch',
    'iPod2,1' => 'iPod touch (2nd gen)',
    'iPod3,1' => 'iPod touch (3rd gen)',
    'iPod4,1' => 'iPod touch (4th gen)',
    'iPod5,1' => 'iPod touch (5th gen)',
}

$ios_device_specs = {
    'iPhone8,1' => {
        'Device Name' => 'iPhone 6s',
        'Manufacturing Year' => 2015,
        'SoC' => 'Apple A9',
        'RAM' => 2048,
        'RAM Speed | Type' => 'LPDDR4',
        'CPU Model' => 'Enhaced Cyclone',
        'CPU Arch' => 'ARMv9',
        'CPU Cores' => 2,
        'CPU Speed' => 1800,
        'GPU' => 'PowerVR GT7600',
        'GPU Cores' => 6,
        'GPU Speed' => '',
        'Display Resolution' => '1334x750',
        'DPI' => 326,
        'Display Size' => 4.7,
        'Motion Sensor' => 'M9',
        'Front Camera' => '5 MP - 1080P@30fps - 720p@30fps - face detection - HDR',
        'Rear Camera' => '12 MP - 4608 x 2592 pixels - phase detection autofocus - 4k Video - dual-LED (dual tone) flash',
        'Battery Capacity' => '1715',
        'Bluetooth Version' => '4.2',
        'Touch ID' => 'yes',
    },
    'iPhone8,2' => {
        'Device Name' => 'iPhone 6s Plus',
        'Manufacturing Year' => 2015,
        'SoC' => 'Apple A9',
        'RAM' => 2048,
        'RAM Speed | Type' => 'LPDDR4',
        'CPU Model' => 'Enhaced Cyclone',
        'CPU Arch' => 'ARMv9',
        'CPU Cores' => 2,
        'CPU Speed' => 1800,
        'GPU' => 'PowerVR GT7600',
        'GPU Cores' => 6,
        'GPU Speed' => '1800',
        'Display Resolution' => '1920x1080',
        'DPI' => 401,
        'Display Size' => 5.5,
        'Motion Sensor' => 'M9',
        'Front Camera' => '5 MP - 1080P@30fps - 720p@30fps - face detection - HDR',
        'Rear Camera' => '12 MP - 4608 x 2592 pixels - phase detection autofocus - 4k Video - dual-LED (dual tone) flash',
        'Battery Capacity' => '2750',
        'Bluetooth Version' => '4.2',
        'Touch ID' => 'yes',
    },
    'iPhone7,1' => {
        'Device Name' => 'iPhone 6 Plus',
        'Manufacturing Year' => 2014,
        'SoC' => 'Apple A8',
        'RAM' => 1024,
        'RAM Speed | Type' => '',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR GX6450',
        'GPU Cores' => 4,
        'GPU Speed' => 450,
        'Display Resolution' => '1920x1080',
        'DPI' => 401,
        'Display Size' => 5.5,
        'Motion Sensor' => 'M8',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@60fps, 720p@240fps - 3264 x 2448 - optical image stabilization - phase detection autofocus - dual-LED (dual tone) flash',
        'Battery Capacity' => '2915',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPhone7,2' => {
        'Device Name' => 'iPhone 6',
        'Manufacturing Year' => 2014,
        'SoC' => 'Apple A8',
        'RAM' => 1024,
        'RAM Speed | Type' => '',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR GX6450',
        'GPU Cores' => 4,
        'GPU Speed' => 450,
        'Display Resolution' => '1334x750',
        'DPI' => 326,
        'Display Size' => 4.7,
        'Motion Sensor' => 'M8',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@60fps, 720p@240fps - 3264 x 2448 - phase detection autofocus - dual-LED (dual tone) flash',
        'Battery Capacity' => '1810',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPhone6,1' => {
        'Device Name' => 'iPhone 5s',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR GX6430',
        'GPU Cores' => 4,
        'GPU Speed' => 300,
        'Display Resolution' => '1136x640',
        'DPI' => 326,
        'Display Size' => 4,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps, 720p@120fps - 3264 x 2448 - dual-LED (dual tone) flash',
        'Battery Capacity' => '1560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPhone6,2' => {
        'Device Name' => 'iPhone 5s',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR GX6430',
        'GPU Cores' => 4,
        'GPU Speed' => 300,
        'Display Resolution' => '1136x640',
        'DPI' => 326,
        'Display Size' => 4,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps, 720p@120fps - 3264 x 2448 - dual-LED (dual tone) flash',
        'Battery Capacity' => '1560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPhone6,3' => {
        'Device Name' => 'iPhone 5s',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR GX6430',
        'GPU Cores' => 4,
        'GPU Speed' => 300,
        'Display Resolution' => '1136x640',
        'DPI' => 326,
        'Display Size' => 4,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps, 720p@120fps - 3264 x 2448 - dual-LED (dual tone) flash',
        'Battery Capacity' => '1560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPhone5,3' => {
        'Device Name' => 'iPhone 5c',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A6',
        'RAM' => 1024,
        'RAM Speed | Type' => '533',
        'CPU Model' => 'Swift',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR SGX543MP3',
        'GPU Cores' => 3,
        'GPU Speed' => 266,
        'Display Resolution' => '1136x640',
        'DPI' => 326,
        'Display Size' => 4,
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps - 3264 x 2448 - LED flash',
        'Battery Capacity' => '1510',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
    },
    'iPhone5,4' => {
        'Device Name' => 'iPhone 5c',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A6',
        'RAM' => 1024,
        'RAM Speed | Type' => '533',
        'CPU Model' => 'Swift',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR SGX543MP3',
        'GPU Cores' => 3,
        'GPU Speed' => 266,
        'Display Resolution' => '1136x640',
        'DPI' => 326,
        'Display Size' => 4,
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps - 3264 x 2448 - LED flash',
        'Battery Capacity' => '1510',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPhone5,2' => {
        'Device Name' => 'iPhone 5',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A6',
        'RAM' => 1024,
        'RAM Speed | Type' => '533',
        'CPU Model' => 'Swift',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR SGX543MP3',
        'GPU Cores' => 3,
        'GPU Speed' => 266,
        'Display Resolution' => '1136x640',
        'DPI' => 326,
        'Display Size' => 4,
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps - 3264 x 2448 - LED flash',
        'Battery Capacity' => '1440',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPhone5,1' => {
        'Device Name' => 'iPhone 5',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A6',
        'RAM' => 1024,
        'RAM Speed | Type' => '533',
        'CPU Model' => 'Swift',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR SGX543MP3',
        'GPU Cores' => 3,
        'GPU Speed' => 266,
        'Display Resolution' => '1136x640',
        'DPI' => 326,
        'Display Size' => 4,
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps - 3264 x 2448 - LED flash',
        'Battery Capacity' => '1440',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPhone4,1' => {
        'Device Name' => 'iPhone 4s',
        'Manufacturing Year' => 2011,
        'SoC' => 'Apple A5',
        'RAM' => 512,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 2,
        'CPU Speed' => 800,
        'GPU' => 'PowerVR SGX543MP2',
        'GPU Cores' => 2,
        'GPU Speed' => 250,
        'Display Resolution' => '960x640',
        'DPI' => 326,
        'Display Size' => 3.5,
        'Front Camera' => '480p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps - 3264 x 2448 - LED flash',
        'Battery Capacity' => '1432',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPhone3,1' => {
        'Device Name' => 'iPhone 4',
        'Manufacturing Year' => 2010,
        'SoC' => 'Apple A4',
        'RAM' => 512,
        'RAM Speed | Type' => '200',
        'CPU Model' => 'ARM Cortex-A8',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 1,
        'CPU Speed' => 800,
        'GPU' => 'PowerVR SGX535',
        'GPU Cores' => 1,
        'GPU Speed' => 200,
        'Display Resolution' => '960x640',
        'DPI' => 326,
        'Display Size' => 3.5,
        'Front Camera' => '480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 720p@30fps - 2592 x 1936 - LED flash',
        'Battery Capacity' => '1420',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPhone3,2' => {
        'Device Name' => 'iPhone 4',
        'Manufacturing Year' => 2010,
        'SoC' => 'Apple A4',
        'RAM' => 512,
        'RAM Speed | Type' => '200',
        'CPU Model' => 'ARM Cortex-A8',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 1,
        'CPU Speed' => 800,
        'GPU' => 'PowerVR SGX535',
        'GPU Cores' => 1,
        'GPU Speed' => 200,
        'Display Resolution' => '960x640',
        'DPI' => 326,
        'Display Size' => 3.5,
        'Front Camera' => '480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 720p@30fps - 2592 x 1936 - LED flash',
        'Battery Capacity' => '1420',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPhone3,3' => {
        'Device Name' => 'iPhone 4',
        'Manufacturing Year' => 2010,
        'SoC' => 'Apple A4',
        'RAM' => 512,
        'RAM Speed | Type' => '200',
        'CPU Model' => 'ARM Cortex-A8',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 1,
        'CPU Speed' => 800,
        'GPU' => 'PowerVR SGX535',
        'GPU Cores' => 1,
        'GPU Speed' => 200,
        'Display Resolution' => '960x640',
        'DPI' => 326,
        'Display Size' => 3.5,
        'Front Camera' => '480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 720p@30fps - 2592 x 1936 - LED flash',
        'Battery Capacity' => '1420',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPhone2,1' => {
        'Device Name' => 'iPhone 3GS',
        'Manufacturing Year' => 2009,
        'SoC' => 'Samsung S5PC100',
        'RAM' => 256,
        'RAM Speed | Type' => '200',
        'CPU Model' => 'ARM Cortex-A8',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 1,
        'CPU Speed' => 600,
        'GPU' => 'PowerVR SGX535',
        'GPU Cores' => 1,
        'GPU Speed' => 150,
        'Display Resolution' => '480x320',
        'DPI' => 163,
        'Display Size' => 3.5,
        'Rear Camera' => '3MP 480p@30fps - LED flash',
        'Battery Capacity' => '1420',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    ### IPad
    'iPad5,4' => {
        'Device Name' => 'iPad Air 2',
        'Manufacturing Year' => 2014,
        'SoC' => 'Apple A8X',
        'RAM' => 2048,
        'RAM Speed | Type' => '',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 3,
        'CPU Speed' => 1500,
        'GPU' => 'PowerVR GXA6850',
        'GPU Cores' => 8,
        'GPU Speed' => '',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Motion Sensor' => 'M8',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps 720p@120fps - 3264 x 2448 - HDR',
        'Battery Capacity' => '7340',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPad5,3' => {
        'Device Name' => 'iPad Air 2',
        'Manufacturing Year' => 2014,
        'SoC' => 'Apple A8X',
        'RAM' => 2048,
        'RAM Speed | Type' => '',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 3,
        'CPU Speed' => 1500,
        'GPU' => 'PowerVR GXA6850',
        'GPU Cores' => 8,
        'GPU Speed' => '',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Motion Sensor' => 'M8',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '8 MP - 1080p@30fps 720p@120fps - 3264 x 2448 - HDR',
        'Battery Capacity' => '7340',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPad4,9' => {
        'Device Name' => 'iPad Mini 3',
        'Manufacturing Year' => 2014,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 326,
        'Display Size' => 7.9,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '6470',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPad4,8' => {
        'Device Name' => 'iPad Mini 3',
        'Manufacturing Year' => 2014,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 326,
        'Display Size' => 7.9,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '6470',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPad4,7' => {
        'Device Name' => 'iPad Mini 3',
        'Manufacturing Year' => 2014,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 326,
        'Display Size' => 7.9,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '6470',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'yes',
    },
    'iPad4,6' => {
        'Device Name' => 'iPad Mini 2',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 326,
        'Display Size' => 7.9,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '6470',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
    },
    'iPad4,5' => {
        'Device Name' => 'iPad Mini 2',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 326,
        'Display Size' => 7.9,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '6470',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
    },
    'iPad4,4' => {
        'Device Name' => 'iPad Mini 2',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1300,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 326,
        'Display Size' => 7.9,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '6470',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
    },
    'iPad4,3' => {
        'Device Name' => 'iPad Air',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '8600',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
    },
    'iPad4,2' => {
        'Device Name' => 'iPad Air',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '8600',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
    },
    'iPad4,1' => {
        'Device Name' => 'iPad Air',
        'Manufacturing Year' => 2013,
        'SoC' => 'Apple A7',
        'RAM' => 1024,
        'RAM Speed | Type' => '666',
        'CPU Model' => 'Cyclone',
        'CPU Arch' => 'ARMv8',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR G6430',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Motion Sensor' => 'M7',
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '8600',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
    },
    'iPad3,4' => {
        'Device Name' => 'iPad 4',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A6X',
        'RAM' => 1024,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'Swift',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR SGX554MP4',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '11560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad3,5' => {
        'Device Name' => 'iPad 4',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A6X',
        'RAM' => 1024,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'Swift',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR SGX554MP4',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '11560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad3,6' => {
        'Device Name' => 'iPad 4',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A6X',
        'RAM' => 1024,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'Swift',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1400,
        'GPU' => 'PowerVR SGX554MP4',
        'GPU Cores' => 4,
        'GPU Speed' => '300',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '11560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad3,3' => {
        'Device Name' => 'iPad 3',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A5X',
        'RAM' => 1024,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP4',
        'GPU Cores' => 4,
        'GPU Speed' => '250',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '11560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad3,2' => {
        'Device Name' => 'iPad 3',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A5X',
        'RAM' => 1024,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP4',
        'GPU Cores' => 4,
        'GPU Speed' => '250',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '11560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad3,1' => {
        'Device Name' => 'iPad 3',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A5X',
        'RAM' => 1024,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7s',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP4',
        'GPU Cores' => 4,
        'GPU Speed' => '250',
        'Display Resolution' => '2048x1536',
        'DPI' => 264,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '11560',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad2,7' => {
        'Device Name' => 'iPad Mini',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A5',
        'RAM' => 512,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP2',
        'GPU Cores' => 2,
        'GPU Speed' => '250',
        'Display Resolution' => '1024x768',
        'DPI' => 163,
        'Display Size' => 7.9,
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '4490',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad2,6' => {
        'Device Name' => 'iPad Mini',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A5',
        'RAM' => 512,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP2',
        'GPU Cores' => 2,
        'GPU Speed' => '250',
        'Display Resolution' => '1024x768',
        'DPI' => 163,
        'Display Size' => 7.9,
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '4490',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad2,5' => {
        'Device Name' => 'iPad Mini',
        'Manufacturing Year' => 2012,
        'SoC' => 'Apple A5',
        'RAM' => 512,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP2',
        'GPU Cores' => 2,
        'GPU Speed' => '250',
        'Display Resolution' => '1024x768',
        'DPI' => 163,
        'Display Size' => 7.9,
        'Front Camera' => '1.2 MP - 720p@30fps - face detection - HDR',
        'Rear Camera' => '5 MP - 1080p@30fps 2592 х 1944 - HDR',
        'Battery Capacity' => '4490',
        'Bluetooth Version' => '4.0',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad2,3' => {
        'Device Name' => 'iPad 2',
        'Manufacturing Year' => 2011,
        'SoC' => 'Apple A5',
        'RAM' => 512,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP2',
        'GPU Cores' => 2,
        'GPU Speed' => '250',
        'Display Resolution' => '1024x768',
        'DPI' => 132,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '3 MP - 720p@30fps - HDR',
        'Battery Capacity' => '6930',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad2,2' => {
        'Device Name' => 'iPad 2',
        'Manufacturing Year' => 2011,
        'SoC' => 'Apple A5',
        'RAM' => 512,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP2',
        'GPU Cores' => 2,
        'GPU Speed' => '250',
        'Display Resolution' => '1024x768',
        'DPI' => 132,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '3 MP - 720p@30fps - HDR',
        'Battery Capacity' => '6930',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad2,1' => {
        'Device Name' => 'iPad 2',
        'Manufacturing Year' => 2011,
        'SoC' => 'Apple A5',
        'RAM' => 512,
        'RAM Speed | Type' => '400',
        'CPU Model' => 'ARM Cortex-A9',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 2,
        'CPU Speed' => 1000,
        'GPU' => 'PowerVR SGX543MP2',
        'GPU Cores' => 2,
        'GPU Speed' => '250',
        'Display Resolution' => '1024x768',
        'DPI' => 132,
        'Display Size' => 9.7,
        'Front Camera' => '0.7 MP - 480p@30fps - face detection - HDR',
        'Rear Camera' => '3 MP - 720p@30fps - HDR',
        'Battery Capacity' => '6930',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
    'iPad1,1' => {
        'Device Name' => 'iPad',
        'Manufacturing Year' => 2010,
        'SoC' => 'Apple A4',
        'RAM' => 256,
        'RAM Speed | Type' => '200',
        'CPU Model' => 'ARM Cortex-A8',
        'CPU Arch' => 'ARMv7',
        'CPU Cores' => 1,
        'CPU Speed' => 800,
        'GPU' => 'PowerVR SGX535',
        'GPU Cores' => 1,
        'GPU Speed' => '200',
        'Display Resolution' => '1024x768',
        'DPI' => 132,
        'Display Size' => 9.7,
        'Battery Capacity' => '6600',
        'Bluetooth Version' => '2.1',
        'Touch ID' => 'no',
        'Motion Sensor' => 'no',
    },
}

op = OptionParser.new do |opts|
    opts.on('--file', '-f', 'Creates a resulting file') {|file| $file = file }
    opts.on('--json', '-j', 'Get output in JSON format') {|json| $json = json }
    opts.on('--csv', '-c', 'Get output in CSV format for Jira') {|csv| $csv = csv }
    opts.on('--quiet', '-q', 'Do not print CSV headers') { |headers| $csv_no_header = headers }
    opts.on('--help', '-h', 'Prints this help') { puts opts; exit }
    opts.parse!
end

def get_ios_device_name(productType)
    # puts "DEBUGGING GET_IOS_DEVICE_NAME #{productType} <-- PRODUCT TYPE VALUE"
    return $ios_device_map[productType]
end

def print_separator
    columns = `stty size | awk '{ print $2 }'`
    columns.to_i.times { print "=" }
end
def print_header_separator
    columns = `stty size | awk '{ print $2 }'`
    columns.to_i.times { print "-" }
end

def check_environment
    system('bash osx_install_libimobiledevice.sh')
end

def get_ios_info
    puts "Calling osx_get_ios_data_with_libimobiledevice" unless $csv_no_header

    values = {}
    IO.popen('bash osx_get_ios_data_with_libimobiledevice.sh') do |stdout|
        stdout.each do |line|
            puts line unless $csv_no_header

            ### Map only the key->values that are not from the interactive process from libimobiledevice
            keyvalue = line.split(': ',2)
            if keyvalue[0] !~ /(ERROR|SUCCESS)/

                # puts "Found: #{keyvalue[0]},#{keyvalue[1]}" if keyvalue[1] != nil
                values[keyvalue[0]] = keyvalue[1] if keyvalue[1] != nil
            end
        end
    end

    return values

end

### Variable Mappings


$jira_settings_map = {
    'Summary' => "#{$user}s iOS",
    'Project Name' => 'AM',
    'OS' => 'iOS',
    'manufacturer' => 'Apple',
    'Internal Storage Replaceable' => 'No'
}

$jira_custom_fields_scripts_map = {
    'IssueType' => 'DeviceClass',
    'Color' => 'DeviceColor',
    'CPU Model' => 'CPUArchitecture',
    'IMEI' => 'InternationalMobileEquipmentIdentity',
    'Product Type' => 'ProductType',
    'MAC Address (WIFI)' => 'WiFiAddress',
    'MAC Address (Bluetooth)' => 'BluetoothAddress',
    'Model' => 'ModelNumber',
    'Serial Number' => 'SerialNumber',
    'OS Version' => 'ProductVersion',
}

def get_ios_udid
    `idevice_id -l | uniq`.chomp.upcase
end

def set_jira_csv_project_headers
    ### Override / Hardcode Summary
    description = get_ios_device_name($ios_values['ProductType'].chomp)
    $jira_settings_map['Summary'] = "#{description} - #{$ios_values['DeviceName'].chomp}" if $ios_values['DeviceName'] != nil
    $jira_settings_map['Description'] = description
    $jira_settings_map['UDID'] = get_ios_udid

    $jira_settings_map.each do |key,value|
        (key.to_s.include? ' ') ? header = "\"#{key}\"" : header = key
        $headers += "#{header},"

        (value.to_s.include? ' ') ? val = "\"#{value}\"" : val = value
        (value.to_s.include? ',') ? val = value.gsub(',', '.') : val = value

        $values += "#{val},"
    end

end

def get_jira_csv_asset_headers_and_values
    $jira_custom_fields_scripts_map.each do |key,mapped_value|
        (key.to_s.include? ' ') ? header = "\"#{key}\"" : header = key
        $headers += "#{header},"

        value = $ios_values[mapped_value].chomp if $ios_values[mapped_value] != nil

        value = "\"#{value}\"" if (value.to_s.include? ' ')
        value.gsub!(',', '.') if (value.to_s.include? ',')

        $values += "#{value},"
    end

    specs = $ios_device_specs[$ios_values['ProductType'].chomp]
    specs.each { |key, value|
        (key.to_s.include? ' ') ? header = "\"#{key}\"" : header = key
        $headers += "#{header},"

        value = "\"#{value}\"" if (value.to_s.include? ' ')
        value.gsub!(',', '.') if (value.to_s.include? ',')

        $values += "#{value},"
    } if specs != nil

end


def get_jira_csv_values
    set_jira_csv_project_headers
    get_jira_csv_asset_headers_and_values


    ### Cleanup the last comma
    $headers = $headers[0..-2]
    $values = $values[0..-2]

    if $csv_no_header == false
        puts $headers
    end

    puts $values
end

def get_jira_json_values
    $jira_settings_map.each { |key, value| $jira_custom_fields_values_map[key] = value}
    # $jira_custom_fields_scripts_map.each { |key, script| append_script_value(key,script)}
    $jira_custom_fields_scripts_map.each { |key, mapped_value| $jira_custom_fields_values_map[key] = $ios_values[mapped_value].chomp if $ios_values[mapped_value] != nil }
    $jira_custom_fields_values_map['Summary'] = "#{get_ios_device_name($ios_values['ProductType'].chomp)} #{$ios_values['DeviceName'].chomp}" if $ios_values['DeviceClass'] != nil
    $jira_custom_fields_values_map['UDID'] = get_ios_udid
    specs = $ios_device_specs[$ios_values['ProductType'].chomp]
    specs.each { |key, value| $jira_custom_fields_values_map[key] = value } if specs != nil
    JSON.generate($jira_custom_fields_values_map)
end

def generate_a_summary_file_with_extension(extension)

    print_separator

    # filename = "AM-#{$jira_custom_fields_values_map['Summary']}.#{extension}".gsub(' ','-').gsub('(','').gsub(')','').gsub('/','-').chomp

    case extension
        when "json"
            buffer = get_jira_json_values
            filename = "AM-#{$jira_custom_fields_values_map['Summary']}.#{extension}".gsub(' ','-').gsub('(','').gsub(')','').gsub('/','-').chomp
            # File.open("#{filename}", 'w+') { |file| file.write(get_jira_json_values) }
            puts "Writing output to file: #{filename}"

            File.open("#{filename}", 'w+') { |file| file.write(buffer) }

        when "csv"
            get_jira_json_values
            # Save old Stdout
            old_stdout = $stdout
            # Set up standard output as a StringIO object.
            csvoutput = StringIO.new
            # Redirect Output to new IO Stream
            $stdout = csvoutput
            # Get the values
            get_jira_csv_values

            # Return to old Stdout
            $stdout = old_stdout

            ### Refresh filename with updated Summary
            filename = "AM-#{$jira_custom_fields_values_map['Summary']}.#{extension}".gsub(' ','-').gsub('(','').gsub(')','').gsub('/','-').chomp
            puts "Writing output to file: #{filename}"

            # csvoutput.string
            File.open("#{filename}", 'w+') { |file| file.write(csvoutput.string) }
    end

end

if !($json || $csv || $file)
    puts 'No output format specified. Nothing dome.'
    puts op.help
    exit 1
end

check_environment
print_separator unless $csv_no_header
$ios_values = get_ios_info

# if $file && !$json && !$csv
#   $json = $csv = true
# end

if $json and ! $file
    print_separator unless $csv_no_header
    puts get_jira_json_values
end

if $csv and ! $file
    print_separator unless $csv_no_header
    get_jira_csv_values
end

if $file
    print_separator unless $csv_no_header
    if !($json || $csv)
        print_separator
        puts "No specific Format selected, generating both JSON and CSV files"
        generate_a_summary_file_with_extension "csv"
        # print_separator
        generate_a_summary_file_with_extension "json"
        # print_separator
        # get_jira_csv_values
        # get_jira_json_values
    end
    if $json
        print_separator
        puts "Generating JSON file"
        generate_a_summary_file_with_extension "json"
    end
    if $csv
        print_separator
        puts "Generating CSV file"
        generate_a_summary_file_with_extension "csv"
    end
end

print_separator unless $csv_no_header
