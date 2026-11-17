"""
    AbstractModel

Supertype of the models, the singleton types that select one of several empirical formulas
for the same quantity, by dispatch. New models are added by defining a subtype and the
corresponding methods, e.g.

```julia
struct MyUtilization <: BitternessModel end
BrewingFormulas.utilization(::MyUtilization, gravity, time; eq = SugarGravityQuad()) = ...
```

The sources of the formulas are given in each docstring and collected in the file
`REFERENCES.md` of the package.
"""
abstract type AbstractModel end

"""
    BitternessModel

Models for the utilization of alpha acids in the boil: [`Tinseth`](@ref), [`Rager`](@ref).
"""
abstract type BitternessModel <: AbstractModel end

"""
    Tinseth()

Glenn Tinseth's model for the utilization of alpha acids,
`utilization = 1.65 × 0.000125^(sg - 1) × (1 - exp(-0.04 t)) / 4.15`, with `t` in minutes:
the product of a "bigness factor", accounting for the gravity of the wort, and a "boil time
factor".

Tinseth's model was not derived for pellets; the usual increase of about 10% for pellets is
a homebrewing convention, applied here through the keyword `factor`.

# References

- G. Tinseth, hop utilization page, <http://www.realbeer.com/hops/research.html> (the
  realbeer.com site has since been retired); also in N. Pyle's Hops FAQ,
  <http://www.realbeer.com/hops/FAQ.html>, the source cited by the Python BrewQuiver.
"""
struct Tinseth <: BitternessModel end

"""
    Rager()

Jackie Rager's model for the utilization of alpha acids,
`utilization = (18.11 + 13.86 tanh((t - 31.32) / 18.27)) / 100 / (1 + GA)`, with `t` in
minutes and the gravity adjustment `GA = max(0, (sg - 1.050) / 0.2)`, `sg` being the gravity
of the boiling wort.

Rager published the utilization as a table of boil times, together with the gravity
adjustment; the `tanh` expression is a curve fit to that table, as given in Norm Pyle's Hops
FAQ.

# References

- J. Rager, "Calculating Hop Bitterness in Beer", *Zymurgy*, Special Issue 1990, pp. 53–54
  (reproduced at <https://bwelman.github.io/bier/calculating-hop-bitterness/hop-bitterness.html>).
- N. Pyle, Hops FAQ, <http://www.realbeer.com/hops/FAQ.html> (the source cited by the
  Python BrewQuiver).
"""
struct Rager <: BitternessModel end

"""
    ColorModel

Models converting malt color units (MCU) to SRM: [`Morey`](@ref), [`Daniels`](@ref),
[`Mosher`](@ref), [`DrueyDaniels`](@ref), [`DrueyNoonan`](@ref).

# References

- D. Morey, "Approximating SRM Beer Color of Homebrew Based on Recipe Formulation", 2015,
  <https://bwelman.github.io/bier/beer-color/beer-color.html>, which compares all of them.
"""
abstract type ColorModel <: AbstractModel end

"""
    Morey()

Dan Morey's power model, `SRM = 1.4922 MCU^0.6859`, recommended for colors up to 50 SRM.

# References

- D. Morey, "Approximating SRM Beer Color of Homebrew Based on Recipe Formulation", 2015,
  <https://bwelman.github.io/bier/beer-color/beer-color.html>.
"""
struct Morey <: ColorModel end

"""
    Daniels()

Ray Daniels' linear model, `SRM = 0.2 MCU + 8.4`, from homebrew competition samples; meant
for darker beers, as it gives at least 8.4 SRM.

# References

- R. Daniels, *Designing Great Beers: The Ultimate Guide to Brewing Classic Beer Styles*,
  Brewers Publications, 1998.
- D. Morey (2015), see [`Morey`](@ref), for the formula as quoted here.
"""
struct Daniels <: ColorModel end

"""
    Mosher()

Randy Mosher's linear model, `SRM = 0.3 MCU + 4.7`, from commercial beers of known recipe
and color; meant for darker beers, as it gives at least 4.7 SRM.

# References

- D. Morey (2015), see [`Morey`](@ref), for the formula and its attribution to R. Mosher.
"""
struct Mosher <: ColorModel end

"""
    DrueyDaniels()

Kyle Druey's power fit to Ray Daniels' data, `SRM = 1.73 MCU^0.64 - 0.27` (named
"Druey-Daniels" in the Python BrewQuiver).

# References

- K. Druey, Home Brew Digest, as reported by D. Morey (2015), see [`Morey`](@ref).
- R. Daniels, *Designing Great Beers*, Brewers Publications, 1998, p. 61 (the data).
"""
struct DrueyDaniels <: ColorModel end

