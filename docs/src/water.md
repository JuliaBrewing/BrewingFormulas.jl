```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# Water

The chemistry of brewing water: the ions added by salts, alkalinity and hardness, Kolbach's
residual alkalinity, the protons given by acids, and an estimate of the mash pH by a balance
of charges. Concentrations are in mg/L (or ppm); alkalinity, hardness and residual alkalinity
are in mg/L as CaCO₃, one milliequivalent per liter being 50.04 mg/L as CaCO₃.

```@docs
alkalinity
calcium_hardness
magnesium_hardness
milliequivalents
residual_alkalinity
AbstractSalt
Gypsum
CalciumChloride
EpsomSalt
MagnesiumChloride
TableSalt
BakingSoda
Chalk
SlakedLime
ions
AbstractAcid
LacticAcid
PhosphoricAcid
acid_milliequivalents
BASE_MALT_DI_PH
MALT_BUFFERING
mash_ph
```
