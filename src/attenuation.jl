# Attenuation, alcohol and calories, following Balling's relations. Extracts in °P.

"""
    ETHANOL_RELATIVE_DENSITY

Density of ethanol relative to water, both at 20 °C: `0.78924 / 0.998203 ≈ 0.7907`, used to
convert alcohol by weight into alcohol by volume. Hall (1995) uses `0.794`, the specific
gravity of ethanol at 15 °C, which gives ABVs about 0.4% (relative) lower.

# References

- Density of ethanol at 20 °C, 0.78924 g/mL: CRC Handbook of Chemistry and Physics.
- G. S. Kell, "Density, thermal expansivity, and compressibility of liquid water from 0° to
  150 °C", *J. Chem. Eng. Data* 20 (1975) 97–105, <https://doi.org/10.1021/je60064a005>.
- M. L. Hall, "Brew By the Numbers — Add Up What's in Your Beer", *Zymurgy*, Summer 1995,
  pp. 54–61.
"""
const ETHANOL_RELATIVE_DENSITY = 0.78924 / 0.998203

# plain-number kernels, all extracts in °P
_real_extract(oe, ae) = 0.1808oe + 0.8192ae
_apparent_extract(oe, re) = (re - 0.1808oe) / 0.8192
_abw(oe, re) = (oe - re) / (2.0665 - 0.010665oe)
_real_extract_from_abw(oe, w) = oe - w * (2.0665 - 0.010665oe)
_attenuation(oe, e) = oe == 0 ? 0.0 : 1 - e / oe

