# Refractometer readings. Refractometers are calibrated for sucrose, and wort reads higher
# by the wort correction factor (≈ 1.04). Once fermentation starts, alcohol distorts the
# reading, and the final gravity must be estimated by an empirical fit.

"""
    refractometer_gravity(reading; wcf = 1.04)

The gravity, in `°P`, of an unfermented wort from the refractometer `reading` (in `Brix`),
corrected by the wort correction factor `wcf`.
"""
refractometer_gravity(reading::SugarContents; wcf::Real = 1.04) =
    _val(u"°P", reading) / wcf * u"°P"

"""
    refractometer_final_gravity([model = TerrillCubic()], initial, final; wcf = 1.04)

The apparent final gravity, in `sg`, estimated from the refractometer readings (in `Brix`)
of the wort before fermentation, `initial`, and of the fermented beer, `final`, both
corrected by the wort correction factor `wcf`, with Sean Terrill's fits
([`TerrillCubic`](@ref) or [`TerrillLinear`](@ref)).

```julia
julia> refractometer_final_gravity(12u"Brix", 6.5u"Brix")
1.0129859456476515 sg
```
"""
refractometer_final_gravity(initial::SugarContents, final::SugarContents; wcf::Real = 1.04) =
    refractometer_final_gravity(DEFAULT_MODELS.refractometer, initial, final; wcf)

function refractometer_final_gravity(model::RefractometerModel, initial::SugarContents,
                                     final::SugarContents; wcf::Real = 1.04)
    bi = _val(u"°P", initial) / wcf
    bf = _val(u"°P", final) / wcf
    return _terrill(model, bi, bf) * u"sg"
end

_terrill(::TerrillLinear, bi, bf) = 1.0 - 0.00085683bi + 0.0034941bf
_terrill(::TerrillCubic, bi, bf) =
    1.0 - 0.0044993bi + 0.011774bf + 0.00027581bi^2 - 0.0012717bf^2 -
    0.0000072800bi^3 + 0.000063293bf^3
