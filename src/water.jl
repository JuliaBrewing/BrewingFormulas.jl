# Water chemistry: ions from salts, alkalinity, Kolbach's residual alkalinity, acids, and an
# estimate of the mash pH by a balance of charges.
#
# Concentrations are in mg/L (ppm, through `DensityConcentration`). Alkalinity, hardness and
# residual alkalinity are in mg/L "as CaCO₃", the usual brewing convention: the mass of
# calcium carbonate with the same number of equivalents. One milliequivalent per liter is
# 50.04 mg/L as CaCO₃ (see `milliequivalents`).

# molar masses, g/mol, from the IUPAC standard atomic weights
const _M = (Ca = 40.078, Mg = 24.305, Na = 22.98977, Cl = 35.453, S = 32.06, O = 15.999,
            H = 1.008, C = 12.011, P = 30.973762)
const _M_SO4 = _M.S + 4_M.O
const _M_HCO3 = _M.H + _M.C + 3_M.O
const _M_CO3 = _M.C + 3_M.O
const _M_H2O = 2_M.H + _M.O
const _M_CACO3 = _M.Ca + _M_CO3
# equivalent weights, mg/mEq
const _EQ_CACO3 = _M_CACO3 / 2
const _EQ_CA = _M.Ca / 2
const _EQ_MG = _M.Mg / 2

_mgL(x::Unitful.Quantity) = dimension(x) == dimension(u"mg/L") ? float(uconvert(u"mg/L", x)) :
                            float(uconvert(u"mg/L", x, DensityConcentration()))
_mgL(x::Real) = throw(ArgumentError("give the concentration $x with its unit, e.g. mg/L or ppm"))

"""
    alkalinity(bicarbonate)

The alkalinity, in mg/L as CaCO₃, of water with the given concentration of `bicarbonate`
(HCO₃⁻, in mg/L or ppm), by the equivalent weights of HCO₃⁻ and CaCO₃ (the other carbonate
species are negligible at the pH of brewing water).

```jldoctest
julia> ustrip(u"mg/L", alkalinity(122u"mg/L"))   # mg/L as CaCO₃
100.0597548184083
```
"""
alkalinity(bicarbonate) = _mgL(bicarbonate) * (_EQ_CACO3 / _M_HCO3)

"""
    calcium_hardness(calcium)

The hardness, in mg/L as CaCO₃, of the given concentration of calcium (mg/L or ppm).
"""
calcium_hardness(calcium) = _mgL(calcium) * (_EQ_CACO3 / _EQ_CA)

"""
    magnesium_hardness(magnesium)

The hardness, in mg/L as CaCO₃, of the given concentration of magnesium (mg/L or ppm).
"""
magnesium_hardness(magnesium) = _mgL(magnesium) * (_EQ_CACO3 / _EQ_MG)

"""
    milliequivalents(x)

The milliequivalents per liter, as a plain number, of a concentration `x` in mg/L as CaCO₃
(alkalinity, hardness, residual alkalinity): one milliequivalent per liter is 50.04 mg/L as
CaCO₃.
"""
milliequivalents(x) = ustrip(u"mg/L", _mgL(x)) / _EQ_CACO3

"""
    residual_alkalinity(alkalinity, calcium, magnesium)

Kolbach's residual alkalinity, in mg/L as CaCO₃, of water with the given `alkalinity` (in
mg/L as CaCO₃) and concentrations of `calcium` and `magnesium` (mg/L or ppm): the
alkalinity left after the calcium and magnesium react with the phosphates of the malt, 3.5
equivalents of calcium and 7 of magnesium neutralizing one equivalent of alkalinity,
`RA = alkalinity - calcium hardness / 3.5 - magnesium hardness / 7`.

# References

- P. Kolbach (1953), as given in J. Palmer and C. Kaminski, *Water: A Comprehensive Guide
  for Brewers*, Brewers Publications, 2013, in "The Power of pH", *Brew Your Own*
  (<https://byo.com/?p=8960>), and in MEBAK method W-030.01.900, "Residual Alkalinity in
  Brewing Liquor". The original paper was not found.

```jldoctest
julia> ustrip(u"mg/L", residual_alkalinity(100u"mg/L", 50u"mg/L", 10u"mg/L"))
58.44182691724805
```
"""
residual_alkalinity(alkalinity, calcium, magnesium) =
    _mgL(alkalinity) - calcium_hardness(calcium) / 3.5 - magnesium_hardness(magnesium) / 7

# Salts

"""
    AbstractSalt

Brewing salts, characterized by the ions they add per mass dissolved in a volume of water
(see [`ions`](@ref)): [`Gypsum`](@ref), [`CalciumChloride`](@ref), [`EpsomSalt`](@ref),
[`MagnesiumChloride`](@ref), [`TableSalt`](@ref), [`BakingSoda`](@ref), [`Chalk`](@ref),
[`SlakedLime`](@ref).
"""
abstract type AbstractSalt end

