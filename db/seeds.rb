# Clean up existing data in the correct order
ActiveRecord::Base.connection.disable_referential_integrity do
  ActiveRecord::Base.connection.execute("DELETE FROM school_classes_students")
  ActiveRecord::Base.connection.execute("DELETE FROM subjects_teachers")
  ActiveRecord::Base.connection.execute("DELETE FROM lectures_trimesters")
  Examination.delete_all
  SchoolClass.delete_all
  Subject.delete_all
  Lecture.delete_all
  Person.with_deleted.delete_all  # Use with_deleted to ensure we clean up soft-deleted records too
  Year.delete_all
  Trimester.delete_all
end

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

# Create School Classes
class1 = SchoolClass.create!(
  name: "Class A",
  grade: 1,
  year: year_2024_2025,
  teacher: teacher1
)

class2 = SchoolClass.create!(
  name: "Class B",
  grade: 1,
  year: year_2025_2026,
  teacher: teacher2
)

# Assign 5 students to each class
class1.students << students[0..4]  # First 5 students
class2.students << students[5..9]  # Last 5 students

# Create lectures with mixed class assignments
[
  # Class A follows both Math (from their teacher) and Chemistry (from another teacher)
  { 
    class: class1, 
    year: year_2024_2025,
    lectures: [
      { teacher: teacher1, subjects: subjects[0..0] },  # Math from teacher1
      { teacher: teacher2, subjects: subjects[2..2] }   # Chemistry from teacher2
    ]
  },
  # Class B follows both Biology (from their teacher) and Physics (from another teacher)
  { 
    class: class2,
    year: year_2025_2026,
    lectures: [
      { teacher: teacher2, subjects: subjects[3..3] },  # Biology from teacher2
      { teacher: teacher1, subjects: subjects[1..1] }   # Physics from teacher1
    ]
  }
].each do |config|
  config[:lectures].each do |lecture_config|
    lecture_config[:subjects].each do |subject|
      # Create 2 lectures per subject
      2.times do |i|
        Lecture.create!(
          start_time: "#{9 + i}:00",
          end_time: "#{10 + i}:30",
          week_day: i.even? ? :monday : :wednesday,
          subject: subject,
          teacher: lecture_config[:teacher],
          school_class: config[:class],
          trimesters: [config[:year].first_trimester]  # Use the correct year's trimester
        )
      end
    end
  end
end

# Create examinations for each subject in different trimesters
subjects.each_with_index do |subject, index|
  # Get all lectures for this subject
  subject_lectures = Lecture.includes(:subject, :school_class)
                          .where(subject: subject)
                          .order(:week_day, :start_time)
  
  next if subject_lectures.empty?
  
  # Mid-trimester examination
  Examination.create!(
    title: "#{subject.name} Mid-Trimester Exam",
    date: year_2024_2025.first_trimester.start_date + 1.month,
    lecture: subject_lectures.first
  )
  
  # End of trimester examination
  Examination.create!(
    title: "#{subject.name} Final Exam",
    date: year_2024_2025.first_trimester.end_date - 1.week,
    lecture: subject_lectures.last
  )
  
  # Special examination for some subjects in the second trimester
  if index < 3 # Only for Mathematics, Physics, and Chemistry
    Examination.create!(
      title: "#{subject.name} Advanced Topics",
      date: year_2024_2025.second_trimester.start_date + 6.weeks,
      lecture: subject_lectures.first
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
puts "- #{Examination.count} Examinations"
