import 'package:flutter/material.dart';

class AdaptiveSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? description;
  final List<Widget> children;

  const AdaptiveSection({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            if (description != null) ...[
              Text(description!),
              const SizedBox(height: 16),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}