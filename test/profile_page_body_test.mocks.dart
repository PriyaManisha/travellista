// Mocks generated by Mockito 5.4.5 from annotations
// in travellista/test/profile_page_body_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:io' as _i8;
import 'dart:ui' as _i6;

import 'package:image_picker/image_picker.dart' as _i10;
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i9;
import 'package:travellista/models/profile.dart' as _i5;
import 'package:travellista/providers/profile_provider.dart' as _i3;
import 'package:travellista/util/storage_service.dart' as _i7;

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

class _FakeLostDataResponse_0 extends _i1.SmartFake
    implements _i2.LostDataResponse {
  _FakeLostDataResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [ProfileProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockProfileProvider extends _i1.Mock implements _i3.ProfileProvider {
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
  _i4.Future<void> saveProfile(_i5.Profile? profile) =>
      (super.noSuchMethod(
            Invocation.method(#saveProfile, [profile]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void addListener(_i6.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i6.VoidCallback? listener) => super.noSuchMethod(
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
class MockStorageService extends _i1.Mock implements _i7.StorageService {
  MockStorageService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<String> uploadFile(_i8.File? file, String? path) =>
      (super.noSuchMethod(
            Invocation.method(#uploadFile, [file, path]),
            returnValue: _i4.Future<String>.value(
              _i9.dummyValue<String>(
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

/// A class which mocks [ImagePicker].
///
/// See the documentation for Mockito's code generation for more information.
class MockImagePicker extends _i1.Mock implements _i10.ImagePicker {
  MockImagePicker() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.XFile?> pickImage({
    required _i2.ImageSource? source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    _i2.CameraDevice? preferredCameraDevice = _i2.CameraDevice.rear,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickImage, [], {
              #source: source,
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #preferredCameraDevice: preferredCameraDevice,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<_i2.XFile?>.value(),
          )
          as _i4.Future<_i2.XFile?>);

  @override
  _i4.Future<List<_i2.XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickMultiImage, [], {
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #limit: limit,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<List<_i2.XFile>>.value(<_i2.XFile>[]),
          )
          as _i4.Future<List<_i2.XFile>>);

  @override
  _i4.Future<_i2.XFile?> pickMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickMedia, [], {
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<_i2.XFile?>.value(),
          )
          as _i4.Future<_i2.XFile?>);

  @override
  _i4.Future<List<_i2.XFile>> pickMultipleMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickMultipleMedia, [], {
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #limit: limit,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<List<_i2.XFile>>.value(<_i2.XFile>[]),
          )
          as _i4.Future<List<_i2.XFile>>);

  @override
  _i4.Future<_i2.XFile?> pickVideo({
    required _i2.ImageSource? source,
    _i2.CameraDevice? preferredCameraDevice = _i2.CameraDevice.rear,
    Duration? maxDuration,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickVideo, [], {
              #source: source,
              #preferredCameraDevice: preferredCameraDevice,
              #maxDuration: maxDuration,
            }),
            returnValue: _i4.Future<_i2.XFile?>.value(),
          )
          as _i4.Future<_i2.XFile?>);

  @override
  _i4.Future<_i2.LostDataResponse> retrieveLostData() =>
      (super.noSuchMethod(
            Invocation.method(#retrieveLostData, []),
            returnValue: _i4.Future<_i2.LostDataResponse>.value(
              _FakeLostDataResponse_0(
                this,
                Invocation.method(#retrieveLostData, []),
              ),
            ),
          )
          as _i4.Future<_i2.LostDataResponse>);

  @override
  bool supportsImageSource(_i2.ImageSource? source) =>
      (super.noSuchMethod(
            Invocation.method(#supportsImageSource, [source]),
            returnValue: false,
          )
          as bool);
}
