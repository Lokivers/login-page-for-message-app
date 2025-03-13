import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event.dart';
import '../repositories/event_repository.dart';

class UploadEventScreen extends StatefulWidget {
  const UploadEventScreen({super.key});

  @override
  State<UploadEventScreen> createState() => _UploadEventScreenState();
}

class _UploadEventScreenState extends State<UploadEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _repository = EventRepository();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _repository.uploadImage(_imageFile!);
        } else if (_imageUrlController.text.isNotEmpty) {
          imageUrl = _imageUrlController.text;
        }

        final event = Event(
          id: DateTime.now().toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          location: _locationController.text,
          category: _categoryController.text,
          imageUrl: imageUrl ?? '',
        );

        await _repository.uploadEvent(event);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error uploading event: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Event'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Description is required'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Event Date'),
                    subtitle: Text(
                      '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 16),
                  if (_imageFile != null)
                    Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'Enter image URL or pick an image',
                    ),
                    enabled: _imageFile == null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Upload Event'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
