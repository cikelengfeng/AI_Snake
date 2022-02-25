import 'dart:math';

int randomWeighted(List<int> weight, Random random) {
  int t = weight.fold(0, (previousValue, element) => previousValue + element);
  int r = random.nextInt(t);
  int index = 0;
  int c = 0;
  while (true) {
    c += weight[index];
    if (c > r) {
      break;
    }
    index += 1;
  }
  return index;
}
