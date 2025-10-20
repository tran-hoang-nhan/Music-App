import 'package:flutter/material.dart';

class LibraryTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const LibraryTabs({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorColor: const Color(0xFFE53E3E),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: const Color(0xFFE53E3E),
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(text: 'Playlist'),
        Tab(text: 'Yêu thích'),
        Tab(text: 'Gần đây'),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}

