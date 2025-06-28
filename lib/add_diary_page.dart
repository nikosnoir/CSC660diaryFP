import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'emotions.dart';

class AddDiaryPage extends StatefulWidget {
  final DiaryEntry? entry;

  const AddDiaryPage({super.key, this.entry});

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _emotion = emotions.keys.first;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _title = widget.entry!.title;
      _description = widget.entry!.description;
      _emotion = emotions.keys.contains(widget.entry!.emotion)
          ? widget.entry!.emotion
          : 'Neutral';
      final parts = widget.entry!.date.split('/');
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Diary Entry')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _emotion,
                decoration: const InputDecoration(
                  labelText: 'Emotion',
                  border: OutlineInputBorder(),
                ),
                items: emotions.keys
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text('${emotions[e]} $e'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _emotion = val!),
                onSaved: (val) => _emotion = val ?? emotions.keys.first,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please select an emotion' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                initialValue: _title,
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                initialValue: _description,
                onSaved: (val) => _description = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Pick Date"),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final entry = DiaryEntry(
                        title: _title,
                        description: _description,
                        date: "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                        emotion: _emotion, // _emotion should be 'Happy', 'Sad', etc.
                      );
                      Navigator.pop(context, entry);
                    }
                  },
                  child: const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}