import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:travellista/models/journal_entry.dart'; // Importing JournalEntry class

class EntryCreationForm extends StatefulWidget {
  @override
  _EntryCreationFormState createState() => _EntryCreationFormState();
}

class _EntryCreationFormState extends State<EntryCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  LatLng _pickedLocation =
      LatLng(37.7749, -122.4194); // Default to San Francisco
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
    // Implement your logic for location picking here
    // This example is a placeholder
    setState(() {
      _pickedLocation = LatLng(34.0522, -118.2437); // Simulated picked location
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

  // Method Definitions for form fields, date picker, and image picker...

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      // Create an instance of JournalEntry using the collected data
      JournalEntry newEntry = JournalEntry(
        entryID: null, // Firestore will auto-generate this on save
        userID:
            'your_user_id_here', // Replace with actual user ID as per your logic
        title: _titleController.text,
        description: _descriptionController.text,
        timestamp:
            _selectedDate, // You may want to convert to appropriate type if needed
        latitude: _pickedLocation.latitude,
        longitude: _pickedLocation.longitude,
        imageURLs: _imageFiles
            .map((file) => file.path)
            .toList(), // Assuming you have URLs
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('journal_entries')
          .add(newEntry.toMap());

      // Optionally, show a confirmation message or navigate back
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Entry saved successfully!')));
      Navigator.pop(context); // Go back to the previous screen
    }
  }
}
