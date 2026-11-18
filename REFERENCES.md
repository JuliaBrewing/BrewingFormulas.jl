# References

The sources of the formulas of BrewingFormulas, also given in the docstrings.

The column **Python** tells whether the Python BrewQuiver (2018), from which most formulas
were ported, credited the formula. The column **Checked** tells how the attribution was
verified for this package:

- *original*: in the original publication;
- *secondary*: in a reliable secondary source quoting the original, which was not
  accessible;
- *not found*: no primary source was found; the formula is credited as commonly used.

| Formula | Function / model | Source | Python | Checked |
|---|---|---|---|---|
| °P ↔ sg, quadratic | `SugarGravityQuad` (UnitfulBrewing) | Robbins (1975), per [BF2012] | no | secondary |
| Density of water | `water_density`, `WATER_DENSITY_20C` | [Kell1975] | — | original (citation) |
| Extract mass, solution volume | `extract_mass`, `solution_volume`, ... | definitions of °P and sg | — | — |
| Hydrometer correction | `hydrometer_correction` | [Lyons1992] | no | original |
| Sucrose 46.214 PPG | `SUCROSE_PPG` | ≈ 46 PPG is the usual value; 46.214 not found | — | not found |
| Real extract, `RE = 0.1808 OE + 0.8192 AE` | `real_extract`, `Balling` | Balling, via [DeClerck1958], [Hall1995] Eq. 11 | no | original (Hall) |
| Alcohol by weight | `abw`, `Balling` | Balling, via [DeClerck1958], [Hall1995] Eq. 16 | no | original (Hall) |
| Balling's mass balance (2.0665 g → 1 + 0.9565 + 0.11 g) | `Balling` | [Savel2020] | no | original |
| ABV from ABW | `abv(::Balling, ...)` | [Hall1995] Eq. 18, with ρ = 0.794; here 0.7907 (20/20) | no | original |
| `ABV = 131.25 (OG - FG)` | `SimpleABV` | widespread homebrewing formula | — | not found |
| Calories | `calories` | [Oliver2011], as quoted in [BYOcal]; variant in [Hall1995] Eq. 22 | no | secondary |
| Refractometer FG, linear and cubic | `TerrillLinear`, `TerrillCubic` | [Terrill2011] | **yes** | secondary |
| Wort correction factor 1.04 | `refractometer_gravity` | common default (factor "mosto" in Python) | no | not found |
| MCU | `mcu` | [Morey2015] | no | original |
| Morey | `Morey` | [Morey2015] | name only | original |
| Daniels | `Daniels` | [Daniels1998], as quoted in [Morey2015] | no | secondary |
| Mosher | `Mosher` | R. Mosher, as quoted in [Morey2015] | no | secondary |
| Druey's fit to Daniels' data | `DrueyDaniels` | K. Druey (Home Brew Digest), in [Morey2015]; data [Daniels1998] p. 61 | name only ("Druey-Daniels") | secondary |
| Druey's fit to Noonan's data | `DrueyNoonan` | K. Druey (Home Brew Digest), in [Morey2015]; data [Noonan2003] p. 206 | name only ("Druey-Noonan") | secondary |
| SRM → RGB table | `srm_rgb`, `srm_hex` | unknown | no | not found |
| Tinseth utilization | `Tinseth` | [Tinseth], [Pyle] | **yes** ([Pyle]) | secondary |
| Rager utilization (tanh fit) | `Rager` | table and gravity adjustment [Rager1990]; tanh fit in [Pyle] | **yes** ([Pyle]) | secondary |
| Isomerization rate (Arrhenius), relative rate below boiling | `isomerization_rate`, `isomerization_factor` | [Malowicki2005], constants as quoted by brewing calculators; they reproduce the relative rates quoted in [MTFhops] at 96 °C (72%) and 90 °C (43%), not its 17% at 82 °C (here 20%) | no | not found (constants) |
| Pellet factor +10% | `factor` keyword (BrewQuiver: `HOP_FORM_FACTORS`) | homebrewing convention, not part of Tinseth's model | no | not found |
| IBU = 1 mg/L of iso-alpha acids | `ibu` | usual approximation | — | — |
| Strike temperature, infusion | `strike_temperature`, `infusion_volume` | [Palmer] | no | secondary |
| Grain displacement 0.67 L/kg | `mash_volume` | [BYOwater] | no | secondary |
| Grain absorption | `grain_absorption` | rule of thumb ≈ 0.83 L/kg [AHAbiab]; software 0.7–1.2 L/kg | no | secondary |
| Residual CO₂ | `residual_co2` | [Hall1995] Eq. 26 | no | original |
| Priming sugar | `priming_sugar`, `co2_yield` | stoichiometry; compare [Hall1995] Eq. 29 (anhydrous glucose) | no | original (Hall) |
| Force carbonation pressure | `carbonation_pressure`, `carbonation_level` | fit to carbonation charts used by most calculators | no | not found |
| Pitch rates 0.75 / 1.5 | `pitch_cells` | G. Fix, as in [White2010] | no | secondary |
| Thermal contraction, evaporation | `volume_at_temperature`, `evaporated_volume` | [Kell1975]; definitions | — | — |

