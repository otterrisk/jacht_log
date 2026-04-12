import 'dart:async';

import 'package:flutter/material.dart';

mixin TripTickerMixin<T extends StatefulWidget> on State<T> {
  Timer? _ticker;

  Listenable get trip;

  bool get isActive;

  Duration get tickInterval => const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    trip.addListener(_onTripChanged);
    _updateTicker();
  }

  @override
  void dispose() {
    trip.removeListener(_onTripChanged);
    _ticker?.cancel();
    super.dispose();
  }

  void _onTripChanged() {
    _updateTicker();
    if (mounted) setState(() {});
  }

  void _updateTicker() {
    _ticker?.cancel();

    if (isActive) {
      _ticker = Timer.periodic(tickInterval, (_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }
}
