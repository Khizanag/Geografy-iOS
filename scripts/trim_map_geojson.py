#!/usr/bin/env python3
"""Trim the world map GeoJSON to what the app reads, without changing any border it draws.

The source is Natural Earth's 10m admin-0 countries (the full file is in git at 46a61934).
The app reads a few properties and only each polygon's outer ring, so this keeps:
- the properties GeoJSONParser looks up (names, continent, ISO codes);
- each polygon's outer ring, dropping holes, which the parser never drew;
- coordinates rounded to 5 decimals (about 1 m), far below what the map can show at full zoom.

Usage: python3 scripts/trim_map_geojson.py Geografy/Resource/countries.geojson
The file is rewritten in place. Running it again on its own output changes nothing.
"""

import json
import sys

KEPT_PROPERTIES = ("NAME", "ADMIN", "CONTINENT", "ISO_A2_EH", "ISO_A2", "ISO_A3", "ADM0_A3")
DECIMALS = 5


def trim_ring(ring):
    trimmed = []
    for longitude, latitude, *_ in ring:
        point = [round(longitude, DECIMALS), round(latitude, DECIMALS)]
        if not trimmed or trimmed[-1] != point:
            trimmed.append(point)
    return trimmed


def trim_geometry(geometry):
    if geometry["type"] == "Polygon":
        return {"type": "Polygon", "coordinates": [trim_ring(geometry["coordinates"][0])]}
    polygons = [[trim_ring(polygon[0])] for polygon in geometry["coordinates"]]
    return {"type": "MultiPolygon", "coordinates": polygons}


def trim_feature(feature):
    properties = {key: feature["properties"][key] for key in KEPT_PROPERTIES if key in feature["properties"]}
    return {"type": "Feature", "properties": properties, "geometry": trim_geometry(feature["geometry"])}


def main(path):
    with open(path, encoding="utf-8") as source:
        collection = json.load(source)
    trimmed = {"type": "FeatureCollection", "features": [trim_feature(f) for f in collection["features"]]}
    with open(path, "w", encoding="utf-8") as output:
        json.dump(trimmed, output, ensure_ascii=False, separators=(",", ":"))


if __name__ == "__main__":
    main(sys.argv[1])
