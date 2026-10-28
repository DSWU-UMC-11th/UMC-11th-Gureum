import 'package:flutter/material.dart';

import 'stat_item.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  static const stats = [
    (label: '본 영화', value: '342'),
    (label: '평점', value: '4.2'),
    (label: '즐겨찾기', value: '58'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StatItem(label: stat.label, value: stat.value),
              ),
            ),
          )
          .toList(),
    );
  }
}
