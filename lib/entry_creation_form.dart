import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:travellista/models/journal_entry.dart';
import 'package:provider/provider.dart';
import 'package:travellista/providers/journal_entry_provider.dart';

class EntryCreationForm extends StatefulWidget {
  @override
  _EntryCreationFormState createState() => _EntryCreationFormState();
}

class _EntryCreationFormState extends State<EntryCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  LatLng _pickedLocation = LatLng(37.7749, -122.4194);
  List<File> _imageFiles = [];
  List<File> _videoFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Entry'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildTitleField(),
              _buildDescriptionField(),
              _buildDatePicker(),
              _buildLocationPicker(),
              _buildImagePicker(),
              _buildVideoPicker(),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      // Create JournalEntry object from the form fields
      final newEntry = JournalEntry(
        entryID: null,
        userID: 'some_user_id', // Replace with real user logic as needed
        title: _titleController.text,
        description: _descriptionController.text,
        timestamp: _selectedDate,
        latitude: _pickedLocation.latitude,
        longitude: _pickedLocation.longitude,
        imageURLs: _imageFiles.map((file) => file.path).toList(),
        videoURLs: _videoFiles.map((file) => file.path).toList(),
        // tags: [...]
      );

      // Call provider's addEntry method
      await context.read<JournalEntryProvider>().addEntry(newEntry);

      // Display success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry saved successfully!')),
      );

      // Pop back to home
      Navigator.pop(context);
    }
  }

  // Method Definitions for form fields, date picker, and image picker...

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(labelText: 'Title'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(labelText: 'Description'),
      maxLines: 3,
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
      trailing: Icon(Icons.calendar_today),
      onTap: _pickDate,
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
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
          'Location: ${_pickedLocation.latitude}, ${_pickedLocation.longitude}'),
      trailing: Icon(Icons.map),
      onTap: _pickLocation,
    );
  }

  Future<void> _pickLocation() async {
    // This example is a placeholder and will be replaced in next milestone
    setState(() {
      _pickedLocation = LatLng(34.0522, -118.2437);
    });
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
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
          child: Text('Add Image'),
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
      children: [
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _videoFiles.length,
            itemBuilder: (context, index) {
              // Display video thumbnail or an indicator
              return Container(
                width: 100,
                child: Center(child: Text('Video ${index + 1}')),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _pickVideo,
          child: Text('Add Video'),
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
