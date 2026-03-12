import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/event.dart';
import 'package:jacht_log/presentation/mode.dart';

class BoatControls extends StatelessWidget {
  const BoatControls({super.key, required this.boat, required this.trip});

  final Boat boat;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            children: [
              SwitchListTile(
                title: Text(EventSource.port.label),
                value: boat.isOn(EventSource.port),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.port)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.engine.label),
                value: boat.isOn(EventSource.engine),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.engine)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.anchor.label),
                value: boat.isOn(EventSource.anchor),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.anchor)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.sail.label),
                value: boat.isOn(EventSource.sail),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.sail)
                    : null,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
              child: Text(
                boat.mode.label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
