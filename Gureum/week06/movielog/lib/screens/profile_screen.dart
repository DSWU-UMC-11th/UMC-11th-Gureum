import 'package:flutter/material.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ProfileHeader(),
              SizedBox(height: 28),
              ProfileStats(),
              SizedBox(height: 30),
              FavoriteGenres(),
            ],
          ),
        ),
      ),
    );
  }
}