"""
    apparent_attenuation(og, fg; eq = SugarGravityQuad())

The apparent attenuation `1 - AE / OE`, from the original gravity `og` and the (apparent)
final gravity `fg`, with the extracts in °P.

```jldoctest
julia> apparent_attenuation(15u"°P", 3.83u"°P")
74.46666666666665 %
```
"""
apparent_attenuation(og, fg; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    _percent(_attenuation(_plato(og, eq), _plato(fg, eq)))

"""
    real_extract(og, fg; eq = SugarGravityQuad())

The real extract `RE = 0.1808 OE + 0.8192 AE` (Balling), in °P, from the original gravity
`og` and the apparent final gravity `fg`.

# References

- J. De Clerck, *A Textbook of Brewing*, Chapman & Hall, 1958, after C. J. N. Balling.
- M. L. Hall, "Brew By the Numbers — Add Up What's in Your Beer", *Zymurgy*, Summer 1995,
  pp. 54–61 (Equation 11).
"""
real_extract(og, fg; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    _real_extract(_plato(og, eq), _plato(fg, eq)) * u"°P"

"""
    apparent_extract(og, re; eq = SugarGravityQuad())

The apparent extract, in the unit of `og`, from the original gravity `og` and the real
extract `re`; the inverse of [`real_extract`](@ref).
"""
apparent_extract(og, re; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    _like(og, _apparent_extract(_plato(og, eq), _plato(re, eq)), eq)

"""
    real_attenuation(og, fg; eq = SugarGravityQuad())

The real attenuation `1 - RE / OE`, from the original gravity `og` and the apparent final
gravity `fg`.
"""
function real_attenuation(og, fg; eq::Equivalence = DEFAULT_EQUIVALENCE)
    oe = _plato(og, eq)
    return _percent(_attenuation(oe, _real_extract(oe, _plato(fg, eq))))
end

"""
    final_gravity(og, attenuation; eq = SugarGravityQuad())

The apparent final gravity, in the unit of `og`, reached from the original gravity `og`
with the given apparent `attenuation` (a percentage or fraction): `AE = (1 - a) OE`.

```jldoctest
julia> final_gravity(1.050u"sg", 75u"percent")
1.0121194807789198 sg
```
"""
final_gravity(og, attenuation; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    _like(og, (1 - _fraction(attenuation)) * _plato(og, eq), eq)

"""
    abw(og, fg; eq = SugarGravityQuad())

The alcohol by weight, from the original gravity `og` and the apparent final gravity `fg`,
by Balling's relation `ABW = (OE - RE) / (2.0665 - 0.010665 OE)`.

# References

- J. De Clerck, *A Textbook of Brewing*, Chapman & Hall, 1958, after C. J. N. Balling.
- M. L. Hall, "Brew By the Numbers — Add Up What's in Your Beer", *Zymurgy*, Summer 1995,
  pp. 54–61 (Equation 16).

```jldoctest
julia> abw(15u"°P", 3.83u"°P")
4.799551015591193 %
```
"""
function abw(og, fg; eq::Equivalence = DEFAULT_EQUIVALENCE)
    oe = _plato(og, eq)
    return _percent(_abw(oe, _real_extract(oe, _plato(fg, eq))) / 100)
end

"""
    real_extract_from_abw(og, abw; eq = SugarGravityQuad())

The real extract, in °P, of a beer with original gravity `og` and alcohol by weight `abw`;
the inverse of [`abw`](@ref) in terms of the real extract.
"""
real_extract_from_abw(og, w; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    _real_extract_from_abw(_plato(og, eq), 100 * _fraction(w)) * u"°P"

"""
    abv([model = Balling()], og, fg; eq = SugarGravityQuad())

The alcohol by volume, from the original gravity `og` and the apparent final gravity `fg`,
with the given [`ABVModel`](@ref):

- [`Balling`](@ref): `ABV = ABW × FG / ρ_ethanol`;
- [`SimpleABV`](@ref): `ABV = 131.25 (OG - FG)`, gravities in sg.

See the models for the references.

```jldoctest
julia> abv(1.050u"sg", 1.010u"sg")
5.316690074810317 %

julia> abv(SimpleABV(), 1.050u"sg", 1.010u"sg")
5.250000000000004 %
```
"""
abv(og, fg; eq::Equivalence = DEFAULT_EQUIVALENCE) = abv(DEFAULT_MODELS.abv, og, fg; eq)

function abv(::Balling, og, fg; eq::Equivalence = DEFAULT_EQUIVALENCE)
    oe, ae = _plato(og, eq), _plato(fg, eq)
    w = _abw(oe, _real_extract(oe, ae))
    return _percent(w * _sg(fg, eq) / ETHANOL_RELATIVE_DENSITY / 100)
end

abv(::SimpleABV, og, fg; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    _percent(1.3125 * (_sg(og, eq) - _sg(fg, eq)))

"""
    calories(og, fg, volume; eq = SugarGravityQuad())

The energy, in `kcal`, of a `volume` of beer with original gravity `og` and apparent final
gravity `fg`: `FG × V(mL) × (6.9 ABW + 4.0 (RE - 0.1)) / 100`, with ABW in percent by
weight and RE in °P: 6.9 kcal per gram of alcohol and 4 kcal per gram of real extract less
0.1% of ash, per 100 g of beer, as in the Python BrewQuiver.

# References

- G. Oliver (ed.), *The Oxford Companion to Beer*, Oxford University Press, 2011, entry
  "calories", as quoted in "Counting Calories & Carbs", *Brew Your Own*,
  <https://byo.com/articles/counting-calories-carbs/>.
- M. L. Hall, "Brew By the Numbers — Add Up What's in Your Beer", *Zymurgy*, Summer 1995,
  pp. 54–61, Equation 22, gives a variant per 12 US fl oz,
  `3.55 FG (4.08 RE + 7.1 ABW)`, which also counts the protein.

```jldoctest
julia> calories(15u"°P", 3.83u"°P", 330u"mL")
187.9616874164696 kcal
```
"""
function calories(og, fg, volume::Unitful.Volume; eq::Equivalence = DEFAULT_EQUIVALENCE)
    oe, ae = _plato(og, eq), _plato(fg, eq)
    re = _real_extract(oe, ae)
    return _sg(fg, eq) * _val(u"mL", volume) * (6.9 * _abw(oe, re) + 4.0 * (re - 0.1)) / 100 *
           u"kcal"
end
