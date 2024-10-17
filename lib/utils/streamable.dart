import 'dart:async';

class Streamable<T> {
  late final StreamController<T> _streamController;

  Streamable([T? initialValue]) {
    _streamController = StreamController<T>();

    if(initialValue != null) _lastEvent = initialValue;
  }

  late T _lastEvent;
  
  void listen(void Function(T) onData) {
    _streamController.stream.listen(onData);
  }

  void dispose() {
    _streamController.close();
  }

  void add(T event) {
    _streamController.add(event);
    _lastEvent = event;
  }

  T get value => _lastEvent;

  Stream<T> get stream => _streamController.stream;
}