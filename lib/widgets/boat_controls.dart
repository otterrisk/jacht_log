import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/presentation/boat_state.dart';
import 'package:jacht_log/presentation/event.dart';

class BoatControls extends StatelessWidget {
  const BoatControls({super.key, required this.boat, required this.active});

  final Boat boat;
  final bool active;

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
            childAspectRatio: 4,
            children: [
              SwitchListTile(
                title: Text(EventSource.port.label(context)),
                value: boat.state.isOn(EventSource.port),
                onChanged: active ? (_) => boat.toggle(EventSource.port) : null,
              ),
              SwitchListTile(
                title: Text(EventSource.engine.label(context)),
                value: boat.state.isOn(EventSource.engine),
                onChanged: active
                    ? (_) => boat.toggle(EventSource.engine)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.anchor.label(context)),
                value: boat.state.isOn(EventSource.anchor),
                onChanged: active
                    ? (_) => boat.toggle(EventSource.anchor)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.sail.label(context)),
                value: boat.state.isOn(EventSource.sail),
                onChanged: active ? (_) => boat.toggle(EventSource.sail) : null,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
              child: Text(
                boat.state.mode.label(context),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