"Gypsum, calcium sulfate dihydrate, CaSO₄·2H₂O."
struct Gypsum <: AbstractSalt end
"Calcium chloride dihydrate, CaCl₂·2H₂O."
struct CalciumChloride <: AbstractSalt end
"Epsom salt, magnesium sulfate heptahydrate, MgSO₄·7H₂O."
struct EpsomSalt <: AbstractSalt end
"Magnesium chloride hexahydrate, MgCl₂·6H₂O."
struct MagnesiumChloride <: AbstractSalt end
"Table salt, sodium chloride, NaCl."
struct TableSalt <: AbstractSalt end
"Baking soda, sodium bicarbonate, NaHCO₃."
struct BakingSoda <: AbstractSalt end
"Chalk, calcium carbonate, CaCO₃; it barely dissolves in water, but does in the mash."
struct Chalk <: AbstractSalt end
"Slaked lime, calcium hydroxide, Ca(OH)₂."
struct SlakedLime <: AbstractSalt end

# per mole of salt: its molar mass, and the moles of each ion and the equivalents of
# alkalinity it gives
_salt(::Gypsum) = (M = _M.Ca + _M_SO4 + 2_M_H2O, Ca = 1, SO4 = 1)
_salt(::CalciumChloride) = (M = _M.Ca + 2_M.Cl + 2_M_H2O, Ca = 1, Cl = 2)
_salt(::EpsomSalt) = (M = _M.Mg + _M_SO4 + 7_M_H2O, Mg = 1, SO4 = 1)
_salt(::MagnesiumChloride) = (M = _M.Mg + 2_M.Cl + 6_M_H2O, Mg = 1, Cl = 2)
_salt(::TableSalt) = (M = _M.Na + _M.Cl, Na = 1, Cl = 1)
_salt(::BakingSoda) = (M = _M.Na + _M_HCO3, Na = 1, alk = 1)
_salt(::Chalk) = (M = _M_CACO3, Ca = 1, alk = 2)
_salt(::SlakedLime) = (M = _M.Ca + 2 * (_M.O + _M.H), Ca = 1, alk = 2)

"""
    ions(salt, mass, volume)

The concentrations, as a NamedTuple `(calcium, magnesium, sodium, chloride, sulfate,
alkalinity)` in mg/L (the alkalinity as CaCO₃), that a `mass` of the [`AbstractSalt`](@ref)
`salt` adds to a `volume` of water, from the stoichiometry of the salt and the IUPAC
standard atomic weights.

```jldoctest
julia> ustrip(u"mg/L", ions(Gypsum(), 1u"g", 1u"L").calcium)
232.78966566761923
```
"""
function ions(salt::AbstractSalt, mass::Unitful.Mass, volume::Unitful.Volume)
    s = _salt(salt)
    mmol = ustrip(u"mg", float(mass)) / s.M / ustrip(u"L", float(volume))   # mmol/L
    c(k, M) = get(s, k, 0) * M * mmol * u"mg/L"
    return (calcium = c(:Ca, _M.Ca), magnesium = c(:Mg, _M.Mg), sodium = c(:Na, _M.Na),
            chloride = c(:Cl, _M.Cl), sulfate = c(:SO4, _M_SO4),
            alkalinity = get(s, :alk, 0) * _EQ_CACO3 * mmol * u"mg/L")
end

# Acids

"""
    AbstractAcid

Acids for lowering the pH of mash or sparge water, as solutions of a given strength (mass
fraction) and density: [`LacticAcid`](@ref), [`PhosphoricAcid`](@ref). See
[`acid_milliequivalents`](@ref).
"""
abstract type AbstractAcid end

"""
    LacticAcid(; strength = 88u"percent", density = 1.21u"g/mL")

A solution of lactic acid (pKa 3.86), by default the usual 88% solution, whose density is
about 1.21 g/mL.
"""
struct LacticAcid <: AbstractAcid
    strength::Float64
    density::typeof(1.0u"g/mL")
end
LacticAcid(; strength = 88u"percent", density = 1.21u"g/mL") =
    LacticAcid(_fraction(strength), uconvert(u"g/mL", float(density)))

"""
    PhosphoricAcid(; strength = 10u"percent", density = 1.05u"g/mL")

A solution of phosphoric acid (pKa 2.15, 7.20, 12.35), by default a 10% solution, whose
density is about 1.05 g/mL (85% solutions are about 1.69 g/mL).
"""
struct PhosphoricAcid <: AbstractAcid
    strength::Float64
    density::typeof(1.0u"g/mL")
end
PhosphoricAcid(; strength = 10u"percent", density = 1.05u"g/mL") =
    PhosphoricAcid(_fraction(strength), uconvert(u"g/mL", float(density)))

