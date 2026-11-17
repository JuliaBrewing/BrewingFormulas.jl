# Color: malt color units (MCU) and their conversion to SRM, and SRM to RGB for display.

"""
    mcu(mass, color, volume)
    mcu(bill, volume)

The malt color units, `MCU = mass(lb) × color(°L) / volume(gal)`, of a `mass` of grain of the
given `color` (in `°L`, `SRM` or `EBC`) in a `volume` of wort. With a `bill`, an iterable of
`mass => color` pairs, the sum of the MCUs of the grains. MCUs are additive, unlike SRM.

# References

- D. Morey, "Approximating SRM Beer Color of Homebrew Based on Recipe Formulation", 2015,
  <https://bwelman.github.io/bier/beer-color/beer-color.html>.

```julia
julia> mcu(4u"kg", 3u"°L", 20u"L")
5.007242671211599
```
"""
function mcu(mass::Unitful.Mass, color::ColorQuantity, volume::Unitful.Volume)
    gal = _val(u"gal", volume)
    gal == 0 && return 0.0
    return _val(u"lb", mass) * _val(u"°L", color) / gal
end

mcu(bill, volume::Unitful.Volume) = sum((mcu(m, c, volume) for (m, c) in bill); init = 0.0)

"""
    srm([model = Morey()], mcu)

The color, in `SRM`, of a wort with the given malt color units `mcu`, with the given
[`ColorModel`](@ref).

```julia
julia> srm(10)
7.239807780133753 SRM
```
"""
srm(mcu::Real) = srm(DEFAULT_MODELS.color, mcu)
srm(::Morey, mcu::Real) = (mcu > 0 ? 1.4922 * mcu^0.6859 : 0.0) * u"SRM"
srm(::Daniels, mcu::Real) = (0.2mcu + 8.4) * u"SRM"
srm(::Mosher, mcu::Real) = (0.3mcu + 4.7) * u"SRM"
srm(::DrueyDaniels, mcu::Real) = (mcu > 0 ? max(0.0, 1.73 * mcu^0.64 - 0.27) : 0.0) * u"SRM"
srm(::DrueyNoonan, mcu::Real) = (mcu > 0 ? max(0.0, 15.03 * mcu^0.27 - 15.53) : 0.0) * u"SRM"

"""
    wort_color([model = Morey()], bill, volume)

The color, in `SRM`, of a `volume` of wort with the grains of `bill`, an iterable of
`mass => color` pairs: `srm(model, mcu(bill, volume))`.
"""
wort_color(bill, volume::Unitful.Volume) = wort_color(DEFAULT_MODELS.color, bill, volume)
wort_color(model::ColorModel, bill, volume::Unitful.Volume) = srm(model, mcu(bill, volume))

# RGB colors of beer from 1 to 40 SRM
const _SRM_RGB = (
    (255, 230, 153), (255, 216, 120), (255, 202, 90), (255, 191, 66), (251, 177, 35),
    (248, 166, 0), (243, 156, 0), (234, 143, 0), (229, 133, 0), (222, 124, 0),
    (215, 114, 0), (207, 105, 0), (203, 98, 0), (195, 89, 0), (187, 81, 0),
    (181, 76, 0), (176, 69, 0), (166, 62, 0), (161, 55, 0), (155, 50, 0),
    (149, 45, 0), (142, 41, 0), (136, 35, 0), (130, 30, 0), (123, 26, 0),
    (119, 25, 0), (112, 20, 0), (106, 14, 0), (102, 13, 0), (94, 11, 0),
    (90, 10, 2), (96, 9, 3), (82, 9, 7), (76, 5, 5), (71, 6, 6),
    (68, 6, 7), (63, 7, 8), (59, 6, 7), (58, 7, 11), (54, 8, 10),
)

"""
    srm_rgb(color)

An `(r, g, b)` tuple of integers in `0:255` representing a beer of the given `color` (in
`SRM`, `EBC` or `°L`), interpolated in a table from 1 to 40 SRM; colors outside this range
are clamped to it.

# References

- The table comes from the Python BrewQuiver, which gives no source for it, and no source
  was found. For a physically based alternative, see A. J. deLange's spectral model of beer
  color, implemented e.g. in <https://pypi.org/project/olfarve/>.
"""
function srm_rgb(color::ColorQuantity)
    v = clamp(_val(u"SRM", color), 1.0, 40.0)
    i = floor(Int, v)
    j = min(i + 1, 40)
    θ = v - i
    a, b = _SRM_RGB[i], _SRM_RGB[j]
    return ntuple(k -> round(Int, (1 - θ) * a[k] + θ * b[k]), 3)
end

"""
    srm_hex(color)

The hexadecimal RGB string, as `"#rrggbb"`, of [`srm_rgb`](@ref)`(color)`.
"""
srm_hex(color::ColorQuantity) = "#" * join(string(c; base = 16, pad = 2) for c in srm_rgb(color))
