using Test
using Unitful
using UnitfulBrewing
using BrewingFormulas

@testset "BrewingFormulas" begin

@testset "Argument conventions" begin
    # gravities need units, and percentages are not gravities
    @test_throws ArgumentError plato(1.050)
    @test_throws ArgumentError plato(12)
    @test_throws ArgumentError plato(5u"percent")
    @test_throws ArgumentError abv(1.050, 1.010)
    # fractions: plain numbers or percentages
    @test final_gravity(12u"°P", 0.75) == final_gravity(12u"°P", 75u"percent")
    @test_throws ArgumentError final_gravity(12u"°P", 1.010u"sg")
    # results come back in the unit family of the original gravity
    @test unit(final_gravity(12u"°P", 0.75)) == u"°P"
    @test unit(final_gravity(1.050u"sg", 0.75)) == u"sg"
    @test unit(final_gravity(50u"gu", 0.75)) == u"gu"
    @test unit(final_gravity(12u"Brix", 0.75)) == u"Brix"
end

@testset "Gravity and extract" begin
    @test plato(1.040u"sg") ≈ 9.99224u"°P"                        # UnitfulBrewing docs
    @test plato(1.040u"sg"; eq = SugarGravity()) ≈ 9.961538461538483u"°P"
    @test plato(40u"gu") ≈ plato(1.040u"sg")
    @test specific_gravity(plato(1.057u"sg")) ≈ 1.057u"sg"
    @test specific_gravity(12u"Brix") == specific_gravity(12u"°P")

    m = extract_mass(20u"L", 12u"°P")
    @test m ≈ 20u"L" * 1.0483700887844734 * 0.998203u"kg/L" * 0.12
    @test extract_mass(20_000u"mL", 12u"°P") ≈ m
    @test gravity_from_extract(m, 20u"L") ≈ 12u"°P" atol = 1e-9u"°P"
    @test gravity_from_extract(0u"kg", 20u"L") == 0u"°P"

    # dilution keeps the extract
    v = volume_for_gravity(20u"L", 1.060u"sg", 1.050u"sg")
    @test v > 20u"L"
    @test extract_mass(v, 1.050u"sg") ≈ extract_mass(20u"L", 1.060u"sg")
    @test volume_for_gravity(20u"L", 12u"°P", 12u"°P") ≈ 20u"L"

    # water + extract → gravity and volume, consistently with extract_mass
    p = solution_gravity(20u"L", 2.5u"kg")
    @test p ≈ 100 * 2.5 / (20 * 0.998203 + 2.5) * u"°P"
    vs = solution_volume(20u"L", 2.5u"kg")
    @test extract_mass(vs, p) ≈ 2.5u"kg"
    @test solution_volume(20u"L", 0u"kg") ≈ 20u"L"
    @test solution_volume(19.96406u"kg", 2.5u"kg") ≈ vs rtol = 1e-6

    # hydrometer: no correction at the calibration temperature, positive above it
    @test hydrometer_correction(1.046u"sg", 20u"°C") ≈ 1.046u"sg"
    @test hydrometer_correction(1.046u"sg", 30u"°C") ≈ 1.0484709600383841u"sg"
    @test unit(hydrometer_correction(11u"°P", 30u"°C")) == u"°P"

    # potential and yield
    @test potential_from_yield(100u"percent") ≈ 1.046214u"sg"
    @test yield_from_potential(potential_from_yield(0.8)) ≈ 80u"percent"
    @test potential_extract(5u"kg", 80u"percent"; moisture = 4u"percent") ≈ 3.84u"kg"
end

@testset "Attenuation and alcohol" begin
    # the defaults of the attenuation calculator of the Python BrewQuiver
    og, fg = 15u"°P", 3.83u"°P"
    @test apparent_attenuation(og, fg) ≈ 74.4667u"percent" rtol = 1e-5
    @test real_extract(og, fg) ≈ 5.849536u"°P"
    @test real_attenuation(og, fg) ≈ 61.0031u"percent" rtol = 1e-5
    @test abw(og, fg) ≈ 4.7996u"percent" rtol = 1e-4
    @test abv(og, fg) ≈ 6.1615u"percent" rtol = 1e-4
    @test calories(og, fg, 330u"mL") ≈ 188u"kcal" rtol = 1e-2

    # inverses
    @test apparent_extract(og, real_extract(og, fg)) ≈ fg
    @test real_extract_from_abw(og, abw(og, fg)) ≈ real_extract(og, fg)
    @test apparent_attenuation(og, final_gravity(og, 70u"percent")) ≈ 70u"percent"

    # independence of the units of the arguments
    @test abv(1.050u"sg", 1.010u"sg") ≈ abv(plato(1.050u"sg"), plato(1.010u"sg"))
    @test abv(50u"gu", 10u"gu") ≈ abv(1.050u"sg", 1.010u"sg")
    @test abv(SimpleABV(), 1.050u"sg", 1.010u"sg") ≈ 5.25u"percent"
    @test abv(1.050u"sg", 1.010u"sg") ≈ abv(Balling(), 1.050u"sg", 1.010u"sg")
    # both models agree reasonably for usual beers
    @test abs(abv(1.050u"sg", 1.010u"sg") - abv(SimpleABV(), 1.050u"sg", 1.010u"sg")) <
          0.2u"percent"
    @test apparent_attenuation(0u"°P", 0u"°P") == 0u"percent"
