function shift_right(arr::Vector{T}, k::Int) where T
    n = length(arr)
    k %= n  # Ensure k is within the range of array length
    shifted_arr = Vector{T}(undef, n)  # Initialize shifted array with uninitialized values
    for i in 1:n
        j = mod1(i - k, n)
        if j == 0
            j = n
        end
        if i <= k
            shifted_arr[i] = zero(T)
        else
            shifted_arr[i] = arr[j]
        end
    end
    return shifted_arr
end

# Test the function
arr = [1, 2, 3, 4, 5]
k = 2
shifted_arr = shift_right(arr, k)
println("Original array: ", arr)
println("Shifted array: ", shifted_arr)
