Future<List<R>> mapBounded<T, R>(
  Iterable<T> items,
  int limit,
  Future<R> Function(T) task,
) async {
  final source = items.toList();
  final results = List<R?>.filled(source.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (cursor < source.length) {
      final index = cursor++;
      results[index] = await task(source[index]);
    }
  }

  if (source.isNotEmpty) {
    await Future.wait(
      List.generate(limit.clamp(1, source.length), (_) => worker()),
    );
  }
  return results.cast<R>();
}
