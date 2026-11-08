#!/usr/bin/env python3
"""Generate the desktop wallpaper: a crescent moon over a night landscape.

Catppuccin Mocha palette (same as hypr/conf/colors.lua). Writes wallpaper.svg next to
this script; render it to PNG with:

    ./generate.py && rsvg-convert -w 3840 -h 2160 wallpaper.svg -o wallpaper.png

Pick the landscape with an argument (default: SCENE below):

    ./generate.py mountains   # layered jagged ranges fading into haze
    ./generate.py lake        # mountains reflected in still water, moon path on the water
    ./generate.py forest      # hazy ranges with a pine treeline in front

Change SEED for different shapes. -o PATH writes the SVG somewhere else.
"""
import argparse
import math
import random
from pathlib import Path

W, H = 3840, 2160
SEED = 7
SCENE = "lake"

# Catppuccin Mocha
CRUST, MANTLE, BASE = "#11111b", "#181825", "#1e1e2e"
SURFACE0, SURFACE1, SURFACE2 = "#313244", "#45475a", "#585b70"
OVERLAY0 = "#6c7086"
LAVENDER, ROSEWATER, BLUE = "#b4befe", "#f5e0dc", "#89b4fa"

# Moon: small, upper right, with a tight halo and a very faint wide haze
MOON_X, MOON_Y, MOON_R = W * 0.72, H * 0.22, 46

# How much darker the lake's reflection is than the mountains (0 = same color, 1 = black)
REFLECT_DARKEN = 0.30

# Rock shading strength: how much faces toward / away from the moon are lightened / darkened
TERRAIN_LIGHT = 0.25
TERRAIN_SHADE = 0.3
# How far the rock grain tilts from vertical to follow the slopes (degrees)
TERRAIN_TILT = 35