end

@testset "Refractometer" begin
    @test refractometer_gravity(10.4u"Brix") ≈ 10u"°P"
    @test refractometer_gravity(10u"Brix"; wcf = 1) ≈ 10u"°P"
    # with no change, the estimate is close to the plain gravity
    @test refractometer_final_gravity(TerrillLinear(), 0u"Brix", 0u"Brix") ≈ 1.0u"sg"
    @test refractometer_final_gravity(TerrillCubic(), 0u"Brix", 0u"Brix") ≈ 1.0u"sg"
    @test refractometer_final_gravity(12u"Brix", 6.5u"Brix") ≈ 1.0129859456476515u"sg"
    @test refractometer_final_gravity(12u"Brix", 6.5u"Brix") ==
          refractometer_final_gravity(TerrillCubic(), 12u"Brix", 6.5u"Brix")
    @test 1.010 < ustrip(refractometer_final_gravity(TerrillLinear(), 12u"Brix", 6.5u"Brix")) < 1.014
end

@testset "Color" begin
    @test mcu(1u"lb", 10u"°L", 1u"gal") ≈ 10
    @test mcu(1u"lb", 10u"°L", 0u"gal") == 0
    @test mcu([1u"lb" => 10u"°L", 1u"lb" => 10u"°L"], 2u"gal") ≈ 10
    @test mcu(1u"lb", uconvert(u"EBC", 10u"°L"), 1u"gal") ≈ 10
    @test srm(Morey(), 10) ≈ 7.2398u"SRM" rtol = 1e-4
    @test srm(10) == srm(Morey(), 10)
    @test srm(Daniels(), 10) ≈ 10.4u"SRM"
    @test srm(Mosher(), 10) ≈ 7.7u"SRM"
    @test srm(Noonan(), 10) ≈ (15.03 * 10^0.27 - 15.53) * u"SRM"
    @test srm(0) == 0u"SRM"
    @test wort_color([1u"lb" => 10u"°L"], 1u"gal") ≈ srm(10)
    @test srm_rgb(1u"SRM") == (255, 230, 153)
    @test srm_rgb(40u"SRM") == (54, 8, 10)
    @test srm_rgb(100u"SRM") == srm_rgb(40u"SRM")
    @test srm_rgb(0.2u"SRM") == srm_rgb(1u"SRM")
    @test srm_rgb(1.5u"SRM") == (255, 223, 136)   # 136.5 rounds to even, as in Python
    @test srm_hex(1u"SRM") == "#ffe699"
    @test srm_hex(uconvert(u"EBC", 10u"SRM")) == srm_hex(10u"SRM")
end

@testset "Bitterness" begin
    @test utilization(1.050u"sg", 60u"minute") ≈ 0.2307 rtol = 1e-3   # Tinseth's table
    @test utilization(1.050u"sg", 1u"hr") ≈ utilization(1.050u"sg", 60u"minute")
    @test utilization(1.050u"sg", 0u"minute") == 0
    @test utilization(1.080u"sg", 60u"minute") < utilization(1.040u"sg", 60u"minute")
    @test utilization(Rager(), 1.050u"sg", 60u"minute") ≈
          (18.11 + 13.86 * tanh((60 - 31.32) / 18.27)) / 100
    @test utilization(Rager(), 1.070u"sg", 60u"minute") ≈
          utilization(Rager(), 1.050u"sg", 60u"minute") / 1.1
    @test alpha_acid_mass(30u"g", 10u"percent") ≈ 3u"g"
    @test isomerized_alpha_acids(30u"g", 0.1, 1.050u"sg", 60u"minute") ≈
          3000u"mg" * utilization(1.050u"sg", 60u"minute")
    @test ibu(200u"mg", 10u"L") ≈ 20u"IBU"
    @test ibu(30u"g", 10u"percent", 1.050u"sg", 60u"minute", 20u"L") ≈ 34.5996u"IBU" rtol = 1e-5
    @test ibu(30u"g", 10u"percent", 1.050u"sg", 60u"minute", 20u"L"; factor = 1.1) ≈
          1.1 * ibu(30u"g", 10u"percent", 1.050u"sg", 60u"minute", 20u"L")
