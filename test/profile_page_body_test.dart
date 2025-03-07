import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/models/profile.dart';
import 'package:travellista/profile_page_body.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/util/theme_manager.dart';
import 'fakes/fake_routers.dart';

import 'profile_page_body_test.mocks.dart';

@GenerateMocks([ProfileProvider, StorageService, ImagePicker])

void main() {
  group('ProfilePageBody Widget Tests', () {
    late MockProfileProvider mockProfileProvider;
    late MockStorageService mockStorageService;

    Widget createWidgetUnderTest() {
      // 1. Create MultiProvider
      final profileWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>.value(value: mockProfileProvider),
          Provider<StorageService>.value(value: mockStorageService),
        ],
        child: Scaffold(
          body: ProfilePageBody(storageOverride: mockStorageService),
        ),
      );

      // 2. Build fake router
      final router = fakeProfileRouter(profileWidget);

      // 3. Return MaterialApp.router
      return MaterialApp.router(
        routerConfig: router,
      );
    }

    setUp(() {
      mockProfileProvider = MockProfileProvider();
      mockStorageService = MockStorageService();
      ThemeManager.themeNotifier.value = ThemeMode.light;
    });

    testWidgets('Shows spinner if profile is loading and no profile yet',
            (tester) async {
          // setup / given / arrange : mock provider
          when(mockProfileProvider.isLoading).thenReturn(true);
          when(mockProfileProvider.profile).thenReturn(null);

          // ACT : put the widget on virtual screen
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pump();

          // ASSERT : should see spinner without the default text
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('No profile found'), findsNothing);
        });

    testWidgets('Shows "No profile found" text if profileProvider is not loading but profile is null',
            (tester) async {
          // setup / given / arrange : mock provider
          when(mockProfileProvider.isLoading).thenReturn(false);
          when(mockProfileProvider.profile).thenReturn(null);

          // ACT : put the widget on virtual screen
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pump();

          // ASSERT : should see fallback text
          expect(find.text('No profile found'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
        });

    testWidgets('Displays profile data in read-only mode by default', (tester) async {
      // setup / given / arrange : mock profile, provider
      final demoProfile = Profile(
        userID: 'demoUser',
        firstName: 'John',
        lastName: 'Doe',
        displayName: 'johnd',
        email: 'john@example.com',
        photoUrl: '',
      );
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(demoProfile);

      // ACT : put the widget on virtual screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ASSERT : Should see display rows with labels
      expect(find.text('First Name: '), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Last Name: '), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
      expect(find.text('Display Name: '), findsOneWidget);
      expect(find.text('johnd'), findsOneWidget);
      expect(find.text('Email: '), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);

      // Edit button is visible, save/cancel are not
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('Tapping "Edit Profile" switches to editing mode', (tester) async {
      // setup / given / arrange : mock profile, provider
      final demoProfile = Profile(
        userID: 'demoUser',
        firstName: 'John',
        lastName: 'Doe',
        displayName: 'johnd',
        email: 'john@example.com',
      );
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(demoProfile);

      // ACT : put the widget on virtual screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ACT : Tap "Edit Profile"
      await tester.tap(find.text('Edit Profile'));
      await tester.pump();

      // ASSERT : We should see text fields for editing
      expect(find.widgetWithText(TextFormField, 'John'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Doe'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'johnd'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'john@example.com'), findsOneWidget);

      // ASSERT : Save & Cancel buttons should appear
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      // ASSERT : Edit Profile button should be gone
      expect(find.text('Edit Profile'), findsNothing);
    });

    testWidgets('Tapping "Save" shows confirmation dialog, then saves on confirm', (tester) async {
      // setup / given / arrange : mock profile, provider
      final demoProfile = Profile(
        userID: 'demoUser',
        firstName: 'John',
        lastName: 'Doe',
        displayName: 'johnd',
        email: 'john@example.com',
      );
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(demoProfile);

      // ACT : put the widget on virtual screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ACT : Enter edit mode
      await tester.tap(find.text('Edit Profile'));
      await tester.pump();

      // ACT : Tap Save
      await tester.tap(find.text('Save'));
      await tester.pump();

      // ASSERT: confirmation dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Are you sure you want to update your profile?'), findsOneWidget);

      // ACT : Confirm profile edit and tap "Yes"
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // VERIFY : provider.saveProfile(...) should be called once
      verify(mockProfileProvider.saveProfile(any)).called(1);

      // ASSERT : expect to see a "Profile updated successfully" SnackBar
      expect(find.text('Profile updated successfully'), findsOneWidget);
    });

    testWidgets('Tapping "Save" -> Cancel in dialog does not save', (tester) async {
      // setup / given / arrange : mock profile, provider
      final demoProfile = Profile(
        userID: 'demoUser',
        firstName: 'John',
        lastName: 'Doe',
        displayName: 'johnd',
        email: 'john@example.com',
      );
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(demoProfile);

      // ACT : put the widget on virtual screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ACT : Enter edit mode
      await tester.tap(find.text('Edit Profile'));
      await tester.pump();

      // ACT : Tap save button
      await tester.tap(find.text('Save'));
      await tester.pump();

      // ASSERT: confirmation dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);

      // ACT : Tap "Cancel"
      await tester.tap(find.byKey(const Key('dialogCancelButton')), warnIfMissed: false);
      await tester.pump();

      // VERIFY : Confirm no call to saveProfile was made
      verifyNever(mockProfileProvider.saveProfile(any));
      // ASSERT : No "Profile updated successfully" message
      expect(find.text('Profile updated successfully'), findsNothing);
    });

    testWidgets('Dark mode switch toggles ThemeMode', (tester) async {
      // setup / given / arrange : mock profile, provider
      final demoProfile = Profile(
        userID: 'demoUser',
        displayName: 'johnd',
        email: 'john@example.com',
      );
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(demoProfile);

      // ACT : put the widget on virtual screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ASSERT : Theme should initially be light
      expect(ThemeManager.themeNotifier.value, ThemeMode.light);

      // ACT : toggle theme button
      final switchFinder = find.byType(SwitchListTile);
      await tester.tap(switchFinder);
      await tester.pump();

      // ASSERT : theme should be changed to dark
      expect(ThemeManager.themeNotifier.value, ThemeMode.dark);

      // ACT : Tap again -> back to light
      await tester.tap(switchFinder);
      await tester.pump();

      // ASSERT : theme should be changed back to light
      expect(ThemeManager.themeNotifier.value, ThemeMode.light);
    });
  });
}
