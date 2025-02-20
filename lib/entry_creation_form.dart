import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/video_player_widget.dart';
import 'package:travellista/location_picker_screen.dart';

class EntryCreationForm extends StatefulWidget {
  final JournalEntry? existingEntry;
  final StorageService? storageOverride;

  const EntryCreationForm({super.key, this.existingEntry, this.storageOverride});

  @override
  _EntryCreationFormState createState() => _EntryCreationFormState();
}

class _EntryCreationFormState extends State<EntryCreationForm> {
  final _formKey = GlobalKey<FormState>();
  late final StorageService _storageService;

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // State
  DateTime _selectedDate = DateTime.now();
  LatLng _pickedLocation = const LatLng(37.7749, -122.4194);

  // For newly picked files only
  List<File> _imageFiles = [];
  List<File> _videoFiles = [];

  // For old remote URLs we want to keep
  List<String> _oldImageURLs = [];
  List<String> _oldVideoURLs = [];

  // For old remote URLs we want to remove
  final List<String> _removedOldImageURLs = [];
  final List<String> _removedOldVideoURLs = [];

  // Track saving state
  bool _isSaving = false;

  bool get _isEditMode => widget.existingEntry != null;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageOverride ?? StorageService();
    if (_isEditMode) {
      final existing = widget.existingEntry!;
      _titleController.text = existing.title ?? '';
      _descriptionController.text = existing.description ?? '';
      if (existing.timestamp != null) {
        _selectedDate = existing.timestamp!;
      }
      if (existing.latitude != null && existing.longitude != null) {
        _pickedLocation = LatLng(existing.latitude!, existing.longitude!);
      }

      // Keep old remote URLs
      if (existing.imageURLs != null) {
        _oldImageURLs = List.from(existing.imageURLs!);
      }
      if (existing.videoURLs != null) {
        _oldVideoURLs = List.from(existing.videoURLs!);
      }
    }
  }

  String _getFileExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filePath.substring(dotIndex).toLowerCase();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
    // 1. Upload newly picked images
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

    // 2. Upload newly picked videos
    final newVideoURLs = <String>[];
    for (File videoFile in _videoFiles) {
      final ext = _getFileExtension(videoFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final videoURL = await _storageService.uploadFile(
        videoFile,
        'videos/$fileName',
      );
      newVideoURLs.add(videoURL);
    }

    // 3. Remove old media that user chose to remove
    for (final url in _removedOldImageURLs) {
      await _storageService.deleteFileByUrl(url); // Implement in your StorageService
    }
    for (final url in _removedOldVideoURLs) {
      await _storageService.deleteFileByUrl(url); // Same approach
    }

    // Also exclude them from the final arrays
    _oldImageURLs.removeWhere((url) => _removedOldImageURLs.contains(url));
    _oldVideoURLs.removeWhere((url) => _removedOldVideoURLs.contains(url));

    // 4. Combine old + new
    final finalImageURLs = [..._oldImageURLs, ...newImageURLs];
    final finalVideoURLs = [..._oldVideoURLs, ...newVideoURLs];

    // 5. Create or update the JournalEntry
    final updatedEntry = JournalEntry(
      entryID: widget.existingEntry?.entryID,
      userID: widget.existingEntry?.userID ?? 'some_user_id',
      title: _titleController.text,
      description: _descriptionController.text,
      timestamp: _selectedDate,
      latitude: _pickedLocation.latitude,
      longitude: _pickedLocation.longitude,
      imageURLs: finalImageURLs,
      videoURLs: finalVideoURLs,
    );

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

    Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving entry')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Scaffold underneath
        SharedScaffold(
          title: _isEditMode ? 'Edit Entry' : 'Create New Entry',
          selectedIndex: 1,
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
                    _buildDescriptionField(),
                    _buildDatePicker(),
                    _buildLocationPicker(),
                    const SizedBox(height: 8),
                    _buildImagePicker(),
                    const SizedBox(height: 8),
                    _buildVideoPicker(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveEntry,
                      child: Text(_isEditMode ? 'Update Entry' : 'Save Entry'),
                    ),
                    const SizedBox(height: 20),
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
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  //-------------------------------------------------------------------------
  // UI WIDGETS
  //-------------------------------------------------------------------------

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: 'Title'),
      validator: (value) =>
      (value == null || value.isEmpty) ? 'Please enter a title' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 3,
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
      trailing: const Icon(Icons.calendar_today),
      onTap: _pickDate,
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Widget _buildLocationPicker() {
    return ListTile(
      title: Text(
        'Location: ${_pickedLocation.latitude}, ${_pickedLocation.longitude}',
      ),
      trailing: const Icon(Icons.map),
      onTap: () async {
        // Nav to LocationPickerScreen
        final chosenLocation = await Navigator.push<LatLng?>(
          context,
          MaterialPageRoute(
            builder: (_) => LocationPickerScreen(
              // Pass current _pickedLocation as init center
              initialLocation: _pickedLocation,
            ),
          ),
        );

        // Update state
        if (chosenLocation != null) {
          setState(() {
            _pickedLocation = chosenLocation;
          });
        }
      },
    );
  }

  //-------------------------------------------------------------------------
  // IMAGE PICKER + REMOVAL
  //-------------------------------------------------------------------------

  Widget _buildNewImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Images:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFiles.length,
            itemBuilder: (context, index) {
              final file = _imageFiles[index];
              return _buildRemovableThumbnail(
                child: Image.file(file),
                onRemove: () {
                  setState(() {
                    _imageFiles.removeAt(index);
                  });
                },
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Add Image'),
        ),
      ],
    );
  }

  Widget _buildExistingImagesSection() {
    if (_oldImageURLs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Existing Images:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _oldImageURLs.length,
            itemBuilder: (context, index) {
              final url = _oldImageURLs[index];
              return _buildRemovableThumbnail(
                child: Image.network(url),
                onRemove: () {
                  setState(() {
                    _removedOldImageURLs.add(url);
                    _oldImageURLs.remove(url);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRemovableThumbnail({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNewImagesSection(),
        _buildExistingImagesSection(),
      ],
    );
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  //-------------------------------------------------------------------------
  // VIDEO PICKER + REMOVAL
  //-------------------------------------------------------------------------

  Widget _buildNewVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Videos:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _videoFiles.length,
            itemBuilder: (context, index) {
              final file = _videoFiles[index];
              return _buildRemovableVideo(
                child: SizedBox(
                  width: 200,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ChewieVideoPlayer(videoFile: file),
                  ),
                ),
                onRemove: () {
                  setState(() {
                    _videoFiles.removeAt(index);
                  });
                },
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _pickVideo,
          child: const Text('Add Video'),
        ),
      ],
    );
  }

  Widget _buildExistingVideosSection() {
    if (_oldVideoURLs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Existing Videos:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _oldVideoURLs.length,
            itemBuilder: (context, index) {
              final url = _oldVideoURLs[index];
              return _buildRemovableVideo(
                child: SizedBox(
                  width: 200,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ChewieVideoPlayer(videoUrl: url),
                  ),
                ),
                onRemove: () {
                  setState(() {
                    _removedOldVideoURLs.add(url);
                    _oldVideoURLs.remove(url);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRemovableVideo({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
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

  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNewVideosSection(),
        _buildExistingVideosSection(),
      ],
    );
  }


  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFiles.add(File(pickedFile.path));
      });
    }
  }
}