
"""
Builds the direct JuMP model for capacitated facility location, returns the model, facility opening variables, and assignment variables.
"""
function capacitated_facility_location_compact_model(
    instance_namedtuple::NamedTuple;
    optimizer,
    time_limit = 600,
)
    depot_cost = instance_namedtuple.depot_cost
    capacities = instance_namedtuple.capacities
    depot_customer_distance_matrix = instance_namedtuple.depot_customer_distance_matrix
    demands = instance_namedtuple.demands
    m = Model(optimizer)
    ndepots = length(depot_cost)
    ncustomers = length(demands)
    @variable(m, x[1:ndepots], Bin)
    @variable(m, y[1:ndepots, 1:ncustomers] >= 0)
    @constraint(
        m,
        demand_met[j = 1:ncustomers],
        sum(y[i, j] for i = 1:ndepots) >= demands[j],
    )
    @constraint(
        m,
        depot_capacity_limit[i = 1:ndepots],
        sum(y[i, j] for j = 1:ncustomers) <= capacities[i] * x[i],
    )
    @objective(m, Min, dot(depot_cost, x) + dot(depot_customer_distance_matrix, y))
    return (m, x, y)
end
