import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A robust image widget that automatically handles:
/// - Remote URLs (http / https) using [CachedNetworkImage]
/// - Local assets using [Image.asset]
/// - Graceful loading and error states with dark-theme styled fallbacks
class AppImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
  });

  bool get _isNetwork {
    final lower = imagePath.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath.trim();
    if (trimmed.isEmpty) {
      return _buildFallback(context);
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: trimmed,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildFallback(context),
      );
    }

    return Image.asset(
      trimmed,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildFallback(context),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF161B22),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF0DA0CE),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (errorWidget != null) return errorWidget!;
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF161B22),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF8B929A),
        size: 36,
      ),
    );
  }
}

