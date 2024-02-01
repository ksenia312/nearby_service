import 'dart:math';

class RandomUtils {
  static RandomUtils? _instance;

  static RandomUtils get instance {
    return _instance ?? RandomUtils();
  }

  final _random = Random();

  int nextInt(int min, int max) {
    return _random.nextInt(max - min) + min;
  }
}
