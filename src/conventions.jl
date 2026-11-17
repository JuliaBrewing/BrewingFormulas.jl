# Normalization of the arguments: everything is converted to plain numbers in the units
# the empirical formulas were fitted in, and the results get their units back.

const SugarContents = UnitfulBrewing.SugarContents
const ColorQuantity = UnitfulBrewing.Color
const CarbonationQuantity = UnitfulBrewing.Carbonation

"""
    DEFAULT_EQUIVALENCE

The equivalence between sugar contents (`°P`) and specific gravity (`sg`) used by default,
`SugarGravityQuad()`, from UnitfulBrewing: `°P = 668.72 sg - 463.37 - 205.35 sg²`.

# References

- This quadratic fit is attributed to Robbins (1975) in "On the relationship between Plato
  and specific gravity", Brewer's Friend, 2012,
  <https://www.brewersfriend.com/2012/10/31/on-the-relationship-between-plato-and-specific-gravity>;
  the original publication was not found.
"""
const DEFAULT_EQUIVALENCE = SugarGravityQuad()

"""
    WATER_DENSITY_20C

Density of water at 20 °C, the reference temperature of the Plato tables (sg 20/20).

# References

- G. S. Kell, "Density, thermal expansivity, and compressibility of liquid water from 0° to
  150 °C", *J. Chem. Eng. Data* 20 (1975) 97–105, <https://doi.org/10.1021/je60064a005>.
"""
const WATER_DENSITY_20C = 0.998203u"kg/L"

const _sg_units = (u"sg", u"gu")

function _check_gravity_unit(x::DimensionlessQuantity)
    unit(x) in _sg_units || throw(ArgumentError(
        "a dimensionless gravity must be in `sg` or `gu`, got $x; " *
        "use a unit such as 1.050u\"sg\", 50u\"gu\" or 12u\"°P\""))
    return nothing
end

_gravity_error(x) = throw(ArgumentError(
    "a gravity must carry its unit (°P, Brix, sg or gu), got $x; " *
    "e.g. 1.050u\"sg\" or 12u\"°P\""))

# gravity in degrees Plato, as a plain number
_plato(x::SugarContents, eq::Equivalence) = float(ustrip(u"°P", x))
function _plato(x::DimensionlessQuantity, eq::Equivalence)
    _check_gravity_unit(x)
    return float(ustrip(u"°P", uconvert(u"°P", x, eq)))
end
_plato(x, eq) = _gravity_error(x)

# gravity as specific gravity, as a plain number
_sg(x::SugarContents, eq::Equivalence) = float(ustrip(u"sg", uconvert(u"sg", x, eq)))
function _sg(x::DimensionlessQuantity, eq::Equivalence)
    _check_gravity_unit(x)
    return float(ustrip(u"sg", uconvert(u"sg", x)))
end
_sg(x, eq) = _gravity_error(x)

# a gravity given in °P, as a quantity in the same unit as `ref`
_like(ref::SugarContents, p::Real, eq::Equivalence) = uconvert(unit(ref), p * u"°P")
_like(ref::DimensionlessQuantity, p::Real, eq::Equivalence) =
    uconvert(unit(ref), p * u"°P", eq)

# fractions: percent quantities or plain numbers taken as fractions
_fraction(x::Real) = float(x)
function _fraction(x::DimensionlessQuantity)
    unit(x) in _sg_units && throw(ArgumentError("expected a fraction or percentage, got $x"))
    return float(uconvert(NoUnits, x))
end

_percent(f::Real) = uconvert(u"percent", f)

# plain numbers in given units
_val(u, x) = float(ustrip(u, x))
