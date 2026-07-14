import 'package:flutter/material.dart';

/// A single mood identity: a base hue + saturation + how its particles move.
class Mood {
  final String key;
  final String name;
  final double hue; // 0-360
  final double saturation; // 0-100
  final MoodMotion motion;
  final String description;

  const Mood({
    required this.key,
    required this.name,
    required this.hue,
    required this.saturation,
    required this.motion,
    required this.description,
  });
}

enum MoodMotion { slow, drift, fast }

const List<Mood> kMoods = [
  Mood(
    key: 'hearth',
    name: 'Hearth',
    hue: 18,
    saturation: 78,
    motion: MoodMotion.slow,
    description: 'Ember and clay, banked low.',
  ),
  Mood(
    key: 'tide',
    name: 'Tide',
    hue: 196,
    saturation: 62,
    motion: MoodMotion.drift,
    description: 'Deep teal pulled by a slow current.',
  ),
  Mood(
    key: 'bloom',
    name: 'Bloom',
    hue: 322,
    saturation: 58,
    motion: MoodMotion.drift,
    description: 'Peony pink easing into violet.',
  ),
  Mood(
    key: 'moss',
    name: 'Moss',
    hue: 96,
    saturation: 40,
    motion: MoodMotion.slow,
    description: 'Olive and lichen, quiet green.',
  ),
  Mood(
    key: 'static',
    name: 'Static',
    hue: 268,
    saturation: 85,
    motion: MoodMotion.fast,
    description: 'Electric violet, live current.',
  ),
  Mood(
    key: 'ash',
    name: 'Ash',
    hue: 222,
    saturation: 18,
    motion: MoodMotion.slow,
    description: 'Graphite blue, almost no color at all.',
  ),
];

const List<String> kPaletteRoles = ['deep', 'base', 'core', 'glow', 'mist'];

// Lightness ramp + hue/sat drift per swatch: deep -> base -> core -> glow -> mist
const List<double> _lightness = [14, 28, 46, 66, 86];
const List<double> _hueDrift = [-6, -2, 0, 4, 10];
const List<double> _satDrift = [4, 0, 2, -8, -22];

double _clamp(double v, double a, double b) => v < a ? a : (v > b ? b : v);

/// Builds a 5-tone HSL palette for a mood, with optional hue jitter for variation.
List<HSLColor> buildPalette(Mood mood, {double jitter = 0}) {
  final h = mood.hue + jitter;
  return List.generate(5, (i) {
    final hue = (h + _hueDrift[i]) % 360;
    final sat = _clamp(mood.saturation + _satDrift[i], 8, 96) / 100.0;
    final light = _lightness[i] / 100.0;
    return HSLColor.fromAHSL(1.0, hue < 0 ? hue + 360 : hue, sat, light);
  });
}

/// Formats a Color as an uppercase hex string, e.g. #FF6A3D
String colorToHex(Color c) {
  return '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
}

/// Shortest-path hue lerp (so 350 -> 10 goes through 360/0, not backwards through 180).
double lerpHue(double a, double b, double t) {
  final d = ((b - a + 540) % 360) - 180;
  var result = (a + d * t) % 360;
  if (result < 0) result += 360;
  return result;
}

HSLColor lerpHsl(HSLColor a, HSLColor b, double t) {
  return HSLColor.fromAHSL(
    1.0,
    lerpHue(a.hue, b.hue, t),
    a.saturation + (b.saturation - a.saturation) * t,
    a.lightness + (b.lightness - a.lightness) * t,
  );
}