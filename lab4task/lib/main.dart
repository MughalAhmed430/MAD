class Student {
  final String name;
  final int age;

  // 1. Default constructor
  Student()
      : name = "Unknown",
        age = 0;

  // 2. Parameterized constructor
  Student.parameterized(this.name, this.age);

  // 3. Named constructor
  Student.named({required String studentName, required int studentAge})
      : name = studentName,
        age = studentAge;

  // 4. Redirecting constructor
  Student.young(String studentName) : this.parameterized(studentName, 18);

  // 5. Constant constructor (for immutable objects)
  const Student.constant(this.name, this.age);

  void display() {
    print("Name: $name, Age: $age");
  }
}

void main() {
  // Using default constructor
  var s1 = Student();
  print("Default Constructor:");
  s1.display();

  s1 = Student.parameterized("Ali", 22);
  print("\n After updating S1:");
  s1.display();
  // Using parameterized constructor
  var s2 = Student.parameterized("Ali", 22);
  print("\nParameterized Constructor:");
  s2.display();

  // Using named constructor
  var s3 = Student.named(studentName: "Waqar", studentAge: 25);
  print("\nNamed Constructor:");
  s3.display();

  // Using redirecting constructor
  var s4 = Student.young("Hassan");
  print("\nRedirecting Constructor:");
  s4.display();


  // Using constant constructor
  const s5 = Student.constant("Bilal", 30);
  print("\nConstant Constructor:");
  s5.display();

}