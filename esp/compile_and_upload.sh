arduino-cli compile --fqbn esp32:esp32:esp32 .
arduino-cli upload -p /dev/ttyACM0 --fqbn esp32:esp32:esp32 .
screen -L /dev/ttyACM0 115200
