import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/util/storage_service.dart';

class EntryCreationForm extends StatefulWidget {
  final JournalEntry? existingEntry;
  const EntryCreationForm({super.key, this.existingEntry});

  @override
  _EntryCreationFormState createState() => _EntryCreationFormState();
}


class _EntryCreationFormState extends State<EntryCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();

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

  bool get _isEditMode => widget.existingEntry != null;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
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

      // Keep old remote URLs so we can merge them if user doesn't replace
      if (existing.imageURLs != null) {
        _oldImageURLs = List.from(existing.imageURLs!);
      }
      if (existing.videoURLs != null) {
        _oldVideoURLs = List.from(existing.videoURLs!);
      }
    }
  }

  // A simple helper to extract file extension
  String _getFileExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filePath.substring(dotIndex).toLowerCase();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    // 1) Upload newly picked images
    List<String> newImageURLs = [];
    for (File imageFile in _imageFiles) {
      final ext = _getFileExtension(imageFile.path); // e.g. ".jpg"
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final imageURL = await _storageService.uploadFile(
        imageFile,
        'images/$fileName',
      );
      newImageURLs.add(imageURL);
      print('imageURL = $imageURL');
    }

    // 2) Upload newly picked videos
    List<String> newVideoURLs = [];
    for (File videoFile in _videoFiles) {
      final ext = _getFileExtension(videoFile.path); // e.g. ".mp4"
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final videoURL = await _storageService.uploadFile(
        videoFile,
        'videos/$fileName',
      );
      newVideoURLs.add(videoURL);
    }

    // If we want to keep old URLs (user didn't remove them)
    // merge old + new. If you want to discard old URLs, skip this step.
    List<String> finalImageURLs = [..._oldImageURLs, ...newImageURLs];
    List<String> finalVideoURLs = [..._oldVideoURLs, ...newVideoURLs];

    // 3) Create or update the JournalEntry with full remote URLs
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Entry' : 'Create New Entry'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTitleField(),
              _buildDescriptionField(),
              _buildDatePicker(),
              _buildLocationPicker(),
              _buildImagePicker(),
              _buildVideoPicker(),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text(_isEditMode ? 'Update Entry' : 'Save Entry'),
              ),
            ],
          ),
        ),
      ),
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
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Widget _buildLocationPicker() {
    return ListTile(
      title: Text(
        'Location: ${_pickedLocation.latitude}, ${_pickedLocation.longitude}',
      ),
      trailing: const Icon(Icons.map),
      onTap: () {
        // Just placeholder logic
        setState(() {
          _pickedLocation = const LatLng(34.0522, -118.2437);
        });
      },
    );
  }

  Widget _buildImagePicker() {
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
              return Image.file(_imageFiles[index]);
            },
          ),
        ),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Add Image'),
        ),
        if (_oldImageURLs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Existing Images:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        if (_oldImageURLs.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _oldImageURLs.length,
              itemBuilder: (context, index) {
                final url = _oldImageURLs[index];
                return Image.network(url);
              },
            ),
          ),
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

  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Videos:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _videoFiles.length,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                alignment: Alignment.center,
                child: Text('Video ${index + 1}'),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _pickVideo,
          child: const Text('Add Video'),
        ),
        if (_oldVideoURLs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Existing Videos:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        if (_oldVideoURLs.isNotEmpty)
          Column(
            children: _oldVideoURLs.map((url) => Text(url)).toList(),
          ),
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
