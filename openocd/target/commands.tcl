
# Set GPIOs 0 and 1 to output
gpios settings 0 1
gpios settings 1 1

for {set i 0} {$i < 20} {incr i} {
    gpios set_pin 0 1
    gpios set_pin 1 0
    sleep 100
    gpios set_pin 0 0
    gpios set_pin 1 1
    sleep 100
}
