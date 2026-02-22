import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/colors.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeImage;
  final String afterImage;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImage,
    required this.afterImage,
  });

  @override
  State<BeforeAfterSlider> createState() =>
      _BeforeAfterSliderState();
}

class _BeforeAfterSliderState
    extends State<BeforeAfterSlider> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _sliderValue +=
                    details.delta.dx / width;
                _sliderValue =
                    _sliderValue.clamp(0.0, 1.0);
              });
            },
            child: SizedBox(
              height: 400,
              child: Stack(
                children: [
                  // After image (full)
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: widget.afterImage,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Before image (clipped)
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _SliderClipper(
                        _sliderValue,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.beforeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Divider line
                  Positioned(
                    left: width * _sliderValue - 1.5,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      color: Colors.white,
                    ),
                  ),

                  // Handle
                  Positioned(
                    left: width * _sliderValue - 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.compare_arrows_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  // Labels
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildLabel('Before'),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildLabel('After ✨'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double value;
  _SliderClipper(this.value);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      0,
      size.width * value,
      size.height,
    );
  }

  @override
  bool shouldReclip(_SliderClipper old) =>
      old.value != value;
}
