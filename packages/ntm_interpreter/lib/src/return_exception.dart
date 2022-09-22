class ReturnException implements Exception {
  const ReturnException(this.value);

  final Object? value;
}