_acid(::LacticAcid) = (M = 3_M.C + 6_M.H + 3_M.O, pKa = (3.86,))
_acid(::PhosphoricAcid) = (M = 3_M.H + _M.P + 4_M.O, pKa = (2.15, 7.20, 12.35))

# the mean number of protons given by a molecule of acid at `ph`, from its pKa values
function _protons(pKa, ph)
    h = 10.0^(-ph)
    K = [10.0^(-p) for p in pKa]
    terms = [prod(K[1:j]; init = 1.0) * h^(length(K) - j) for j in 0:length(K)]
    return sum(j * terms[j + 1] for j in 0:length(K)) / sum(terms)
end

"""
    acid_milliequivalents(acid, volume; ph = 5.4)

The milliequivalents of protons, as a plain number, that a `volume` of the solution of
[`AbstractAcid`](@ref) `acid` gives at the pH `ph` (of a mash, about 5.4), from its strength,
density, molar mass and pKa values (the fraction of each acid group dissociated at `ph`).

# References

- The pKa values are from the CRC Handbook of Chemistry and Physics; the densities of the
  solutions are typical values, to be checked against the supplier's.

```jldoctest
julia> acid_milliequivalents(LacticAcid(), 1u"mL")
11.489505404836624
```
"""
function acid_milliequivalents(acid::AbstractAcid, volume::Unitful.Volume; ph::Real = 5.4)
    a = _acid(acid)
    mg = ustrip(u"mg", volume * acid.density) * acid.strength
    return mg / a.M * _protons(a.pKa, ph)
end

# Mash pH

"""
    BASE_MALT_DI_PH

The usual pH of a mash of pale base malt in distilled water, 5.7, the default of
[`mash_ph`](@ref): a rule of thumb, from secondary sources. The distilled water pH of
crystal and roasted malts is much lower, and must be given.
"""
const BASE_MALT_DI_PH = 5.7

"""
    MALT_BUFFERING

The usual buffering capacity of malts, 40 mEq/(kg pH), the default of [`mash_ph`](@ref): a
rule of thumb, from secondary sources, consistent with the shift of about 0.1 pH per mEq/L of
residual alkalinity at 4 L/kg reported by Troester.
"""
const MALT_BUFFERING = 40.0

"""
    mash_ph(grist, water, residual_alkalinity; acids = [])

An estimate of the pH of a mash, by a balance of charges: each malt of the `grist` resists
moving from its distilled water pH with its buffering capacity, and the water and the acids
push it,

    Σ mᵢ bᵢ (pH - pHᵢ) = V RA - acid,

with the masses `mᵢ` (kg), buffering capacities `bᵢ` (mEq/(kg pH)) and distilled water pH
`pHᵢ` of the malts, the volume `V` of `water` (L), its Kolbach residual alkalinity `RA`
(mEq/L, from mg/L as CaCO₃, see [`residual_alkalinity`](@ref)), and the milliequivalents of
`acids` (pairs `acid => volume`, see [`acid_milliequivalents`](@ref), at the resulting pH).

Each malt is a NamedTuple `(mass, di_ph, buffering)`; `di_ph` and `buffering` may be
`nothing`, for the defaults [`BASE_MALT_DI_PH`](@ref) and [`MALT_BUFFERING`](@ref), right
only for pale base malts. The pH is returned as a plain number.

# References

- The model of a balance of charges with linear buffering, in K. Troester, "The Effect of
  Brewing Water and Grist Composition on the pH of the Mash", braukaiser.com, 2009, and
  A. J. deLange's notes on estimating the mash pH, as described in J. Palmer, "Exploring
  the effect of residual alkalinity", ASBC 2016
  (<https://www.asbcnet.org/events/archives/2016/proceedings/Documents/GC_Water_Palmer.pdf>),
  which reports about 0.1 pH per mEq/L of residual alkalinity at 4 L/kg, as given here by a
  buffering of 40 mEq/(kg pH). The original papers were not found.

```jldoctest
julia> mash_ph([(mass = 5u"kg", di_ph = nothing, buffering = nothing)], 15u"L", 50u"mg/L")
5.774935555422337
```
"""
function mash_ph(grist, water::Unitful.Volume, residual_alkalinity; acids = [])
    num, den = 0.0, 0.0
    for m in grist
        kg = ustrip(u"kg", float(m.mass))
        b = something(m.buffering, MALT_BUFFERING)
        num += kg * b * something(m.di_ph, BASE_MALT_DI_PH)
        den += kg * b
    end
    den > 0 || throw(ArgumentError("a mash needs malt"))
    alk = milliequivalents(residual_alkalinity) * ustrip(u"L", float(water))
    ph = (num + alk) / den
    for _ in 1:50                       # (the acids give more protons at a higher pH)
        acid = sum((acid_milliequivalents(a, v; ph) for (a, v) in acids); init = 0.0)
        new = (num + alk - acid) / den
        abs(new - ph) < 1e-10 && return new
        ph = new
    end
    return ph
end
