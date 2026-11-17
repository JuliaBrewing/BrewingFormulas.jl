# Gravity, extract and the relations between them.
#
# Degrees Plato are the mass percentage of extract in the solution, and the specific gravity
# is the density of the solution relative to water, both at 20 °C. Hence a solution with
# extract mass `mₑ` and total mass `m` has `P = 100 mₑ / m` and volume `V = m / (sg ρw)`.

"""
    plato(gravity; eq = SugarGravityQuad())

The `gravity` (in `°P`, `Brix`, `sg` or `gu`) in degrees Plato.

```julia
julia> plato(1.050u"sg")
12.387625000000002 °P
```
"""
plato(x; eq::Equivalence = DEFAULT_EQUIVALENCE) = _plato(x, eq) * u"°P"

"""
    specific_gravity(gravity; eq = SugarGravityQuad())

The `gravity` (in `°P`, `Brix`, `sg` or `gu`) as specific gravity, in `sg`.

```julia
julia> specific_gravity(12u"°P")
1.0483700887844734 sg
```
"""
specific_gravity(x; eq::Equivalence = DEFAULT_EQUIVALENCE) = _sg(x, eq) * u"sg"

_water_mass(x::Unitful.Mass) = x
_water_mass(x::Unitful.Volume) = x * WATER_DENSITY_20C

"""
    extract_mass(volume, gravity; eq = SugarGravityQuad())

The mass of extract dissolved in a `volume` of solution with the given `gravity`, both at
20 °C: `volume × sg × ρw × P / 100`, where `ρw` is the density of water at 20 °C. This
follows from the definitions of degrees Plato (percentage of extract by mass) and of specific
gravity (density relative to water, both at 20 °C).

```julia
julia> extract_mass(20u"L", 12u"°P")
2.5115668025638263 kg
```
"""
function extract_mass(volume::Unitful.Volume, gravity; eq::Equivalence = DEFAULT_EQUIVALENCE)
    p = _plato(gravity, eq)
    s = _sg(p * u"°P", eq)
    return uconvert(u"kg", volume * s * WATER_DENSITY_20C * p / 100)
end

# Solve `sg(P) P / 100 = c` for P by bisection: the left-hand side is increasing in P.
function _plato_from_concentration(c::Real, eq::Equivalence)
    c ≤ 0 && return 0.0
    f(p) = _sg(p * u"°P", eq) * p / 100 - c
    lo, hi = 0.0, 80.0
    f(hi) < 0 && throw(DomainError(c, "extract concentration beyond the range of the gravity equivalence"))
    for _ in 1:200
        mid = (lo + hi) / 2
        f(mid) < 0 ? (lo = mid) : (hi = mid)
        hi - lo < 1e-12 && break
    end
    return (lo + hi) / 2
end

"""
    gravity_from_extract(extract, volume; eq = SugarGravityQuad())

The gravity, in `°P`, of a `volume` of solution containing the mass `extract` of dissolved
extract; the inverse of [`extract_mass`](@ref).
"""
function gravity_from_extract(extract::Unitful.Mass, volume::Unitful.Volume;
                              eq::Equivalence = DEFAULT_EQUIVALENCE)
    c = float(uconvert(NoUnits, extract / (volume * WATER_DENSITY_20C)))
    return _plato_from_concentration(c, eq) * u"°P"
end

"""
    volume_for_gravity(volume, gravity, target; eq = SugarGravityQuad())

The volume a solution with the given `volume` and `gravity` must have, after dilution or
concentration, to reach the `target` gravity, keeping its extract. Add water if it is
larger than `volume`, boil off otherwise.

```julia
julia> volume_for_gravity(20u"L", 1.060u"sg", 1.050u"sg")
24.027752581421268 L
```
"""
function volume_for_gravity(volume::Unitful.Volume, gravity, target;
                            eq::Equivalence = DEFAULT_EQUIVALENCE)
    m = extract_mass(volume, gravity; eq)
    p = _plato(target, eq)
    s = _sg(p * u"°P", eq)
    return uconvert(unit(volume), m / (WATER_DENSITY_20C * s * p / 100))
end

"""
    solution_gravity(water, extract; eq = SugarGravityQuad())

The gravity, in `°P`, of the solution of the mass `extract` in `water`, given either as a
mass or as a volume at 20 °C: `P = 100 mₑ / (m_w + mₑ)`.
"""
function solution_gravity(water::Union{Unitful.Mass, Unitful.Volume}, extract::Unitful.Mass;
                          eq::Equivalence = DEFAULT_EQUIVALENCE)
    mw = _water_mass(water)
    return float(uconvert(NoUnits, 100 * extract / (mw + extract))) * u"°P"
