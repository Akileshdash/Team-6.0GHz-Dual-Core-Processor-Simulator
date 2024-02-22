function int_to_signed_20bit_bin_string(value::Int)
    if value < 0
        value += 2^20
    end
    bin_str = string(value, base=2)
    bin_str = string("0"^(20 - length(bin_str)), bin_str)
    return bin_str
end

# Example usage:
integer_value = 5  # Replace this with your integer value
bin_string = int_to_signed_20bit_bin_string(integer_value)
println(bin_string)
