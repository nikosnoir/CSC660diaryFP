import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'emotions.dart';
import 'package:uuid/uuid.dart';

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
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final entry = DiaryEntry(
                    id: widget.entry?.id ?? const Uuid().v4(),
                    title: _title,
                    description: _description,
                    date:
                        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                    emotion: _emotion,
                  );
                  Navigator.pop(context, entry);
                }
              },
              child: const Text("Save"),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date and Emoji Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${_selectedDate.day.toString().padLeft(2, '0')} "
                    "${_selectedDate.monthName()}, ${_selectedDate.year}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
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
                    icon: const Icon(Icons.arrow_drop_down, size: 28),
                    color: textColor,
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Text(
                      emotions[_emotion] ?? '😐',
                      style: const TextStyle(fontSize: 28),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),

              // Emotion Dropdown (hidden, but value still used)
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
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please select an emotion' : null,
              ),

              const SizedBox(height: 16),

              // Title
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: textColor?.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 18, color: textColor),
                initialValue: _title,
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const Divider(),

              // Description
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Write more here...',
                    hintStyle: TextStyle(color: textColor?.withOpacity(0.4)),
                    border: InputBorder.none,
                  ),
                  initialValue: _description,
                  onSaved: (val) => _description = val ?? '',
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter a description' : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension for month name formatting
extension MonthName on DateTime {
  String monthName() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[this.month - 1];
  }
}
