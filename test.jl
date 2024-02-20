# Binary string
binary_string = "00000000011100110000001010110011"

# Parse binary string to integer
decimal_number = parse(Int, binary_string, base=2)

# Convert decimal number to hexadecimal string
hex_string = string(decimal_number, base=16)

# Print the result
println("Binary: $binary_string")
println("Hexadecimal: $hex_string")
