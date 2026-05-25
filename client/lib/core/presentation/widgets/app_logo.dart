import 'package:flutter/material.dart';
import 'package:ink/core/presentation/app_assets.dart' as assets;
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';

enum LogoSize { small, large }

class AppLogo extends StatelessWidget {
  const AppLogo({
    required this.size,
    this.semanticLabel = 'App Logo',
    super.key,
  });

  final LogoSize size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final logoAsset = context.isLight
        ? assets.logoLightPath
        : assets.logoDarkPath;

    final (width, height) = switch (size) {
      LogoSize.small => (sizes.smallImageWidth, sizes.smallImageHeight),
      LogoSize.large => (sizes.largeImageWidth, sizes.largeImageHeight),
    };

    return Image.asset(
      logoAsset,
      semanticLabel: semanticLabel,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
