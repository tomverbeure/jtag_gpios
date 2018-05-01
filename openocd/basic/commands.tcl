
jtag init

# Force TAP to get back to Test Logic Reset state
runtest 5

# Select GPIO_CONFIG IR
irscan chip.gpios_tap 0x5 -endstate IRPAUSE

# Set all GPIOs to output
drscan chip.gpios_tap 3 0x7

# Select GPIO_DATA IR
irscan chip.gpios_tap 0x4 -endstate IRPAUSE

# Set all GPIOs to high
drscan chip.gpios_tap 3 0x7
sleep 250

# Set all GPIOs to high
drscan chip.gpios_tap 3 0x0
sleep 250

# Set all GPIOs to high
drscan chip.gpios_tap 3 0x7
sleep 250

# Set all GPIOs to high
drscan chip.gpios_tap 3 0x0
sleep 250
