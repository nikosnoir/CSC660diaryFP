import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'emotions.dart';
import 'package:uuid/uuid.dart';
import 'globals.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _title = widget.entry!.title;
      _description = widget.entry!.description;
      _emotion = emotions.containsKey(widget.entry!.emotion) ? widget.entry!.emotion : 'Neutral';

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

  void _selectEmotion() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 250,
          child: GridView.count(
            crossAxisCount: 5,
            children: emotions.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _emotion = entry.key;
                  });
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(entry.value, height: 40),
                    const SizedBox(height: 4),
                    Text(entry.key, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isSaving = true);

      final now = DateTime.now();

      final entry = DiaryEntry(
        id: widget.entry?.id ?? const Uuid().v4(),
        title: _title,
        description: _description,
        date: "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
        emotion: _emotion,
        user: currentUserEmail,
        createdAt: widget.entry?.createdAt ?? now,
        updatedAt: now,
      );

      await Future.delayed(const Duration(seconds: 2)); // simulate delay

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, entry);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Stack(
      children: [
        Scaffold(
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
                  onPressed: _isSaving ? null : _saveEntry,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${_selectedDate.day.toString().padLeft(2, '0')} ${_selectedDate.monthName()}, ${_selectedDate.year}",
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
                      GestureDetector(
                        onTap: _selectEmotion,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            emotions[_emotion] ?? 'assets/emotions/neutral_emoji.gif',
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: textColor?.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 18, color: textColor),
                    initialValue: _title,
                    onSaved: (val) => _title = val ?? '',
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                  ),
                  const Divider(),

                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Write more here...',
                        hintStyle: TextStyle(color: textColor?.withOpacity(0.4)),
                        border: InputBorder.none,
                      ),
                      initialValue: _description,
                      onSaved: (val) => _description = val ?? '',
                      validator: (val) => val == null || val.isEmpty ? 'Please enter a description' : null,
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
        ),

        if (_isSaving)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/animations/saving.gif', height: 150),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Extension
extension MonthName on DateTime {
  String monthName() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
