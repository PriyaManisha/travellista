import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/router/app_router.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/video_player_widget.dart';
import 'package:travellista/location_picker_screen.dart';
import 'package:travellista/util/chip_theme_util.dart';

class EntryCreationForm extends StatefulWidget {
  final JournalEntry? existingEntry;
  final StorageService? storageOverride;
  final ImagePicker? pickerOverride;

  const EntryCreationForm({
    super.key,
    this.existingEntry,
    this.storageOverride,
    this.pickerOverride,
  });

  @override
  _EntryCreationFormState createState() => _EntryCreationFormState();
}

class _EntryCreationFormState extends State<EntryCreationForm> {
  final _formKey = GlobalKey<FormState>();
  late final StorageService _storageService;
  late final ImagePicker _picker;

  // Location
  String? _pickedAddress = "Seattle, Washington, United States";
  String? _pickedLocale = "Seattle";
  String? _pickedRegion = "Washington";
  String? _pickedCountry = "United States";
  LatLng _pickedLocation = const LatLng(47.60621, -122.33207);

  // Basic text
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Tags
  final TextEditingController _tagController = TextEditingController();
  List<String> _tags = [];

  // Date
  DateTime _selectedDate = DateTime.now();
  String? _monthName;

  // Images
  List<File> _imageFiles = [];
  List<String> _oldImageURLs = [];
  final List<String> _removedOldImageURLs = [];

  // Videos
  List<String> _oldVideoURLs = [];
  List<String> _oldVideoThumbURLs = [];
  final List<String> _removedOldVideoURLs = [];
  List<File> _newVideoFiles = [];
  List<Uint8List?> _newVideoThumbBytes = [];

  // State
  bool _isSaving = false;
  bool get _isEditMode => widget.existingEntry != null;
  bool get _isFormValid =>
      _titleController.text.trim().isNotEmpty;

  Future<Uint8List?> _generateThumbnail(File videoFile) async {
    return await VideoThumbnail.thumbnailData(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 75,
    );
  }

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageOverride ?? StorageService();
    _picker = widget.pickerOverride ?? ImagePicker();
    _titleController.addListener(() => setState(() {}));

