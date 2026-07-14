import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood.dart';
import '../widgets/aura_orb.dart';
import '../widgets/mood_picker.dart';
import '../widgets/palette_ribbon.dart';

class AuraScreen extends StatefulWidget {
  const AuraScreen({super.key});

  @override
  State<AuraScreen> createState() => _AuraScreenState();
}

class _AuraScreenState extends State<AuraScreen> {
  int _selectedIndex = 0;
  double _jitter = 0;

  Mood get _mood => kMoods[_selectedIndex];
  List<HSLColor> get _palette => buildPalette(_mood, jitter: _jitter);

  void _selectMood(int i) {
    setState(() {
      _selectedIndex = i;
      _jitter = 0;
    });
  }

  void _shuffle() {
    final rnd = Random();
    setState(() {
      _jitter = (rnd.nextDouble() - 0.5) * 40;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 760;

    final sidebar = _Sidebar(
      selectedIndex: _selectedIndex,
      onSelect: _selectMood,
      onShuffle: _shuffle,
      moodName: _mood.name,
    );

    final stage = _Stage(
      mood: _mood,
      jitter: _jitter,
      palette: _palette,
      index: _selectedIndex,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10),
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  SizedBox(width: 340, child: sidebar),
                  const VerticalDivider(width: 1, color: Colors.white12),
                  Expanded(child: stage),
                ],
              )
            : _MobileLayout(
                mood: _mood,
                jitter: _jitter,
                palette: _palette,
                selectedIndex: _selectedIndex,
                onSelect: _selectMood,
                onShuffle: _shuffle,
              ),
      ),
    );
  }
}

/// Dedicated mobile layout: orb full-bleed behind everything, a compact
/// header on top, horizontal mood chips instead of a tall list, and the
/// palette ribbon pinned to the bottom.
class _MobileLayout extends StatelessWidget {
  final Mood mood;
  final double jitter;
  final List<HSLColor> palette;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onShuffle;

  const _MobileLayout({
    required this.mood,
    required this.jitter,
    required this.palette,
    required this.selectedIndex,
    required this.onSelect,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AuraOrb(mood: mood, jitter: jitter),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'CHOOSE YOUR AURA · 0${selectedIndex + 1}/0${kMoods.length}',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 10.5,
                          letterSpacing: 1.6,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onShuffle,
                      icon: const Icon(Icons.shuffle, size: 18),
                      color: Colors.white.withOpacity(0.75),
                      tooltip: 'Shuffle this aura',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mood.name,
                  style: GoogleFonts.fraunces(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: const [Shadow(blurRadius: 20, color: Colors.black45)],
                  ),
                ),
                const SizedBox(height: 14),
                MoodChipsRow(selectedIndex: selectedIndex, onSelect: onSelect),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PaletteRibbon(palette: palette),
        ),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onShuffle;
  final String moodName;

  const _Sidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.onShuffle,
    required this.moodName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF131319), Color(0xFF0B0B10)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'CHOOSE YOUR AURA',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              letterSpacing: 2.2,
              color: const Color(0xFF9C9A95),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Aura',
            style: GoogleFonts.fraunces(
              fontSize: 44,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEEECE6),
              height: 1.0,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Pick a mood. Watch its palette breathe into being — five tones, tuned and ready to use.',
            style: GoogleFonts.fraunces(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF9C9A95),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: MoodPicker(selectedIndex: selectedIndex, onSelect: onSelect),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onShuffle,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9C9A95),
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              '⟳  SHUFFLE THIS AURA',
              style: GoogleFonts.ibmPlexMono(fontSize: 12, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'tap any swatch below to copy its hex',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10.5,
              color: const Color(0xFF9C9A95).withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  final Mood mood;
  final double jitter;
  final List<HSLColor> palette;
  final int index;

  const _Stage({
    required this.mood,
    required this.jitter,
    required this.palette,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AuraOrb(mood: mood, jitter: jitter),
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                '0${index + 1} / 0${kMoods.length}',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  letterSpacing: 2.4,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mood.name,
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: const [Shadow(blurRadius: 20, color: Colors.black45)],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PaletteRibbon(palette: palette),
        ),
      ],
    );
  }
}