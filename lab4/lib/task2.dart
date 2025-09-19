import 'dart:io';

void main() {
  String name;
  while (true) {
    stdout.write("Enter your name: ");
    String? input = stdin.readLineSync();
    if (input != null && input.trim().isNotEmpty) {
      if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(input)) {
        name = input.trim();
        break;
      } else {
        print("Name should only contain letters. Please try again.");
      }
    } else {
      print("Name cannot be empty. Please enter your name.");
    }
  }

  int age;
  while (true) {
    stdout.write("Enter your age: ");
    String? input = stdin.readLineSync();
    if (input != null) {
      try {
        age = int.parse(input);
        break;
      } catch (e) {
        print("Invalid age. Please enter a valid number.");
      }
    }
  }

  if (age < 18) {
    print("Sorry $name, you are not eligible to register.");
    return;
  }
  print("Welcome $name! You are eligible to register.\n");

  int n;
  while (true) {
    stdout.write("How many numbers do you want to enter? ");
    String? input = stdin.readLineSync();
    if (input != null) {
      try {
        n = int.parse(input);
        if (n > 0) {
          break;
        } else {
          print("Please enter a number greater than 0.");
        }
      } catch (e) {
        print("Invalid input. Please enter a valid number.");
      }
    }
  }

  List<int> numbers = [];
  for (int i = 1; i <= n; i++) {
    while (true) {
      stdout.write("Enter number $i: ");
      String? input = stdin.readLineSync();
      if (input != null) {
        try {
          int value = int.parse(input);
          numbers.add(value);
          break;
        } catch (e) {
          print("Invalid number. Please enter again.");
        }
      }
    }
  }

  int evenSum = 0;
  int oddSum = 0;
  for (int num in numbers) {
    if (num % 2 == 0) {
      evenSum += num;
    } else {
      oddSum += num;
    }
  }

  int largest = numbers.reduce((a, b) => a > b ? a : b);
  int smallest = numbers.reduce((a, b) => a < b ? a : b);

  print("\nResults");
  print("Numbers entered: $numbers");
  print("Sum of even numbers: $evenSum");
  print("Sum of odd numbers: $oddSum");
  print("Largest number: $largest");
  print("Smallest number: $smallest");
}
