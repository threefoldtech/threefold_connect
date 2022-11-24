mixin BlockAndRunMixin {
  bool _processingCallback = false;

  void blockAndRunAsync(Function function) async {
    if (!_processingCallback) {
      _processingCallback = true;
      await function();
    }
    _processingCallback = false;
  }

  void blockAndRun(Function function) {
    if (!_processingCallback) {
      _processingCallback = true;
      function();
    }
    _processingCallback = false;
  }
}
