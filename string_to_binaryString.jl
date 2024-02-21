
function string_to_binary_8bit_string_array(str::String)
    hex_array = transcode(UInt8, str)
    binary_array = [bitstring(UInt8(x)) for x in hex_array]
    return binary_array
end

arr = string_to_binary_8bit_string_array("\n")
println(arr)

function binary_to_letters(binary_strings::Vector{String})
    letters = Char[]
    for binary_str in binary_strings
        decimal_value = parse(Int, binary_str, base=2)
        letter = Char(decimal_value)
        push!(letters, letter)
    end
    return join(letters)
end

binary_strings = ["01001000", "01100101", "01101100", "01101100", "01101111"]
result = binary_to_letters(arr)
println(result)