end

"""
    solution_volume(water, extract; eq = SugarGravityQuad())

The volume, at 20 °C, of the solution of the mass `extract` in `water`, given either as a
mass or as a volume at 20 °C: `V = (m_w + mₑ) / (sg ρw)`, with `sg` the specific gravity of
the solution. This is how the volume of a wort follows from the water and the extract
dissolved from the grains.

```julia
julia> solution_volume(20u"L", 2.5u"kg")
21.54110091391626 L
```
"""
function solution_volume(water::Union{Unitful.Mass, Unitful.Volume}, extract::Unitful.Mass;
                         eq::Equivalence = DEFAULT_EQUIVALENCE)
    mw = _water_mass(water)
    s = _sg(solution_gravity(mw, extract; eq), eq)
    return uconvert(u"L", (mw + extract) / (s * WATER_DENSITY_20C))
end

# polynomial correction of hydrometers, in thousandths of sg, with the temperature in °F
_hydrometer_poly(tf) = 1.313454 - 0.132674tf + 2.057793e-3tf^2 - 2.627634e-6tf^3

"""
    hydrometer_correction(reading, temperature; calibration = 20u"°C", eq = SugarGravityQuad())

The gravity corrected from a hydrometer `reading` taken at `temperature`, for a hydrometer
calibrated at `calibration`, in the unit of `reading`.

The correction is the difference, in thousandths of sg, of the cubic fit
`1.313454 - 0.132674 T + 2.057793e-3 T² - 2.627634e-6 T³` (`T` in °F) at the two
temperatures. The fit (R² = 0.999969, from 0 to 212 °F) is to the density of water from the
CRC Handbook of Chemistry and Physics, relative to its value at 59 °F; taking differences
allows any calibration temperature.

# References

- C. Lyons, "Hydrometer Temperature Corrections", Homebrew Digest #963, 7 September 1992,
  <https://brewery.org/library/HydromCorr0992.html>.

```julia
julia> hydrometer_correction(1.046u"sg", 30u"°C")
1.0484709600383841 sg
```
"""
function hydrometer_correction(reading, temperature::Unitful.Temperature;
                               calibration::Unitful.Temperature = 20u"°C",
                               eq::Equivalence = DEFAULT_EQUIVALENCE)
    correction = (_hydrometer_poly(_val(u"°F", temperature)) -
                  _hydrometer_poly(_val(u"°F", calibration))) / 1000
    s = _sg(reading, eq) + correction
    reading isa SugarContents ? uconvert(unit(reading), s * u"sg", eq) :
                                uconvert(unit(reading), s * u"sg")
end

"""
    SUCROSE_PPG

Points per pound per gallon of sucrose, `46.214`: one pound of sucrose in one US gallon of
solution gives a specific gravity of `1.046214`.

# References

- About 46 PPG is the value commonly given for sucrose in brewing references; the source of
  the precise value 46.214, carried over from usual brewing software, was not found. (The
  extract model of this package, with `SugarGravityQuad`, gives about 46.18.)
"""
const SUCROSE_PPG = 46.214

"""
    potential_from_yield(yield)

The potential of a fermentable, as the specific gravity of 1 lb in 1 US gallon (as in
BeerJSON), from its extract `yield` relative to sucrose (a percentage or fraction).

```julia
julia> potential_from_yield(80u"percent")
1.0369712 sg
```
"""
potential_from_yield(yield) = (1 + _fraction(yield) * SUCROSE_PPG / 1000) * u"sg"

"""
    yield_from_potential(potential)

The extract yield, relative to sucrose, of a fermentable with the given `potential` (the
specific gravity of 1 lb in 1 US gallon); the inverse of [`potential_from_yield`](@ref).
"""
yield_from_potential(potential; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    _percent((_sg(potential, eq) - 1) * 1000 / SUCROSE_PPG)

"""
    potential_extract(mass, yield; moisture = 0)

The maximum mass of extract obtainable from a `mass` of fermentable with the given extract
`yield` on dry basis and `moisture` content (percentages or fractions).

```julia
julia> potential_extract(5u"kg", 80u"percent"; moisture = 4u"percent")
3.84 kg
```
"""
potential_extract(mass::Unitful.Mass, yield; moisture = 0) =
    mass * (1 - _fraction(moisture)) * _fraction(yield)
