class Events {
  static final Events _singleton = Events._internal();

  factory Events() {
    return _singleton;
  }

  Map<Type, dynamic> eventList = <Type, dynamic>{};

  Events._internal(); // init here

  onEvent(Type eventType, Function function) {
    if (eventList[eventType] == null) {
      eventList[eventType] = [];
    }
    eventList[eventType].add(function);
  }

  emit(var event) {
    var eventType = event.runtimeType;
    if (eventList[eventType] == null) {
      return;
    }
    for (var function in eventList[eventType]) {
      function(event);
    }
  }

  reset() {
    eventList = <Type, dynamic>{};
  }
}
