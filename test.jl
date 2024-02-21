function int_to_32bit_bin(n::Int)
    binary_str_20bit = string(n + 2^20, base=2)[2:end]
    binary_str_32bit = string("0" ^ (32 - length(binary_str_20bit)), binary_str_20bit)
    return binary_str_32bit
end

println(int_to_32bit_bin(64))