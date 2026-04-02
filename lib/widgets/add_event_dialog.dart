import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/widgets/add_event_result.dart';

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  DateTime _timestamp = DateTime.now();
  EventSource? _source;
  EventType? _type;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
          // 📅 timestamp
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

          DropdownButtonFormField<EventSource>(
            initialValue: _source,
            items: EventSource.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _source = value!;
              });
            },
          ),

          DropdownButtonFormField<EventType>(
            initialValue: _type,
            items: EventType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _type = value!;
              });
            },
          ),

          // 📝 description
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
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
    final description = _descriptionController.text.trim();

    Navigator.pop(
      context,
      AddEventResult(
        timestamp: _timestamp,
        source: EventSource.port,
        type: EventType.start,
      ),
    );
  }
}
