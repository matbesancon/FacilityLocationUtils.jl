import FacilityLocationUtils as FLU
using Test
using HiGHS
using JuMP

@testset "parsing and building model" begin
    instance_info = FLU.parse_facility_location_cfl(joinpath(@__DIR__, "T100x100_10_1.cfl"))
    (m, x, y) = FLU.capacitated_facility_location_compact_model(instance_info, optimizer=HiGHS.Optimizer)
    set_silent(m)
    JuMP.optimize!(m)
    @test termination_status(m) == MOI.OPTIMAL
end
