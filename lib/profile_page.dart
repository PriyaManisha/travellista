import 'package:flutter/material.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/profile_page_body.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedScaffold(
      title: 'Profile',
      selectedIndex: 3,
      body: ProfilePageBody(),
    );
  }
}