from skyfield.api import load
import json

# Gravitational constant in km^3/kg/s^2
G = 6.67430e-20

# Load ephemeris DE440
ephemeris = load('de440.bsp')

# Barycenters only
barycenters = {
    'mercury_barycenter': ephemeris['MERCURY BARYCENTER'],
    'venus_barycenter': ephemeris['VENUS BARYCENTER'],
    'earth_barycenter': ephemeris['EARTH BARYCENTER'],
    'mars_barycenter': ephemeris['MARS BARYCENTER'],
    'jupiter_barycenter': ephemeris['JUPITER BARYCENTER'],
    'saturn_barycenter': ephemeris['SATURN BARYCENTER'],
    'uranus_barycenter': ephemeris['URANUS BARYCENTER'],
    'neptune_barycenter': ephemeris['NEPTUNE BARYCENTER'],
    'pluto_barycenter': ephemeris['PLUTO BARYCENTER'],
}

masses_kg = {
    'mercury_barycenter': 3.3011e23,
    'venus_barycenter': 4.8675e24,
    'earth_barycenter': 5.9724e24,
    'mars_barycenter': 6.4171e23,
    'jupiter_barycenter': 1.8982e27,
    'saturn_barycenter': 5.6834e26,
    'uranus_barycenter': 8.6810e25,
    'neptune_barycenter': 1.02413e26,
    'pluto_barycenter': 1.303e22,
    'sun': 1.9885e30
}


ts = load.timescale()
t = ts.now()

# Get sun position at time t relative to SSB
sun = ephemeris['SUN']
sun_pos = sun.at(t).position.km

data = {}

for name, body in barycenters.items():
    # Position relative to SSB
    body_pos = body.at(t).position.km
    
    # Position relative to Sun
    relative_pos = body_pos - sun_pos
    
    x2d, y2d = relative_pos[0], relative_pos[1]

    mass = None
    try:
        gm = body.gm
        mass = gm / G
    except AttributeError:
        mass = masses_kg[name]
    except Exception as e:
        print(e)

    data[name.split('_')[0]] = {
        'position_3d_km': relative_pos.tolist(),
        'position_2d_km': [x2d, y2d],
        'mass_kg': mass
    }

with open('../space-race/Metadata/2d_coords_relative_to_sun.json', 'w') as f:
    json.dump(data, f, indent=2)