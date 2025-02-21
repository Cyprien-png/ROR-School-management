# Clean up existing data
SchoolClass.all.each { |school_class| school_class.students.clear }
SchoolClass.delete_all
Person.delete_all

# Create a Dean
dean = Dean.create!(
  lastname: "Johnson",
  firstname: "Emily",
  email: "emily.johnson@example.com",
  phone_number: "5551234567",
  password: "password",
  password_confirmation: "password"
)

# Create Teachers
teacher1 = Teacher.create!(
  lastname: "Smith",
  firstname: "John",
  email: "john.smith@example.com",
  phone_number: "1234567890",
  iban: "GB29NWBK60161331926819",
  password: "password",
  password_confirmation: "password"
)

teacher2 = Teacher.create!(
  lastname: "Brown",
  firstname: "Mary",
  email: "mary.brown@example.com",
  phone_number: "9876543210",
  iban: "GB29NWBK60161331926820",
  password: "password",
  password_confirmation: "password"
)

# Create 10 Students
students = 10.times.map do |i|
  Student.create!(
    lastname: "Student#{i+1}",
    firstname: "First#{i+1}",
    email: "student#{i+1}@example.com",
    phone_number: "555#{format('%07d', i+1)}",
    status: :in_formation,
    password: "password",
    password_confirmation: "password"
  )
end

# Create 2 School Classes
class1 = SchoolClass.create!(
  name: "Mathematics 101",
  grade: 1,
  year: 2025,
  teacher: teacher1
)

class2 = SchoolClass.create!(
  name: "Physics 101",
  grade: 1,
  year: 2025,
  teacher: teacher2
)

# Assign 5 students to each class
class1.students << students[0..4]  # First 5 students
class2.students << students[5..9]  # Last 5 students

puts "Seed data created successfully!"
puts "Created:"
puts "- 1 Dean"
puts "- 2 Teachers"
puts "- 10 Students"
puts "- 2 Classes with 5 students each"
