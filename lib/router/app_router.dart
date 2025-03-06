import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/profile_page.dart';
import 'package:travellista/profile_page_body.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/video_player_widget.dart';
import 'package:travellista/nav_bar.dart';
import 'package:travellista/map_view_page.dart';
import 'package:travellista/location_picker_screen.dart';
import 'package:travellista/entry_detail_page.dart';
import 'package:travellista/entry_card.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:travellista/entry_search.dart';



final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Route strings
const String homeRoute = '/';
const String detailRoute = '/entry/:entryId';


final GoRouter appRouter = GoRouter(
  initialLocation: homeRoute,
  routes: [
    GoRoute(
      path: homeRoute,
      builder: (context, state) => const HomeScreenPage(),
    ),

  ],
);
