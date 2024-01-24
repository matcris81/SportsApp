import 'package:flutter/material.dart';

class PlayerAvatars extends StatelessWidget {
  final List<String?> playerImageUrls;
  static const int maxAvatars = 5;
  static const String defaultImageUrl =
      'assets/default-avatar.png'; // Replace with a valid image path

  const PlayerAvatars({
    Key? key,
    required this.playerImageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int displayCount = playerImageUrls.length > maxAvatars
        ? maxAvatars
        : playerImageUrls.length;

    return Container(
      height: 40, // Fixed height
      width: displayCount * 20.0 + 20.0, // Adjusted width
      child: Stack(
        children: List.generate(
          displayCount,
          (index) {
            double offset = index * 20.0; // Adjust this value for overlap
            String imageUrl = playerImageUrls[index] ?? defaultImageUrl;
            return Positioned(
              left: offset,
              child: CircleAvatar(
                backgroundImage: AssetImage(
                    imageUrl), // Changed to AssetImage for local assets
                radius: 20.0,
              ),
            );
          },
        ),
      ),
    );
  }
}
