import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/services/network_service.dart';

class PopularCard extends StatelessWidget {
  const PopularCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.author,
    required this.description,
    required this.courseId,
  });

  final String imageUrl;
  final String title;
  final double rating;
  final String author;
  final String description;
  final int courseId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/course_details',
          arguments: {
            'imageURL': imageUrl,
            'title': title,
            'instructor': author,
            'description': description,
            'courseId': courseId,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NetworkOrPlaceholderImage(
              imageUrl: imageUrl,
              height: 100,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultText(
                    context: context,
                    text: title,
                    size: 16,
                    color: Colors.white,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    context: context,
                    text: author,
                    size: 14,
                    bold: false,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: "⭐ $rating",
                    size: 14,
                    bold: false,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _NetworkOrPlaceholderImage extends StatelessWidget {
  const _NetworkOrPlaceholderImage({
    required this.imageUrl,
    required this.height,
    required this.width,
    this.borderRadius,
  });

  final String imageUrl;
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final online = NetworkService.isConnected;

    Widget placeholder() {
      return Container(
        height: height,
        width: width,
        color: Colors.white10,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white54,
          ),
        ),
      );
    }

    if (!online) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: placeholder(),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Colors.white10,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
