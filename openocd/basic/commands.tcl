
# Force TAP to get back to Test Logic Reset state
runtest 5

# Select SCAN_N IR
irscan chip.gpios_tap 0x2 -endstate IRPAUSE

# Select CONFIG register
drscan chip.gpios_tap 1 0x0

# Select EXTEST IR
irscan chip.gpios_tap 0x3 -endstate IRPAUSE

# Set all GPIOs to output
drscan chip.gpios_tap 4 0xf

# Select SCAN_N IR
irscan chip.gpios_tap 0x2 -endstate IRPAUSE

# Select DATA register
drscan chip.gpios_tap 1 0x1

# Select EXTEST IR
irscan chip.gpios_tap 0x3 -endstate IRPAUSE

# Set all GPIOs to high
drscan chip.gpios_tap 4 0xf
sleep 250

for {set i 0} {$i < 20} {incr i} {
    # Set all GPIO 0 to 1 and GPIO to 0
    drscan chip.gpios_tap 4 0x9
    sleep 250

    # Set all GPIO 0 to 0 and GPIO to 1
    drscan chip.gpios_tap 4 0xa
    sleep 250
}
