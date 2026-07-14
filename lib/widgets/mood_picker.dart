import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood.dart';

/// Compact horizontal scrolling chip row — used on narrow/mobile layouts
/// where a tall vertical list doesn't fit alongside the orb.
class MoodChipsRow extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const MoodChipsRow({super.key, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: kMoods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final mood = kMoods[i];
          final active = i == selectedIndex;
          final dotColor = HSLColor.fromAHSL(1.0, mood.hue, mood.saturation / 100, 0.52).toColor();

          return Material(
            color: active ? Colors.white.withOpacity(0.14) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => onSelect(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mood.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: active ? Colors.white : Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Full vertical list — used in the wide/desktop sidebar.
class MoodPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const MoodPicker({super.key, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(kMoods.length, (i) {
        final mood = kMoods[i];
        final active = i == selectedIndex;
        final dotColor = HSLColor.fromAHSL(1.0, mood.hue, mood.saturation / 100, 0.52).toColor();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Material(
            color: active ? Colors.white.withOpacity(0.07) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelect(i),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.only(
                  left: active ? 16 : 10,
                  right: 10,
                  top: 14,
                  bottom: 14,
                ),
                child: Row(
                  children: [
                    Text(
                      '0${i + 1}',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        color: const Color(0xFF9C9A95).withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      mood.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: active ? const Color(0xFFEEECE6) : const Color(0xFF9C9A95),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}