
function find_index_for_label(label_array, label)
    for row in label_array
        if row[1] == label
            return row[2]
        end
    end
    return nothing  # Return nothing if the string is not found
end

label_array = [("print",8),("print1",8),("print2",8)]
label = "print1"

println(find_index_for_label(label_array,label))