# Clean up existing data in the correct order
ActiveRecord::Base.connection.execute("DELETE FROM school_classes_students")
ActiveRecord::Base.connection.execute("DELETE FROM subjects_teachers")
SchoolClass.delete_all
Subject.delete_all
Person.with_deleted.delete_all  # Use with_deleted to ensure we clean up soft-deleted records too
Year.delete_all
Trimester.delete_all

# Create a Dean
dean = Dean.create!(
  lastname: "Johnson",
  firstname: "Emily",
  email: "emily.johnson@example.com",
  phone_number: "5551234567",
  password: "password",
  password_confirmation: "password"
)

# Create Academic Years
year_2024_2025 = Year.create!(
  first_trimester: Trimester.create!(start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31)),
  second_trimester: Trimester.create!(start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31)),
  third_trimester: Trimester.create!(start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30)),
  fourth_trimester: Trimester.create!(start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31))
)

year_2025_2026 = Year.create!(
  first_trimester: Trimester.create!(start_date: Date.new(2025,8,1), end_date: Date.new(2025,10,31)),
  second_trimester: Trimester.create!(start_date: Date.new(2025,11,1), end_date: Date.new(2026,1,31)),
  third_trimester: Trimester.create!(start_date: Date.new(2026,2,1), end_date: Date.new(2026,4,30)),
  fourth_trimester: Trimester.create!(start_date: Date.new(2026,5,1), end_date: Date.new(2026,7,31))
)

# Create Subjects
subjects = [
  Subject.create!(name: "Mathematics"),
  Subject.create!(name: "Physics"),
  Subject.create!(name: "Chemistry"),
  Subject.create!(name: "Biology"),
  Subject.create!(name: "Computer Science")
]

# Create Teachers with subjects
teacher1 = Teacher.create!(
  lastname: "Smith",
  firstname: "John",
  email: "john.smith@example.com",
  phone_number: "1234567890",
  iban: "GB29NWBK60161331926819",
  password: "password",
  password_confirmation: "password"
)
teacher1.subjects << subjects[0..1] # Mathematics and Physics

teacher2 = Teacher.create!(
  lastname: "Brown",
  firstname: "Mary",
  email: "mary.brown@example.com",
  phone_number: "9876543210",
  iban: "GB29NWBK60161331926820",
  password: "password",
  password_confirmation: "password"
)
teacher2.subjects << subjects[2..3] # Chemistry and Biology

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
  year: year_2024_2025,
  teacher: teacher1
)

class2 = SchoolClass.create!(
  name: "Physics 101",
  grade: 1,
  year: year_2025_2026,
  teacher: teacher2
)

# Assign 5 students to each class
class1.students << students[0..4]  # First 5 students
class2.students << students[5..9]  # Last 5 students

# Create lectures for each subject with their respective teachers
subjects.each_with_index do |subject, index|
  teacher = subject.teachers.first # Get the first teacher who teaches this subject
  next unless teacher # Skip if no teacher is assigned to this subject
  
  # Create 2 lectures per subject
  2.times do |i|
    Lecture.create!(
      start_time: "#{9 + i}:00",
      end_time: "#{10 + i}:30",
      week_day: i.even? ? :monday : :wednesday,
      subject: subject,
      teacher: teacher,
      trimesters: [year_2024_2025.first_trimester]
    )
  end
end

puts "Seed data created successfully!"
puts "Created:"
puts "- 1 Dean"
puts "- 2 Teachers"
puts "- 5 Subjects"
puts "- 10 Students"
puts "- 2 Academic Years (2024-2025 and 2025-2026)"
puts "- 2 Classes with 5 students each"
puts "- #{Lecture.count} Lectures"