    if (_isEditMode) {
      final existing = widget.existingEntry!;
      // Load existing fields
      _titleController.text = existing.title ?? '';
      _descriptionController.text = existing.description ?? '';
      if (existing.timestamp != null) _selectedDate = existing.timestamp!;
      if (existing.latitude != null && existing.longitude != null) {
        _pickedLocation = LatLng(existing.latitude!, existing.longitude!);
      }
      _monthName = existing.monthName;
      _pickedAddress = existing.address;
      _pickedLocale = existing.localeName;
      _pickedRegion = existing.regionName;
      _pickedCountry = existing.countryName;
      _tags = existing.tags ?? [];
      _tagController.text = _tags.join(', ');

      // Existing images
      if (existing.imageURLs != null) {
        _oldImageURLs = List.from(existing.imageURLs!);
      }
      // Existing videos
      if (existing.videoURLs != null) {
        _oldVideoURLs = List.from(existing.videoURLs!);
      }
      // Existing video thumbs
      if (existing.videoThumbnailURLs != null) {
        _oldVideoThumbURLs = List.from(existing.videoThumbnailURLs!);
      }
    } else {
      _monthName = DateFormat('MMMM').format(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final userID = profileProvider.profile?.userID ?? 'demoUser';

    return Stack(
      children: [
        SharedScaffold(
          title: _isEditMode ? 'Edit Entry' : 'Create New Entry',
          selectedIndex: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.photo),
              tooltip: 'Add Image',
              onPressed: _pickImage,
            ),
            IconButton(
              icon: const Icon(Icons.videocam),
              tooltip: 'Add Video',
              onPressed: _pickVideo,
            ),
          ],
          floatingActionButton: _buildSaveFAB(userID),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const Divider(),
                    _buildLocationPicker(),
                    const Divider(),
                    _buildTagField(),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    _buildVideoSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isSaving)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  // ---------------------------
  // Floating Action Button
  // ---------------------------
  Widget _buildSaveFAB(String userID) {
    return FloatingActionButton(
      onPressed: _isFormValid ? () => _saveEntry(userID) : null,
      backgroundColor: _isFormValid ? const Color(0xFF7E57C2) : Colors.grey,
      child: Icon(_isEditMode ? Icons.check : Icons.save),
    );
  }

  // ---------------
  // Field Builders
  // ---------------
  Widget _buildTitleField() {
    final theme = Theme.of(context).textTheme;
    return TextFormField(
      controller: _titleController,
      style: theme.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Title',
        labelStyle: theme.labelLarge,
        hintText: 'Enter your title here',
        hintStyle: theme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
        ),
      ),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Please enter a title'
          : null,
    );
  }
  Widget _buildDescriptionField() {
    final theme = Theme.of(context).textTheme;
    return TextFormField(
      controller: _descriptionController,
      style: theme.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: theme.labelLarge,
        hintText: 'What happened today?',
        hintStyle: theme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
        ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildDatePicker() {
    final theme = Theme.of(context).textTheme;
    final dateStr = DateFormat('MM/dd/yyyy').format(_selectedDate);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Date: $dateStr',
        style: theme.bodyLarge,
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: _pickDate,
    );
  }

  Widget _buildLocationPicker() {
    final theme = Theme.of(context).textTheme;
    final hasAddress = _pickedAddress != null && _pickedAddress!.isNotEmpty;
    final displayedLocation = hasAddress
        ? 'Location: $_pickedAddress'
        : 'Location: ${_pickedLocation.latitude}, ${_pickedLocation.longitude}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        displayedLocation,
        style: theme.bodyLarge,
      ),
      subtitle: Text(
        'Tap to pick a new location',
        style: theme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
        ),
      ),
      trailing: const Icon(Icons.map),
      onTap: () async {
        final result = await context.push<PickedLocationResult>(
          locationPickerRoute,
          extra: {
            'initialLocation': _pickedLocation,
            'initialAddress': _pickedAddress,
          },
        );
        if (result != null && result.latLng != null) {
          setState(() {
            _pickedLocation = result.latLng!;
            _pickedAddress = result.address;
            _pickedLocale = result.locale;
            _pickedRegion = result.region;
            _pickedCountry = result.country;
          });
        }
      },
    );
  }

  Widget _buildTagField() {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (comma separated)',
          style: theme.labelLarge,
        ),
        TextFormField(
          controller: _tagController,
          style: theme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'e.g. beach, hiking, summer',
            hintStyle: theme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: -4.0,
          children: _tags.map((tag) {
            return ChipThemeUtil.buildStyledChip(
              label: tag,
              labelStyle: theme.bodyMedium,
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                  _tagController.text = _tags.join(', ');
                });
              },
              deleteIcon: const Icon(Icons.close),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------
  // Image Sections (unchanged)
  // ---------------------------
  Widget _buildImageSection() {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images:',
          style: theme.titleLarge,
        ),
        const SizedBox(height: 8),

        if (_imageFiles.isEmpty && _oldImageURLs.isEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'No images yet.',
              style: theme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ]
        else ...[
          if (_imageFiles.isNotEmpty) ...[
            Text('New Images:', style: theme.titleMedium),
            const SizedBox(height: 8),
            _buildNewImagesList(),
            const SizedBox(height: 16),
          ],
          if (_oldImageURLs.isNotEmpty) ...[
            Text('Existing Images:', style: theme.titleMedium),
            const SizedBox(height: 8),
            _buildExistingImagesList(),
          ]
        ],
      ],
    );
  }

  Widget _buildNewImagesList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length,
        itemBuilder: (context, index) {
          final file = _imageFiles[index];
          return _buildRemovableThumbnail(
            child: Image.file(file),
            onRemove: () => setState(() {
              _imageFiles.removeAt(index);
            }),
          );
        },
      ),
    );
  }

  Widget _buildExistingImagesList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _oldImageURLs.length,
        itemBuilder: (context, index) {
          final url = _oldImageURLs[index];
          return _buildRemovableThumbnail(
            child: Image.network(url),
            onRemove: () => setState(() {
              _removedOldImageURLs.add(url);
              _oldImageURLs.removeAt(index);
            }),
          );
        },
      ),
    );
  }

    Widget _buildRemovableThumbnail({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8.0),
          child: child,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }

  // ======================
  // Video Sections
  // ======================
  Widget _buildVideoSection() {
    final theme = Theme.of(context).textTheme;
    final hasNoVideos = _newVideoFiles.isEmpty && _oldVideoURLs.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Videos:', style: theme.titleLarge),
        const SizedBox(height: 8),
        if (hasNoVideos)
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('No videos yet.', style: TextStyle(fontStyle: FontStyle.italic))
          )
        else ...[
          if (_newVideoFiles.isNotEmpty) ...[
            Text('New Videos:', style: theme.titleMedium),
            const SizedBox(height: 8),
            _buildNewVideosList(),
            const SizedBox(height: 16),
          ],
          if (_oldVideoURLs.isNotEmpty) ...[
            Text('Existing Videos:', style: theme.titleMedium),
            const SizedBox(height: 8),
            _buildExistingVideosList(),
          ],
        ],
      ],
    );
  }

  // NEW videos
  Widget _buildNewVideosList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _newVideoFiles.length,
        itemBuilder: (context, index) {
          final file = _newVideoFiles[index];
          final thumbBytes = _newVideoThumbBytes[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () => _showFullscreenVideo(
                  context,
                  file: file, // local file
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  width: 100,
                  height: 100,
                  color: Colors.black12,
                  child: Stack(
                    children: [
                      if (thumbBytes == null)
                        const Center(
                          child: Icon(Icons.videocam, size: 40, color: Colors.white70),
                        )
                      else
                        Image.memory(
                          thumbBytes,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                        ),
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 50,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _newVideoFiles.removeAt(index);
                      _newVideoThumbBytes.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // OLD existing videos
  Widget _buildExistingVideosList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _oldVideoURLs.length,
        itemBuilder: (context, index) {
          final videoUrl = _oldVideoURLs[index];
          String? thumbUrl;
          if (index < _oldVideoThumbURLs.length) {
            thumbUrl = _oldVideoThumbURLs[index];
          }
          return Stack(
            children: [
              GestureDetector(
                onTap: () => _showFullscreenVideo(
                  context,
                  videoUrl: videoUrl,
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  width: 100,
                  height: 100,
                  color: Colors.black12,
                  child: Stack(
                    children: [
                      if (thumbUrl == null || thumbUrl.isEmpty)
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 50,
                            color: Colors.white70,
                          ),
                        )
                      else
                        Image.network(
                          thumbUrl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 50,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _removedOldVideoURLs.add(videoUrl);
                      _oldVideoURLs.removeAt(index);
                      if (index < _oldVideoThumbURLs.length) {
                        _oldVideoThumbURLs.removeAt(index);
                      }
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFullscreenVideo(
      BuildContext context, {
        File? file,
        String? videoUrl,
      }) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ChewieVideoPlayer(
            videoFile: file,
            videoUrl: videoUrl,
          ),
        );
      },
    );
  }



  // ======================
  // IMAGE / VIDEO PICK
  // ======================
  Future<void> _pickImage() async {
    final source = await _showMediaSourceDialog('Image');
    if (source == null) return;
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickVideo() async {
    final source = await _showMediaSourceDialog('Video');
    if (source == null) return;
    final pickedFile = await _picker.pickVideo(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final thumb = await _generateThumbnail(file);

      setState(() {
        _newVideoFiles.add(file);
        _newVideoThumbBytes.add(thumb);
      });
    }
  }

  Future<ImageSource?> _showMediaSourceDialog(String mediaType) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $mediaType Source'),
        actions: [
          TextButton(
            onPressed: () => context.pop(ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => context.pop(ImageSource.gallery),
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => context.pop(null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ======================
  // DATE PICK
  // ======================
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _monthName = DateFormat('MMMM').format(_selectedDate);
      });
    }
  }

  // ======================
  // SAVE
  // ======================
  Future<void> _saveEntry(String userID) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // 1) Upload new images
      final newImageURLs = await _uploadNewImages();

      // 2) Upload new videos & thumbs
      final newVideoURLs = <String>[];
      final newVideoThumbURLs = <String>[];

      for (int i = 0; i < _newVideoFiles.length; i++) {
        final videoFile = _newVideoFiles[i];
        // Upload the video
        final ext = _getFileExtension(videoFile.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
        final videoURL = await _storageService.uploadFile(
          videoFile,
          'videos/$fileName',
        );
        newVideoURLs.add(videoURL);

        // Upload the thumbnail if available
        final thumbBytes = _newVideoThumbBytes[i];
        if (thumbBytes != null) {
          final thumbFile = await _saveBytesToTempFile(thumbBytes);
          final thumbUploadName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final uploadedThumbURL = await _storageService.uploadFile(
            thumbFile,
            'thumbnails/$thumbUploadName',
          );
          await thumbFile.delete();
          newVideoThumbURLs.add(uploadedThumbURL);
        } else {
          newVideoThumbURLs.add('');
        }
      }

      // 3) Remove old media
      await _removeOldMedia();

      // 4) Combine old + new videos (and thumbs)
      final finalVideoURLs = [..._oldVideoURLs, ...newVideoURLs];
      final finalVideoThumbs = [..._oldVideoThumbURLs, ...newVideoThumbURLs];

      // 5) Parse tags
      final typedTags = _tagController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final finalTags = {..._tags, ...typedTags}.toList();

      // 6) Build final lists
      final finalImageURLs = [
        ..._oldImageURLs,
        ...newImageURLs,
      ];

      // 7) Create the updated JournalEntry
      final updatedEntry = JournalEntry(
        entryID: widget.existingEntry?.entryID,
        userID: widget.existingEntry?.userID ?? userID,
        title: _titleController.text,
        description: _descriptionController.text,
        timestamp: _selectedDate,
        latitude: _pickedLocation.latitude,
        longitude: _pickedLocation.longitude,
        address: _pickedAddress,
        imageURLs: finalImageURLs,
        videoURLs: finalVideoURLs,
        videoThumbnailURLs: finalVideoThumbs,
        localeName: _pickedLocale,
        regionName: _pickedRegion,
        countryName: _pickedCountry,
        tags: finalTags,
        monthName: _monthName,
      );

      // 8) Save via provider
      final provider = context.read<JournalEntryProvider>();
      if (_isEditMode) {
        await provider.updateEntry(updatedEntry.entryID!, updatedEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry updated successfully!')),
        );
      } else {
        await provider.addEntry(updatedEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error saving entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving entry')),
      );
    } finally {
      setState(() => _isSaving = false);
    }

    // Navigate
    if (_isEditMode) {
      if (mounted) context.pop();
    } else {
      if (mounted) context.go(homeRoute);
    }
  }

  // ======================
  // Upload / Remove Helpers
  // ======================
  Future<List<String>> _uploadNewImages() async {
    final newImageURLs = <String>[];
    for (File imageFile in _imageFiles) {
      final ext = _getFileExtension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final imageURL = await _storageService.uploadFile(
        imageFile,
        'images/$fileName',
      );
      newImageURLs.add(imageURL);
    }
    return newImageURLs;
  }

  Future<void> _removeOldMedia() async {
    // remove old images
    for (final url in _removedOldImageURLs) {
      await _storageService.deleteFileByUrl(url);
    }
    // remove old videos
    for (final url in _removedOldVideoURLs) {
      await _storageService.deleteFileByUrl(url);
    }
    _oldImageURLs.removeWhere((url) => _removedOldImageURLs.contains(url));
    _oldVideoURLs.removeWhere((url) => _removedOldVideoURLs.contains(url));
  }

  String _getFileExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filePath.substring(dotIndex).toLowerCase();
  }

  Future<File> _saveBytesToTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final tempFile = File('${dir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }
}
