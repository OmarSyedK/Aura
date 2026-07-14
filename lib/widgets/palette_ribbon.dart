import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood.dart';

class PaletteRibbon extends StatefulWidget {
  final List<HSLColor> palette;

  const PaletteRibbon({super.key, required this.palette});

  @override
  State<PaletteRibbon> createState() => _PaletteRibbonState();
}

class _PaletteRibbonState extends State<PaletteRibbon> {
  int? _hoveredIndex;

  void _copy(BuildContext context, String hex) {
    Clipboard.setData(ClipboardData(text: hex));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFEEECE6),
        duration: const Duration(milliseconds: 1200),
        margin: const EdgeInsets.only(bottom: 118, left: 120, right: 120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        content: Text(
          'Copied $hex',
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexMono(color: const Color(0xFF0B0B10), fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B10).withOpacity(0.35),
            border: const Border(
              top: BorderSide(color: Colors.white12, width: 1),
            ),
          ),
          child: Row(
            children: List.generate(widget.palette.length, (i) {
              final c = widget.palette[i];
              final color = c.toColor();
              final hex = colorToHex(color);
              final hovered = _hoveredIndex == i;
              // adaptive text color for contrast against light "mist" swatches
              final textColor = c.lightness > 0.62 ? Colors.black87 : Colors.white;

              return Expanded(
                flex: hovered ? 135 : 100,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = i),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _copy(context, hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      height: 96,
                      color: color,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kPaletteRoles[i].toUpperCase(),
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 9.5,
                              letterSpacing: 1.4,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hex,
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}