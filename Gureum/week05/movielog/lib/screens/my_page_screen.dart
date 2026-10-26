import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('마이페이지')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(
          radius: 52,
          backgroundImage: AssetImage(
            'assets/images/profile/profile_movielog.jpg',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '구름',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        const Text('영화의 순간을 기록하는 무비러버', textAlign: TextAlign.center),
        const SizedBox(height: 28),
        const Row(
          children: [
            Expanded(
              child: _Stat(label: '본 영화', value: '342'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _Stat(label: '평균 평점', value: '4.2'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _Stat(label: '즐겨찾기', value: '58'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.history),
                title: Text('나의 영화 기록'),
                trailing: Icon(Icons.chevron_right),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('설정'),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label),
        ],
      ),
    ),
  );
}
