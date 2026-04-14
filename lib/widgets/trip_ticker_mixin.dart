import 'dart:async';

import 'package:flutter/material.dart';

mixin TripTickerMixin<T extends StatefulWidget> on State<T> {
  Timer? _ticker;
  Listenable? _tripRef;

  Listenable get trip;

  bool get isActive;

  Duration get tickInterval => const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _attachTrip();
    _updateTicker();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_tripRef != trip) {
      _detachTrip();
      _attachTrip();
      _updateTicker();
    }
  }

  @override
  void dispose() {
    _detachTrip();
    _ticker?.cancel();
    super.dispose();
  }

  void _attachTrip() {
    _tripRef = trip;
    _tripRef?.addListener(_onTripChanged);
  }

  void _detachTrip() {
    _tripRef?.removeListener(_onTripChanged);
    _tripRef = null;
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
