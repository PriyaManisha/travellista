// Mocks generated by Mockito 5.4.5 from annotations
// in travellista/test/entry_creation_form_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:io' as _i9;
import 'dart:ui' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i10;
import 'package:travellista/models/journal_entry.dart' as _i3;
import 'package:travellista/models/profile.dart' as _i7;
import 'package:travellista/providers/journal_entry_provider.dart' as _i2;
import 'package:travellista/providers/profile_provider.dart' as _i6;
import 'package:travellista/util/storage_service.dart' as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [JournalEntryProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockJournalEntryProvider extends _i1.Mock
    implements _i2.JournalEntryProvider {
  MockJournalEntryProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  List<_i3.JournalEntry> get entries =>
      (super.noSuchMethod(
            Invocation.getter(#entries),
            returnValue: <_i3.JournalEntry>[],
          )
          as List<_i3.JournalEntry>);

  @override
  bool get isLoading =>
      (super.noSuchMethod(Invocation.getter(#isLoading), returnValue: false)
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i4.Future<void> fetchEntriesForUser(String? userID) =>
      (super.noSuchMethod(
            Invocation.method(#fetchEntriesForUser, [userID]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> addEntry(_i3.JournalEntry? entry) =>
      (super.noSuchMethod(
            Invocation.method(#addEntry, [entry]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> updateEntry(
    String? entryID,
    _i3.JournalEntry? updatedEntry,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateEntry, [entryID, updatedEntry]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> deleteEntry(String? entryID) =>
      (super.noSuchMethod(
            Invocation.method(#deleteEntry, [entryID]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void addListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [ProfileProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockProfileProvider extends _i1.Mock implements _i6.ProfileProvider {
  MockProfileProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isLoading =>
      (super.noSuchMethod(Invocation.getter(#isLoading), returnValue: false)
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i4.Future<void> fetchProfile(String? userID) =>
      (super.noSuchMethod(
            Invocation.method(#fetchProfile, [userID]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> saveProfile(_i7.Profile? profile) =>
      (super.noSuchMethod(
            Invocation.method(#saveProfile, [profile]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void addListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [StorageService].
///
/// See the documentation for Mockito's code generation for more information.
class MockStorageService extends _i1.Mock implements _i8.StorageService {
  MockStorageService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<String> uploadFile(_i9.File? file, String? path) =>
      (super.noSuchMethod(
            Invocation.method(#uploadFile, [file, path]),
            returnValue: _i4.Future<String>.value(
              _i10.dummyValue<String>(
                this,
                Invocation.method(#uploadFile, [file, path]),
              ),
            ),
          )
          as _i4.Future<String>);

  @override
  _i4.Future<void> deleteFileByUrl(String? url) =>
      (super.noSuchMethod(
            Invocation.method(#deleteFileByUrl, [url]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}
