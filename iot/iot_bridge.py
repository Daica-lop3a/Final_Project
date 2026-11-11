"""
SmartWaste - Arduino Serial to Web HTTP Bridge (Python)
Requirements: pip install pyserial requests
"""

import time
import json
import serial
import serial.tools.list_ports
import requests

SERVER_URL = "http://localhost:8080/SmartWaste/api/bin/update-fill"
BAUD_RATE = 9600

def list_ports():
    ports = list(serial.tools.list_ports.comports())
    return [p.device for p in ports]

def main():
    print("=" * 60)
    print("   SMARTWASTE - IOT SENSOR BRIDGE (ARDUINO -> WEB)   ")
    print("=" * 60)

    available_ports = list_ports()
    if not available_ports:
        print("[ERROR] No COM ports found. Connect Arduino USB cable!")
        return

    print(f"Available ports: {', '.join(available_ports)}")
    port = available_ports[0]
    if len(available_ports) > 1:
        user_port = input(f"Enter port [{available_ports[0]}]: ").strip()
        if user_port:
            port = user_port

    print(f"[INFO] Opening {port} at {BAUD_RATE} baud...")
    try:
        ser = serial.Serial(port, BAUD_RATE, timeout=3)
        time.sleep(2) # Wait for Arduino reset
        print(f"[SUCCESS] Listening on {port}...\n")
    except Exception as e:
        print(f"[ERROR] Could not open {port}: {e}")
        print("Note: Make sure Arduino Serial Monitor is CLOSED.")
        return

    try:
        while True:
            line = ser.readline().decode('utf-8', errors='ignore').strip()
            if not line:
                continue

            if line.startswith("{") and line.endswith("}"):
                try:
                    data = json.loads(line)
                    if "status" in data and data["status"] == "READY":
                        print(f"[ARDUINO] Booted: {data}")
                        continue

                    bin_id = data.get("bin_id")
                    fill_level = data.get("fill_level")
                    dist = data.get("distance_cm")

                    print(f"[DATA] Bin: {bin_id} | Distance: {dist}cm | Fill: {fill_level}%")

                    # POST to SmartWaste Web API
                    payload = {"binID": bin_id, "fillPercent": fill_level}
                    res = requests.post(SERVER_URL, data=payload, timeout=5)
                    print(f"       [WEB API] {res.text}")

                except json.JSONDecodeError:
                    print(f"[WARN] Non-JSON line: {line}")
                except requests.RequestException as re:
                    print(f"[WEB ERROR] Could not reach server: {re}")
            else:
                print(f"[RAW] {line}")

    except KeyboardInterrupt:
        print("\n[INFO] Stopped by user.")
    finally:
        ser.close()
        print("[INFO] Serial connection closed.")

if __name__ == "__main__":
    main()