end

@testset "Mash" begin
    # Palmer's metric rule of thumb: Tw = (0.41 / r)(T - Tg) + T, r in L/kg
    @test strike_temperature(67u"°C", 20u"°C", 15u"L", 5u"kg") ≈
          (67 + 0.4 / (3 * 0.998203) * 47) * u"°C"
    @test strike_temperature(67u"°C", 67u"°C", 15u"L", 5u"kg") ≈ 67u"°C"
    @test unit(strike_temperature(152u"°F", 68u"°F", 15u"L", 5u"kg")) == u"°F"
    # heat balance of the infusion
    v = infusion_volume(50u"°C", 67u"°C", 15u"L", 5u"kg")
    mw = 15 * 0.998203; mi = ustrip(u"L", v) * 0.998203
    @test (0.4 * 5 + mw) * 50 + mi * 100 ≈ (0.4 * 5 + mw + mi) * 67
    @test_throws ArgumentError infusion_volume(50u"°C", 67u"°C", 15u"L", 5u"kg";
                                               infusion_temperature = 60u"°C")
    @test mash_thickness(15u"L", 5u"kg") ≈ 3u"L/kg"
    @test mash_volume(15u"L", 5u"kg") ≈ 18.35u"L"
    @test grain_absorption(5u"kg") ≈ 5u"L"
    @test grain_absorption(5u"kg"; rate = 0.8u"L/kg") ≈ 4u"L"
    @test moisture_water(5u"kg", 4u"percent") ≈ 0.2u"kg" / 0.998203u"kg/L"
end

@testset "Boil and volumes" begin
    @test water_density(4u"°C") ≈ 0.99997u"kg/L" rtol = 1e-5
    @test water_density(20u"°C") ≈ 0.998207u"kg/L" rtol = 1e-5
    @test water_density(100u"°C") ≈ 0.958365u"kg/L" rtol = 1e-5
    @test volume_at_temperature(25u"L", 100u"°C", 20u"°C") ≈ 24.0022u"L" rtol = 1e-5
    @test volume_at_temperature(25u"L", 20u"°C", 20u"°C") ≈ 25u"L"
    @test evaporated_volume(25u"L", 4u"L/hr", 90u"minute") ≈ 6u"L"
    @test evaporated_volume(25u"L", 10u"percent/hr", 90u"minute") ≈ 3.75u"L"
    @test evaporated_volume(5u"L", 4u"L/hr", 3u"hr") == 5u"L"
end

@testset "Carbonation" begin
    @test residual_co2(68u"°F") ≈ 0.8615u"vols" rtol = 1e-4
    @test residual_co2(20u"°C") ≈ residual_co2(68u"°F")
    @test co2_yield(Sucrose()) ≈ 0.5143 rtol = 1e-3
    @test co2_yield(Glucose()) ≈ 0.4886 rtol = 1e-3
    @test co2_yield(CornSugar()) ≈ 0.4442 rtol = 1e-3
    @test co2_yield(PrimingSugar(0.3)) == 0.3
    g = priming_sugar(Sucrose(), 20u"L", 2.5u"vols", 20u"°C")
    @test g ≈ (2.5 - 0.8614872) * 1.977 * 20 / co2_yield(Sucrose()) * u"g" rtol = 1e-6
    @test priming_sugar(CornSugar(), 20u"L", 2.5u"vols", 20u"°C") > g
    @test priming_sugar(Sucrose(), 20u"L", 0.5u"vols", 20u"°C") == 0u"g"
    # usual force-carbonation charts: about 11-12 psi for 2.5 vols at 38 °F
    @test 11u"psi" < carbonation_pressure(2.5u"vols", 38u"°F") < 12u"psi"
    @test carbonation_level(carbonation_pressure(2.5u"vols", 4u"°C"), 4u"°C") ≈ 2.5u"vols"
    @test carbonation_level(1u"bar", 4u"°C") ≈ carbonation_level(uconvert(u"psi", 1u"bar"), 4u"°C")
end

@testset "Yeast" begin
    @test pitch_cells(20u"L", 12u"°P") ≈ 1.8e11
    @test pitch_cells(20u"L", 12u"°P"; rate = 1.5) ≈ 3.6e11
    @test pitch_cells(20u"L", plato(1.050u"sg")) ≈ 0.75e6 * 20_000 * ustrip(plato(1.050u"sg"))
end

end
