import 'bus.dart';

/// Cell interface for registering handlers with the bus
abstract class Cell {
  /// Unique identifier for this cell
  String get id;

  /// List of subjects this cell subscribes to
  List<String> get subjects;

  /// Register this cell's handlers with the bus
  Future<void> register(BodyBus bus);
}
