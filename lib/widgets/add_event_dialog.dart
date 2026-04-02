import 'package:flutter/material.dart';
import 'package:jacht_log/presentation/event_preset.dart';
import 'package:jacht_log/presentation/event_result.dart';

class AddEventDialog extends StatefulWidget {
  final DateTime minTime;
  final DateTime maxTime;

  const AddEventDialog({
    super.key,
    required this.minTime,
    required this.maxTime,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  DateTime _timestamp = DateTime.now();
  EventPreset? _selectedPreset;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: widget.minTime,
      lastDate: widget.maxTime,
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );

    if (time == null) return;

    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add event"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _timestamp.toString(), // możesz sformatować
                ),
              ),
              IconButton(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today),
              ),
            ],
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<EventPreset>(
            initialValue: _selectedPreset,
            decoration: const InputDecoration(labelText: "Event"),
            items: eventPresets.map((preset) {
              return DropdownMenuItem<EventPreset>(
                value: preset,
                child: Text(preset.description(context)),
              );
            }).toList(),
            onChanged: (preset) {
              setState(() {
                _selectedPreset = preset;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _submit, child: const Text("Add")),
      ],
    );
  }

  void _submit() {
    if (_selectedPreset == null) return;
    Navigator.pop(
      context,
      EventResult(
        timestamp: _timestamp,
        source: _selectedPreset!.source,
        type: _selectedPreset!.type,
      ),
    );
  }
}
