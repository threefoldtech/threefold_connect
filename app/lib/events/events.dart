class Events {
  static final Events _singleton = new Events._internal();

  factory Events() {
    return _singleton;
  }

  Map<Type, dynamic> eventList = Map<Type, dynamic>();

  Events._internal(); // init here

  onEvent(Type eventType, Function function) {
    if (this.eventList[eventType] == null) {
      this.eventList[eventType] = [];
    }
    this.eventList[eventType].add(function);
  }

  emit(var event) {
    var eventType = event.runtimeType;
    if (this.eventList[eventType] == null) {
      return;
    }
    for (var function in this.eventList[eventType]) {
      function(event);
    }
  }

  reset() {
    eventList = Map<Type, dynamic>();
  }
}
