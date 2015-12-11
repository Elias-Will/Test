#!/usr/bin/env bash
echo "AirPort: $(bash osx_get_mac_address_airport.sh)"
echo "Bluetooth: $(bash osx_get_mac_address_bluetooth.sh)"
echo "Ethernet (Built-in, if any): $(bash osx_get_mac_address_ethernet.sh)"
