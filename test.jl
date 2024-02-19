function show_hex(value)
    hex_str = string(value, base=16)
    return lpad(hex_str, 2, '0')
end

println(show_hex(10))
