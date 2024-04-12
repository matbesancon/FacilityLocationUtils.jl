
"""
Parse a CFL instance, return the result as named tuple
"""
function parse_facility_location_cfl(filepath)

    file_lines = open(filepath) do f
        readlines(f)
    end

    @assert occursin("CFLP-PROBLEMFILE", file_lines[1])

    # depot information
    @assert occursin("DEPOTS", file_lines[5])
    depot_first_line = 7

    capacities = Int[]
    depot_cost = Int[]
    depot_x_coord = Float64[]
    depot_y_coord = Float64[]
    depot_names = String[]
    line_idx = depot_first_line
    while length(file_lines[line_idx]) > 1
        line = split(file_lines[line_idx], " ")
        push!(capacities, parse(Int, line[1]))
        push!(depot_cost, parse(Int, line[2]))
        push!(depot_x_coord, parse(Float64, line[4]))
        push!(depot_y_coord, parse(Float64, line[5]))
        push!(depot_names, line[6])
        line_idx += 1
    end

    ndepots = length(depot_cost)

    depot_distance_matrix = [
        sqrt((depot_x_coord[i] - depot_x_coord[j])^2 + (depot_y_coord[i] - depot_y_coord[j])^2) for i in 1:ndepots, j in 1:ndepots
    ]

    @assert occursin("CUSTOMERS", file_lines[depot_first_line + ndepots + 1])

    first_customer = depot_first_line + ndepots + 3

    demands = Int[]
    customer_x_coord = Float64[]
    customer_y_coord = Float64[]
    customer_names = String[]
    line_idx = first_customer
    while length(file_lines[line_idx]) > 1
        line = split(file_lines[line_idx], " ")
        push!(demands, parse(Int, line[1]))
        push!(customer_x_coord, parse(Float64, line[2]))
        push!(customer_y_coord, parse(Float64, line[3]))
        push!(customer_names, line[4])
        line_idx += 1
    end

    ncustomers = length(demands)

    @assert occursin("COSTMATRIX", file_lines[first_customer + ncustomers + 1])
    @assert occursin("MATRIX", file_lines[first_customer + ncustomers + 3])

    first_cost_line = first_customer + ncustomers + 5

    cost_matrix = zeros(ndepots, ncustomers)
    line_idx = first_cost_line
    while line_idx <= length(file_lines) && length(file_lines[line_idx]) > 1
        line = split(file_lines[line_idx], " ")
        # may be an empty space at the end of the line
        @assert ncustomers <= length(line) <= ncustomers + 1
        for j in 1:ncustomers
            cost_matrix[line_idx - first_cost_line + 1, j] = parse(Float64, line[j])
        end
        line_idx += 1
    end

    # we also compute the direct ndepots × ncustomers distance matrix
    depot_customer_distance_matrix_file = cost_matrix ./ demands' / 0.01
    depot_customer_distance_matrix = [
        sqrt((depot_x_coord[i] - customer_x_coord[j])^2 + (depot_y_coord[i] - customer_y_coord[j])^2) for i in 1:ndepots, j in 1:ncustomers
    ]

    # cost matrix of the file already multiplies the whole demand to normalize the flows.
    # /!\ for some reason, the generator produces the transposed matrix if ndepots == ncustomers
    # to keep our sanity, we recompute the distance matrices ourselves and always keep the convention
    # D[ndepots, ncustomers]
    if ndepots != ncustomers
        @assert norm(depot_customer_distance_matrix_file - depot_customer_distance_matrix, Inf) ≤ 1e-2
    else
        @assert norm(depot_customer_distance_matrix_file - depot_customer_distance_matrix', Inf) ≤ 1e-2
    end

    return (; depot_cost, depot_x_coord, depot_y_coord, capacities, depot_names, depot_distance_matrix, demands, customer_x_coord, customer_y_coord, customer_names, depot_customer_distance_matrix)
end