def mix(a, b, t):
    """Blend two hex colors; t=0 gives a, t=1 gives b."""
    ca = [int(a[i:i + 2], 16) for i in (1, 3, 5)]
    cb = [int(b[i:i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(x + (y - x) * t):02x}" for x, y in zip(ca, cb))


def falloff_stops(color, peak, steps=24, sharpness=3.2):
    """Radial gradient stops with an exponential falloff, so the glow has no visible rings."""
    out = []
    for i in range(steps + 1):
        t = i / steps
        o = peak * (math.exp(-sharpness * t) - math.exp(-sharpness)) / (1 - math.exp(-sharpness))
        out.append(f'<stop offset="{t:.3f}" stop-color="{color}" stop-opacity="{o:.4f}"/>')
    return "\n    ".join(out)


def smooth_stops(colors, steps=16):
    """Vertical gradient through several colors with smoothstep easing between them."""
    out = []
    for i in range(steps + 1):
        t = i / steps
        seg = min(int(t * (len(colors) - 1)), len(colors) - 2)
        u = t * (len(colors) - 1) - seg
        u = u * u * (3 - 2 * u)
        out.append(f'<stop offset="{t:.3f}" stop-color="{mix(colors[seg], colors[seg + 1], u)}"/>')
    return "\n    ".join(out)


# Sky color just above the horizon; far ranges sit just below this so their ridge doesn't glow
HORIZON_SKY = mix(BASE, SURFACE0, 0.55)

# Range colors from farthest to nearest: barely off the sky, then steadily darker
RANGE = [
    mix(HORIZON_SKY, SURFACE1, 0.30),
    mix(HORIZON_SKY, BASE, 0.40),
    mix(BASE, MANTLE, 0.35),
    MANTLE,
    mix(MANTLE, CRUST, 0.6),
]


def mountain_ridge(rng, base_y, height, roughness, peaks=3):
    """Jagged ridge line via midpoint displacement, shaped by a few broad peaks.

    roughness: 0.4 is smooth and distant, 0.6 is craggy and close.
    """
    n = 512
    v = [0.0] * (n + 1)
    v[0], v[n] = rng.uniform(-0.3, 0.3), rng.uniform(-0.3, 0.3)
    step, scale = n, 0.8
    while step > 1:
        half = step // 2
        for i in range(half, n, step):
            v[i] = (v[i - half] + v[i + half]) / 2 + rng.uniform(-1, 1) * scale
        scale *= roughness
        step = half
    lo, hi = min(v), max(v)
    v = [(x - lo) / (hi - lo) for x in v]

    # Broad peaks so the range has a few clear summits rather than even noise
    bumps = [(rng.uniform(0.05, 0.95), rng.uniform(0.08, 0.2), rng.uniform(0.5, 1.0)) for _ in range(peaks)]
    pts = []
    for i, x in enumerate(v):
        u = i / n
        env = 0.35 + sum(a * math.exp(-((u - c) / w) ** 2) for c, w, a in bumps)
        X = -40 + u * (W + 80)
        pts.append((X, base_y - x * env * height))
    return pts


def ridge_at(pts, x):
    """Height of a ridge polyline at x."""
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        if x0 <= x <= x1:
            return y0 + (y1 - y0) * (x - x0) / (x1 - x0)
    return pts[-1][1]


def closed(pts, bottom):
    d = f"M{pts[0][0]:.1f},{bottom:.1f} " + " ".join(f"L{x:.1f},{y:.1f}" for x, y in pts)
    return d + f" L{pts[-1][0]:.1f},{bottom:.1f} Z"


def pine(x, y, h, rng):
    """Pine silhouette: a trunk tip with stacked, slightly ragged tiers."""
    w = h * rng.uniform(0.28, 0.36)
    tiers = rng.randint(4, 6)
    left, right = [], []
    for t in range(tiers + 1):
        f = t / tiers                       # 0 at tip, 1 at base
        ty = y - h + f * h * 0.92
        tw = w * (0.12 + 0.88 * f) / 2
        jag = tw * rng.uniform(0.25, 0.45)  # notch between tiers
        left += [(x - tw, ty), (x - tw + jag, ty + 0.01)]
        right += [(x + tw, ty), (x + tw - jag, ty + 0.01)]
    pts = [(x, y - h * 1.04)] + right[1:] + [(x + w * 0.06, y), (x - w * 0.06, y)] + list(reversed(left[1:]))
    return "M" + " L".join(f"{px:.1f},{py:.1f}" for px, py in pts) + " Z"


def layer_gradient(i, top, bottom, color):
    """Lit at the crest, fading darker toward the base, like haze settling in valleys."""
    return f'''<linearGradient id="r{i}" x1="0" y1="{top:.0f}" x2="0" y2="{bottom:.0f}" gradientUnits="userSpaceOnUse">
  <stop offset="0" stop-color="{mix(color, LAVENDER, 0.025)}"/>
  <stop offset="1" stop-color="{mix(color, CRUST, 0.22)}"/>
</linearGradient>'''


def sky_and_moon(rng, horizon):
    parts = [f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">
<defs>
  <linearGradient id="sky" x1="0" y1="0" x2="0" y2="{horizon:.0f}" gradientUnits="userSpaceOnUse">
    {smooth_stops([CRUST, mix(CRUST, BASE, 0.6), BASE, HORIZON_SKY])}
  </linearGradient>
  <radialGradient id="haze" cx="{MOON_X}" cy="{MOON_Y}" r="{MOON_R * 26}" gradientUnits="userSpaceOnUse">
    {falloff_stops(LAVENDER, 0.06, sharpness=2.5)}
  </radialGradient>
  <radialGradient id="halo" cx="{MOON_X}" cy="{MOON_Y}" r="{MOON_R * 5}" gradientUnits="userSpaceOnUse">
    {falloff_stops(LAVENDER, 0.16, sharpness=4.0)}
  </radialGradient>
  <mask id="crescent" maskUnits="userSpaceOnUse" x="0" y="0" width="{W}" height="{H}">
    <circle cx="{MOON_X}" cy="{MOON_Y}" r="{MOON_R}" fill="white"/>
    <circle cx="{MOON_X + MOON_R * 0.42}" cy="{MOON_Y - MOON_R * 0.22}" r="{MOON_R * 0.86}" fill="black"/>
  </mask>
  <filter id="grain" x="0" y="0" width="100%" height="100%">
    <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="{SEED}"/>
    <feColorMatrix values="0 0 0 0 0.5  0 0 0 0 0.5  0 0 0 0 0.5  0 0 0 0.045 0"/>
  </filter>
</defs>
<rect width="{W}" height="{H}" fill="url(#sky)"/>
<rect width="{W}" height="{H}" fill="url(#haze)"/>''']

    # Faint stars, thinning toward the horizon and kept off the moon
    for _ in range(70):
        x, y = rng.uniform(0, W), H * 0.55 * rng.random() ** 1.6
        if math.hypot(x - MOON_X, y - MOON_Y) < MOON_R * 6:
            continue
        r = rng.uniform(1.0, 2.4)
        o = rng.uniform(0.12, 0.45) * (1 - y / (H * 0.6))
        parts.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r:.1f}" fill="{ROSEWATER}" opacity="{o:.2f}"/>')

    # Halo: soft falloff around the moon, then the crescent itself
    parts.append(f'<circle cx="{MOON_X}" cy="{MOON_Y}" r="{MOON_R * 5}" fill="url(#halo)"/>')
    parts.append(f'<circle cx="{MOON_X}" cy="{MOON_Y}" r="{MOON_R}" fill="{ROSEWATER}" opacity="0.95" mask="url(#crescent)"/>')
    return parts


def extrema(pts, min_drop, smooth=6):
    """Alternating (index, "peak"|"valley") along a ridge, ignoring bumps smaller than min_drop.

    Zigzag scan over a lightly smoothed ridge (remember: smaller y is higher).
    """
    ys = [p[1] for p in pts]
    k = smooth
    sm = [sum(ys[max(0, i - k):i + k + 1]) / len(ys[max(0, i - k):i + k + 1]) for i in range(len(ys))]
    res, trend = [], None
    hi = lo = 0
    for i in range(len(sm)):
        if trend != "down" and sm[i] < sm[hi]:
            hi = i
        if trend != "up" and sm[i] > sm[lo]:
            lo = i
        if trend != "down" and sm[i] - sm[hi] > min_drop:     # fell far enough below a peak
            res.append((hi, "peak")); trend = "down"; lo = i
        elif trend != "up" and sm[lo] - sm[i] > min_drop:     # rose far enough above a valley
            res.append((lo, "valley")); trend = "up"; hi = i
    return res


def mountain_details(i, pts, base, h, color, snow, rng):
    """Snow caps for one range (the rock shading is a lighting filter). Returns (defs, shapes)."""
    defs, shapes = [], []
    marks = extrema(pts, h * 0.07)
    peaks = [m for m, t in marks if t == "peak"]

    # Snow on the tallest peaks: a muted cap with a ragged lower edge
    if snow:
        snow_col = mix(color, "#cdd6f4", 0.28)
        tall = sorted(peaks, key=lambda m: pts[m][1])[:snow]
        for m in tall:
            px, py = pts[m]
            # The cap follows the ridge: thickest at the summit, thinning out down both slopes,
            # with a few narrow tongues of snow running down gullies
            depth = h * rng.uniform(0.07, 0.09)
            reach = W * rng.uniform(0.035, 0.05)
            tongues = [(px + rng.uniform(-1, 1) * reach * 0.8, rng.uniform(3, 7), rng.uniform(0.25, 0.7))
                       for _ in range(rng.randint(5, 9))]
            waves = [(rng.uniform(0, 6.3), rng.uniform(0.01, 0.03)) for _ in range(2)]
            cap = []
            for j in range(len(pts)):
                x, y = pts[j]
                u = (x - px) / reach
                if abs(u) >= 1:
                    continue
                thick = depth * (1 - u * u) ** 1.5
                thick *= 1 + 0.25 * sum(math.sin(x * f + ph) for ph, f in waves) / 2
                thick += sum(depth * a * math.exp(-abs(x - c) / w) for c, w, a in tongues) * (1 - u * u)
                # Only where the ridge is near the summit's height (no snow down in saddles)
                if y - py > depth * 2.2:
                    thick = 0
                cap.append((x, y, max(thick, 0)))
            if len(cap) < 4:
                continue
            poly = [(x, y) for x, y, _ in cap] + [(x, y + t) for x, y, t in reversed(cap)]
            defs.append(f'''<linearGradient id="snow{i}_{m}" x1="0" y1="{py:.0f}" x2="0" y2="{py + depth * 2.5:.0f}" gradientUnits="userSpaceOnUse">
  <stop offset="0" stop-color="{snow_col}" stop-opacity="0.95"/>
  <stop offset="1" stop-color="{snow_col}" stop-opacity="0.4"/>
</linearGradient>''')
            shapes.append(f'<path d="M{" L".join(f"{x:.1f},{y:.1f}" for x, y in poly)} Z" fill="url(#snow{i}_{m})"/>')

    return defs, shapes


def terrain_filter(fid, seed, h, azimuth):
    """Rock texture lit by the moon, as a faint overlay (no fill of its own).

    Builds a height map from broad noise (whole slopes tilting toward or away from the moon)
    plus finer noise stretched along the filter's y axis (ridges and gullies), lights it, and
    turns the result into a faint lavender tint on faces toward the light and a faint dark
    tint on faces away from it. Callers rotate the filtered group so "y" runs down the slope;
    `azimuth` is the light direction in that rotated frame.
    """
    lr, lg, lb = (int(LAVENDER[n:n + 2], 16) / 255 for n in (1, 3, 5))
    cr, cg, cb = (int(CRUST[n:n + 2], 16) / 255 for n in (1, 3, 5))
    flat = 0.64          # lighting value of a flat surface (sin of the light elevation, 40 deg)
    lit_k, shade_k = TERRAIN_LIGHT, TERRAIN_SHADE
    return f'''<filter id="{fid}" color-interpolation-filters="sRGB">
  <feTurbulence type="fractalNoise" baseFrequency="0.0011 0.0008" numOctaves="2" seed="{seed * 2}" result="broad"/>
  <feTurbulence type="fractalNoise" baseFrequency="0.0045 0.0016" numOctaves="5" seed="{seed}" result="fine"/>
  <feComposite in="broad" in2="fine" operator="arithmetic" k1="0" k2="1" k3="0.35" k4="-0.2" result="rough"/>
  <!-- slight blur smooths the 8-bit height steps, which would otherwise light up as contour rings -->
  <feGaussianBlur in="rough" stdDeviation="2" result="height"/>
  <feDiffuseLighting in="height" surfaceScale="{h * 0.03:.1f}" diffuseConstant="1" lighting-color="white" result="light">
    <feDistantLight azimuth="{azimuth % 360:.0f}" elevation="40"/>
  </feDiffuseLighting>
  <feColorMatrix in="light" result="lit" values="0 0 0 0 {lr:.3f}  0 0 0 0 {lg:.3f}  0 0 0 0 {lb:.3f}  {lit_k} 0 0 0 {-lit_k * flat:.3f}"/>
  <feColorMatrix in="light" result="shade" values="0 0 0 0 {cr:.3f}  0 0 0 0 {cg:.3f}  0 0 0 0 {cb:.3f}  {-shade_k} 0 0 0 {shade_k * flat:.3f}"/>
  <feMerge result="tint"><feMergeNode in="shade"/><feMergeNode in="lit"/></feMerge>
  <feComposite in="tint" in2="SourceAlpha" operator="in"/>
</filter>'''


def terrain_zones(i, pts, bottom, h):
    """Rock texture for one range, following the slopes.

    The range is split at its summits. Left of a summit the texture is tilted so its grain runs
    down and to the left, right of it down and to the right. Neighboring zones cross-fade, so
    there's no visible seam. Returns (defs, shapes).
    """
    defs, shapes = [], []
    summits = [m for m, t in extrema(pts, h * 0.12) if t == "peak"] or [min(range(len(pts)), key=lambda j: pts[j][1])]
    xs = [pts[m][0] for m in summits]
    mids = [(a + b) / 2 for a, b in zip(xs, xs[1:])]
    lo, hi = pts[0][0], pts[-1][0]
    edges = [lo] + mids + [hi]
    fade = W * 0.025
    zones = []
    for k, m in enumerate(summits):
        zones.append((edges[k], xs[k], TERRAIN_TILT, m))       # left of the summit: grain down-left
        zones.append((xs[k], edges[k + 1], -TERRAIN_TILT, m))  # right of it: grain down-right
    for z, (a, b, ang, m) in enumerate(zones):
        sx, sy = pts[m]
        a0, b0 = max(lo, a - fade), min(hi, b + fade)
        sub = [p for p in pts if a0 <= p[0] <= b0]
        if len(sub) < 3:
            continue
        # Cross-fade mask: ramps up across the left edge and down across the right edge
        span = b0 - a0
        ramp_in = [(0, 1)] if a <= lo else [(0, 0), (min(2 * fade / span, 0.5), 1)]
        ramp_out = [(1, 1)] if b >= hi else [(max(1 - 2 * fade / span, 0.5), 1), (1, 0)]
        stops = "".join(f'<stop offset="{o:.3f}" stop-color="white" stop-opacity="{v}"/>' for o, v in ramp_in + ramp_out)
        zid = f"t{i}_{z}"
        defs.append(f'<linearGradient id="{zid}g" x1="{a0:.0f}" y1="0" x2="{b0:.0f}" y2="0" gradientUnits="userSpaceOnUse">{stops}</linearGradient>')
        defs.append(f'<mask id="{zid}m" maskUnits="userSpaceOnUse" x="{a0:.0f}" y="0" width="{span:.0f}" height="{H}">'
                    f'<rect x="{a0:.0f}" y="0" width="{span:.0f}" height="{H}" fill="url(#{zid}g)"/></mask>')
        # Light comes from up-right (azimuth 320); in the rotated frame that shifts by -ang
        defs.append(terrain_filter(f"{zid}f", SEED * 10 + i * 7 + z, h, 320 - ang))
        shapes.append(f'<g mask="url(#{zid}m)"><g transform="rotate({ang} {sx:.0f} {sy:.0f})">'
                      f'<g filter="url(#{zid}f)"><g transform="rotate({-ang} {sx:.0f} {sy:.0f})">'
                      f'<path d="{closed(sub, bottom)}"/></g></g></g></g>')
    return defs, shapes


def range_layers(rng, specs, bottom, snow=(2, 1, 0)):
    """specs: (base_y, height, roughness, color).

    Returns (svg parts, ridge polylines, shapes) where shapes is the drawing without its
    <defs>, so it can be reused (e.g. mirrored in water) without duplicating ids.
    """
    defs, shapes, ridges = [], [], []
    for i, (y, h, rough, color) in enumerate(specs):
        pts = mountain_ridge(rng, y, h, rough)
        top = min(p[1] for p in pts)
        defs.append(layer_gradient(i, top, y + h * 0.6, color))
        defs.append(f'<clipPath id="clip{i}"><path d="{closed(pts, bottom)}"/></clipPath>')
        # Details use their own random stream, so the ridge shapes stay the same as before
        d_defs, d_shapes = mountain_details(i, pts, min(y + h * 0.2, bottom), h, color,
                                            snow[i] if i < len(snow) else 0, random.Random(SEED * 100 + i))
        defs += d_defs
        shapes.append(f'<path d="{closed(pts, bottom)}" fill="url(#r{i})"/>')
        shapes.append(f'<g clip-path="url(#clip{i})">{"".join(d_shapes)}</g>')
        t_defs, t_shapes = terrain_zones(i, pts, bottom, h)
        defs += t_defs
        shapes += t_shapes
        ridges.append(pts)
        # Mist settling at this layer's foot, so it fades into the next layer instead of a hard step
        if i < len(specs) - 1:
            nxt = specs[i + 1][0]
            m0, m1 = nxt - specs[i + 1][1] * 0.9, nxt
            d, r = mist_rect(i, m0, m1, color)
            defs.append(d)
            shapes.append(r)
    return defs + shapes, ridges, "".join(shapes)


def mist_rect(i, top, bottom, color):
    """A band of the layer's own color, transparent at the top and ~35% at the bottom."""
    return ((f'<linearGradient id="mist{i}" x1="0" y1="{top:.0f}" x2="0" y2="{bottom:.0f}" gradientUnits="userSpaceOnUse">'
             + "".join(f'<stop offset="{t / 8:.3f}" stop-color="{color}" stop-opacity="{0.35 * (t / 8) ** 2 * (3 - 2 * t / 8):.3f}"/>' for t in range(9))
             + '</linearGradient>'),
            f'<rect x="0" y="{top:.0f}" width="{W}" height="{bottom - top:.0f}" fill="url(#mist{i})"/>')


def scene_mountains(rng):
    parts = sky_and_moon(rng, H * 0.70)
    layers, _, _ = range_layers(rng, [
        (H * 0.66, 520, 0.42, RANGE[0]),
        (H * 0.74, 440, 0.48, RANGE[1]),
        (H * 0.82, 360, 0.52, RANGE[2]),
        (H * 0.92, 260, 0.56, RANGE[3]),
        (H * 1.02, 220, 0.58, RANGE[4]),
    ], H)
    return parts + layers


def scene_lake(rng):
    horizon = H * 0.68
    parts = sky_and_moon(rng, horizon)
    specs = [
        (horizon - 20, 560, 0.42, RANGE[0]),
        (horizon + 5,  380, 0.48, RANGE[1]),
        (horizon + 15, 200, 0.52, RANGE[2]),
    ]
    layers, ridges, shapes = range_layers(rng, specs, horizon + 2)
    parts += layers

    # Water: the sky's horizon color, darkened, getting deeper toward the viewer
    water_top = mix(HORIZON_SKY, MANTLE, 0.55)
    parts.append(f'''<linearGradient id="water" x1="0" y1="{horizon:.0f}" x2="0" y2="{H}" gradientUnits="userSpaceOnUse">
    {smooth_stops([water_top, mix(BASE, MANTLE, 0.5), CRUST])}
</linearGradient>
<clipPath id="lake"><rect x="0" y="{horizon:.0f}" width="{W}" height="{H - horizon:.0f}"/></clipPath>
<filter id="soft" x="-20%" y="-200%" width="140%" height="500%"><feGaussianBlur stdDeviation="2.5 1.2"/></filter>
<radialGradient id="moonpath" cx="0.5" cy="0" r="1">
    {falloff_stops(ROSEWATER, 0.10, sharpness=3.0)}
</radialGradient>''')
    parts.append(f'<rect x="0" y="{horizon:.0f}" width="{W}" height="{H - horizon:.0f}" fill="url(#water)"/>')

    # Ripples: the water is split into depth bands; each band gets a displacement filter that
    # shifts thin horizontal slices sideways. Bands nearer the shore have finer, smaller
    # ripples, so the surface reads as flat and receding. Used for the reflection and moonlight.
    bands = [  # (top, bottom) as fractions of the water depth, ripple frequency (y), shift in px
        (0.00, 0.08, 0.125, 20),
        (0.08, 0.22, 0.070, 42),
        (0.22, 0.45, 0.040, 75),
        (0.45, 1.00, 0.024, 115),
    ]
    depth = H - horizon
    for b, (t0, t1, fy, shift) in enumerate(bands):
        y0, y1 = horizon + depth * t0, horizon + depth * t1
        parts.append(f'''<clipPath id="band{b}"><rect x="0" y="{y0:.0f}" width="{W}" height="{y1 - y0 + 1:.0f}"/></clipPath>
<filter id="ripple{b}" filterUnits="userSpaceOnUse" x="0" y="{horizon:.0f}" width="{W}" height="{depth:.0f}">
  <feTurbulence type="fractalNoise" baseFrequency="{0.0012:.4f} {fy:.3f}" numOctaves="2" seed="{SEED + b}" result="noise"/>
  <!-- stretch red around the middle for stronger sideways shifts; alpha fixed at 0.5 = no vertical shift -->
  <feColorMatrix in="noise" result="n" values="2.4 0 0 0 -0.7  0 0 0 0 0  0 0 0 0 0  0 0 0 0 0.5"/>
  <feDisplacementMap in="SourceGraphic" in2="n" scale="{shift}" xChannelSelector="R" yChannelSelector="A"/>
</filter>''')

    def rippled(content):
        """Draw the same content once per depth band, each clipped to its band and rippled."""
        return [f'<g clip-path="url(#band{b})"><g filter="url(#ripple{b})">{content}</g></g>' for b in range(len(bands))]

    # Mirrored ranges: clearly darker than the real ones and pulled toward the water color,
    # the way water absorbs part of what it reflects
    # (flip inside the filtered group, so the clip and filter stay in screen space)
    # out = (0.75 * c + 0.25 * water) * (1 - d) + crust * d, applied to the full detailed ranges
    d = REFLECT_DARKEN
    k = 0.75 * (1 - d)
    wc = [int(water_top[n:n + 2], 16) / 255 for n in (1, 3, 5)]
    cc = [int(CRUST[n:n + 2], 16) / 255 for n in (1, 3, 5)]
    off = [0.25 * (1 - d) * w + d * c for w, c in zip(wc, cc)]
    parts.append(f'''<filter id="reflect" filterUnits="userSpaceOnUse" x="0" y="0" width="{W}" height="{H}" color-interpolation-filters="sRGB">
  <feColorMatrix values="{k:.4f} 0 0 0 {off[0]:.4f}  0 {k:.4f} 0 0 {off[1]:.4f}  0 0 {k:.4f} 0 {off[2]:.4f}  0 0 0 1 0"/>
</filter>''')
    mirror = (f'<g filter="url(#reflect)"><g transform="translate(0,{2 * horizon:.0f}) scale(1,-1)">'
              + shapes + "</g></g>")
    parts += rippled(mirror)

    # Wave lines catching a little sky light, spaced like the ripple bands (tight near the shore)
    wave = mix(water_top, LAVENDER, 0.18)
    for _ in range(160):
        f = rng.random() ** 1.7
        y = horizon + 4 + depth * f
        w = rng.uniform(150, 700) * (0.4 + 1.6 * f)
        x = rng.uniform(-300, W)
        th = 1.2 + 3.5 * f
        o = rng.uniform(0.25, 0.6) * (1 - 0.5 * f)
        parts.append(f'<rect x="{x:.0f}" y="{y:.0f}" width="{w:.0f}" height="{th:.1f}" rx="{th / 2:.1f}" fill="{wave}" opacity="{o:.2f}"/>')

    # Reflection fades into deep water toward the bottom, faster than before
    parts.append(f'''<linearGradient id="deep" x1="0" y1="{horizon:.0f}" x2="0" y2="{H}" gradientUnits="userSpaceOnUse">
  <stop offset="0"    stop-color="{CRUST}" stop-opacity="0"/>
  <stop offset="0.15" stop-color="{CRUST}" stop-opacity="0.12"/>
  <stop offset="0.5"  stop-color="{CRUST}" stop-opacity="0.6"/>
  <stop offset="1"    stop-color="{CRUST}" stop-opacity="0.88"/>
</linearGradient>''')
    parts.append(f'<rect x="0" y="{horizon:.0f}" width="{W}" height="{depth:.0f}" fill="url(#deep)"/>')

    # Moonlight on the water: a soft column of light plus scattered glints, rippled like the reflection
    col_h = depth * 0.95
    glints = [f'<ellipse cx="{MOON_X:.0f}" cy="{horizon:.0f}" rx="{MOON_R * 5:.0f}" ry="{col_h:.0f}" fill="url(#moonpath)"/>']
    for _ in range(140):
        f = rng.random() ** 1.3                    # 0 at the shore, 1 near the viewer
        y = horizon + 8 + (depth - 40) * f
        spread = 12 + 150 * f
        x = MOON_X + rng.gauss(0, spread * 0.45)
        w = rng.uniform(0.3, 1.0) * (16 + 150 * f)
        fade = math.exp(-((x - MOON_X) / spread) ** 2)   # dimmer toward the edges of the path
        o = (0.55 - 0.40 * f) * fade * rng.uniform(0.35, 1.0)
        th = 1.5 + 4 * f
        glints.append(f'<rect x="{x - w / 2:.0f}" y="{y:.0f}" width="{w:.0f}" height="{th:.1f}" rx="{th / 2:.1f}" fill="{ROSEWATER}" opacity="{o:.2f}"/>')
    parts += rippled('<g filter="url(#soft)">' + "".join(glints) + "</g>")

    # Soft shoreline: barely-there light where water meets the far shore
    parts.append(f'<rect x="0" y="{horizon - 1:.0f}" width="{W}" height="3" fill="{LAVENDER}" opacity="0.04" filter="url(#soft)"/>')
    return parts


def scene_forest(rng):
    haze = HORIZON_SKY
    parts = sky_and_moon(rng, H * 0.72)
    layers, _, _ = range_layers(rng, [
        (H * 0.66, 500, 0.42, RANGE[0]),
        (H * 0.74, 400, 0.48, RANGE[1]),
        (H * 0.82, 300, 0.50, RANGE[2]),
    ], H)
    parts += layers

    # Low mist over the valley floor
    parts.append(f'''<linearGradient id="mist" x1="0" y1="{H * 0.70:.0f}" x2="0" y2="{H * 0.90:.0f}" gradientUnits="userSpaceOnUse">
  <stop offset="0"   stop-color="{haze}" stop-opacity="0"/>
  <stop offset="0.6" stop-color="{haze}" stop-opacity="0.18"/>
  <stop offset="1"   stop-color="{haze}" stop-opacity="0"/>
</linearGradient>''')
    parts.append(f'<rect x="0" y="{H * 0.70:.0f}" width="{W}" height="{H * 0.20:.0f}" fill="url(#mist)"/>')

    # Two treelines on rolling ground: a hazier far one and a near silhouette
    for depth, (base, hill, hmin, hmax, gap, color) in enumerate([
        (H * 0.90, 70, 70, 170, (20, 45), RANGE[3]),
        (H * 1.00, 110, 140, 330, (35, 80), RANGE[4]),
    ]):
        ground = mountain_ridge(rng, base, hill, 0.35, peaks=2)
        trees = []
        x = -30
        while x < W + 30:
            gy = ridge_at(ground, x)
            # Thin the trees near the moon's reflection line so the sky stays open there
            h = rng.uniform(hmin, hmax)
            trees.append(pine(x, gy + 6, h, rng))
            x += rng.uniform(*gap) * (2.5 if rng.random() < 0.06 else 1)
        parts.append(f'<path d="{closed(ground, H)}" fill="{color}"/>')
        parts.append(f'<path d="{" ".join(trees)}" fill="{color}"/>')
    return parts


SCENES = {"mountains": scene_mountains, "lake": scene_lake, "forest": scene_forest}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("scene", nargs="?", default=SCENE, choices=SCENES)
    ap.add_argument("-o", "--out", type=Path, default=Path(__file__).with_name("wallpaper.svg"))
    args = ap.parse_args()

    rng = random.Random(SEED)
    parts = SCENES[args.scene](rng)
    parts.append(f'<rect width="{W}" height="{H}" filter="url(#grain)"/>')
    parts.append("</svg>")
    args.out.write_text("\n".join(parts))
    print(args.out)


if __name__ == "__main__":
    main()
