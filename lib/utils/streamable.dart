import 'dart:async';

class Streamable<T> {
  late final StreamController<T> _streamController;

  Streamable() {
    _streamController = StreamController<T>();
  }

  void listen(void Function(T) onData) {
    _streamController.stream.listen(onData);
  }

  void dispose() {
    _streamController.close();
  }

  void add(T event) {
    _streamController.add(event);
  }

  Stream<T> get stream => _streamController.stream;
}