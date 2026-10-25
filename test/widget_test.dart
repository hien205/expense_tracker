import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Kiểm tra phép tính thu chi', () {
    const totalIncome = 10000000;
    const totalExpense = 4000000;

    expect(totalIncome - totalExpense, 6000000);
  });
}