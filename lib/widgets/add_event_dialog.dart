import 'package:flutter/material.dart';
import 'package:jacht_log/presentation/models/event_preset.dart';
import 'package:jacht_log/presentation/models/event_result.dart';
import 'package:jacht_log/widgets/date_time_picker.dart';

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
  late DateTime _timestamp;
  String? _errorText;
  EventPreset? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _timestamp = widget.maxTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add event"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<EventPreset>(
            key: const Key("eventDropdown"),
            initialValue: _selectedPreset,
            decoration: const InputDecoration(labelText: "Event"),
            items: eventPresets.map((preset) {
              return DropdownMenuItem<EventPreset>(
                key: Key("${preset.source.name}-${preset.type.name}"),
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

          const SizedBox(height: 12),

          DateTimePicker(
            value: _timestamp,
            firstDate: widget.minTime,
            lastDate: widget.maxTime,
            errorText: _errorText,
            onChanged: (newTs) {
              setState(() {
                _timestamp = newTs;
                _errorText = _timestamp.validate(
                  min: widget.minTime,
                  max: widget.maxTime,
                );
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key("cancelButton"),
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          key: const Key("addButton"),
          onPressed: _errorText == null ? _submit : null,
          child: const Text('Add'),
        ),
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
