import 'dart:io';

void main() {
  stdout.write("Enter the number of rows (n): ");
  int n = int.parse(stdin.readLineSync()!);

  // Outer loop: rows
  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= i; j++) {
      stdout.write("$j ");
    }
    print("");
  }
}