"""
    DrueyNoonan()

Kyle Druey's power fit to Greg Noonan's data, `SRM = 15.03 MCU^0.27 - 15.53` (named
"Druey-Noonan" in the Python BrewQuiver).

# References

- K. Druey, Home Brew Digest, as reported by D. Morey (2015), see [`Morey`](@ref).
- G. J. Noonan, *New Brewing Lager Beer*, revised and expanded edition, Brewers
  Publications, 2003, p. 206 (the data).
"""
struct DrueyNoonan <: ColorModel end

"""
    ABVModel

Models for the alcohol by volume: [`Balling`](@ref), [`SimpleABV`](@ref).
"""
abstract type ABVModel <: AbstractModel end

"""
    Balling()

Balling's relations between original extract, real extract and alcohol: the real extract
`RE = 0.1808 OE + 0.8192 AE`, the alcohol by weight `ABW = (OE - RE) / (2.0665 - 0.010665 OE)`
and the alcohol by volume `ABV = ABW × FG / ρ_ethanol`, all extracts in °P.

The constant 2.0665 comes from Balling's mass balance of fermentation: 2.0665 g of extract
give 1 g of ethanol, 0.9565 g of CO₂ and 0.11 g of yeast dry matter. For the relative density
of ethanol, Hall uses 0.794; here it is [`ETHANOL_RELATIVE_DENSITY`](@ref) ≈ 0.7907, the
ratio of the densities of ethanol and water at 20 °C, consistent with the Plato tables.

# References

- C. J. N. Balling, *Die Gährungschemie*, Prague, 1845–1865 (three editions).
- J. De Clerck, *A Textbook of Brewing*, Chapman & Hall, 1958.
- M. L. Hall, "Brew By the Numbers — Add Up What's in Your Beer", *Zymurgy*, Summer 1995,
  pp. 54–61 (the relations as used here, after De Clerck).
- J. Šavel, P. Košin, A. Brož, J. Vlček, "Interpolation formulas for Balling's alcohol
  factors", *Kvasny prumysl* 66 (2020) 239–244, <https://doi.org/10.18832/kp2019.66.239>
  (the mass balance).
"""
struct Balling <: ABVModel end

"""
    SimpleABV()

The usual homebrewing approximation `ABV = 131.25 (OG - FG)`, with gravities in sg, adequate
for usual beers but increasingly inaccurate for high gravities.

# References

- A widespread homebrewing formula; no primary source for it was found.
"""
struct SimpleABV <: ABVModel end

"""
    RefractometerModel

Models for estimating the final gravity from refractometer readings:
[`TerrillLinear`](@ref), [`TerrillCubic`](@ref).
"""
abstract type RefractometerModel <: AbstractModel end

"""
    TerrillLinear()

Sean Terrill's linear fit of the final gravity from the refractometer readings `RIi` and
`RIf` (in Brix, divided by the wort correction factor) before and after fermentation:
`FG = 1 - 0.00085683 RIi + 0.0034941 RIf`.

# References

- S. Terrill, "Refractometer FG Results", 7 April 2011,
  <http://seanterrill.com/2011/04/07/refractometer-fg-results/> (cited by the Python
  BrewQuiver).
"""
struct TerrillLinear <: RefractometerModel end

"""
    TerrillCubic()

Sean Terrill's cubic fit of the final gravity from the refractometer readings `RIi` and
`RIf` (in Brix, divided by the wort correction factor) before and after fermentation:

    FG = 1 - 0.0044993 RIi + 0.011774 RIf + 0.00027581 RIi² - 0.0012717 RIf²
           - 0.0000072800 RIi³ + 0.000063293 RIf³.

# References

- S. Terrill, "Refractometer FG Results", 7 April 2011,
  <http://seanterrill.com/2011/04/07/refractometer-fg-results/> (cited by the Python
  BrewQuiver).
"""
struct TerrillCubic <: RefractometerModel end

"""
    DEFAULT_MODELS

The models used when none is given:

- `gravity = SugarGravityQuad()`, the equivalence between °P and sg;
- `bitterness = Tinseth()`;
- `color = Morey()`;
- `abv = Balling()`;
- `refractometer = TerrillCubic()`.
"""
const DEFAULT_MODELS = (
    gravity = SugarGravityQuad(),
    bitterness = Tinseth(),
    color = Morey(),
    abv = Balling(),
    refractometer = TerrillCubic(),
)