## Bibliography

- **[AHAbiab]** American Homebrewers Association, "How To Brew in a Bag",
  <https://www.homebrewersassociation.org/wp-content/uploads/How-To-Brew-in-a-Bag.pdf>.
- **[BF2012]** "On the relationship between Plato and specific gravity", Brewer's Friend,
  31 October 2012,
  <https://www.brewersfriend.com/2012/10/31/on-the-relationship-between-plato-and-specific-gravity>.
- **[BYOcal]** "Counting Calories & Carbs", *Brew Your Own*,
  <https://byo.com/articles/counting-calories-carbs/>.
- **[BYOwater]** "Calculating Water Usage", *Brew Your Own*,
  <https://byo.com/articles/calculating-water-usage/>.
- **[Daniels1998]** R. Daniels, *Designing Great Beers: The Ultimate Guide to Brewing
  Classic Beer Styles*, Brewers Publications, 1998.
- **[DeClerck1958]** J. De Clerck, *A Textbook of Brewing*, Chapman & Hall, London, 1958.
  It presents C. J. N. Balling's relations, which Balling published between 1843 and 1865.
- **[Hall1995]** M. L. Hall, "Brew By the Numbers — Add Up What's in Your Beer",
  *Zymurgy*, Summer 1995, pp. 54–61.
- **[Kell1975]** G. S. Kell, "Density, thermal expansivity, and compressibility of liquid
  water from 0° to 150 °C", *J. Chem. Eng. Data* 20 (1975) 97–105,
  <https://doi.org/10.1021/je60064a005>.
- **[Lyons1992]** C. Lyons, "Hydrometer Temperature Corrections", Homebrew Digest #963,
  7 September 1992, <https://brewery.org/library/HydromCorr0992.html>.
- **[Malowicki2005]** M. G. Malowicki and T. H. Shellhammer, "Isomerization and Degradation
  Kinetics of Hop (*Humulus lupulus*) Acids in a Model Wort-Boiling System", *J. Agric.
  Food Chem.* 53 (2005) 4434–4439, <https://doi.org/10.1021/jf0481296>.
- **[MTFhops]** "Hops", Milk The Funk Wiki, section on isomerization below boiling,
  <https://www.milkthefunk.com/wiki/Hops>.
- **[Morey2015]** D. Morey, "Approximating SRM Beer Color of Homebrew Based on Recipe
  Formulation", 2015, <https://bwelman.github.io/bier/beer-color/beer-color.html>.
- **[Noonan2003]** G. J. Noonan, *New Brewing Lager Beer*, revised and expanded edition,
  Brewers Publications, 2003.
- **[Oliver2011]** G. Oliver (ed.), *The Oxford Companion to Beer*, Oxford University Press,
  2011.
- **[Palmer]** J. Palmer, *How to Brew*, chapter "The Methods of Mashing",
  <https://howtobrew.com>.
- **[Pyle]** N. Pyle, Hops FAQ, <http://www.realbeer.com/hops/FAQ.html> (the realbeer.com
  site has been retired; the reference cited by the Python BrewQuiver).
- **[Rager1990]** J. Rager, "Calculating Hop Bitterness in Beer", *Zymurgy*, Special Issue
  1990, pp. 53–54; reproduced at
  <https://bwelman.github.io/bier/calculating-hop-bitterness/hop-bitterness.html>.
- **[Savel2020]** J. Šavel, P. Košin, A. Brož, J. Vlček, "Interpolation formulas for
  Balling's alcohol factors", *Kvasny prumysl* 66 (2020) 239–244,
  <https://doi.org/10.18832/kp2019.66.239>.
- **[Terrill2011]** S. Terrill, "Refractometer FG Results", 7 April 2011,
  <http://seanterrill.com/2011/04/07/refractometer-fg-results/> (the reference cited by the
  Python BrewQuiver).
- **[Tinseth]** G. Tinseth, hop utilization page, <http://www.realbeer.com/hops/research.html>
  (retired site).
- **[White2010]** C. White, J. Zainasheff, *Yeast: The Practical Guide to Beer Fermentation*,
  Brewers Publications, 2010.

## Notes on the Python BrewQuiver

- Its `abv_via_extrato_final_aparente` passed the *apparent* final extract to
  `conteudo_alcoolico_peso`, which expects the *real* one; `abv` here uses the real
  extract, as in Balling's relation.
- Its options "Druey-Daniels" and "Druey-Noonan" are Kyle Druey's power fits, and are
  `DrueyDaniels` and `DrueyNoonan` here.
- Its Tinseth utilization was divided by 0.9 ("since Tinseth is for leaf"), with a factor
  0.9 for leaf hops; here Tinseth's model is kept as published, and hop forms are handled by
  the `factor` keyword.
