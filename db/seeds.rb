# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

puts "Cleaning database..."
# Clean up in the correct order to avoid foreign key constraints
ActiveRecord::Base.connection.disable_referential_integrity do
  Grade.delete_all
  Examination.delete_all
  Lecture.delete_all
  SchoolClass.delete_all
  Year.delete_all
  Trimester.delete_all
  Subject.delete_all
  Person.delete_all
end

puts "Creating dean..."
dean = Dean.create!(
  firstname: "John",
  lastname: "Smith",
  email: "dean@school.com",
  phone_number: "1234567890",
  password: "password",
  password_confirmation: "password"
)

puts "Creating teachers..."
math_teacher = Teacher.create!(
  firstname: "Robert",
  lastname: "Johnson",
  email: "robert.johnson@school.com",
  phone_number: "2345678901",
  iban: "CH93 0076 2011 6238 5295 7",
  password: "password",
  password_confirmation: "password"
)

physics_teacher = Teacher.create!(
  firstname: "Marie",
  lastname: "Curie",
  email: "marie.curie@school.com",
  phone_number: "3456789012",
  iban: "CH93 0076 2011 6238 5295 8",
  password: "password",
  password_confirmation: "password"
)

biology_teacher = Teacher.create!(
  firstname: "Charles",
  lastname: "Darwin",
  email: "charles.darwin@school.com",
  phone_number: "4567890123",
  iban: "CH93 0076 2011 6238 5295 9",
  password: "password",
  password_confirmation: "password"
)

history_teacher = Teacher.create!(
  firstname: "Howard",
  lastname: "Zinn",
  email: "howard.zinn@school.com",
  phone_number: "5678901234",
  iban: "CH93 0076 2011 6238 5296 0",
  password: "password",
  password_confirmation: "password"
)

english_teacher = Teacher.create!(
  firstname: "Jane",
  lastname: "Austen",
  email: "jane.austen@school.com",
  phone_number: "6789012345",
  iban: "CH93 0076 2011 6238 5296 1",
  password: "password",
  password_confirmation: "password"
)

puts "Creating subjects..."
math = Subject.create!(name: "Mathematics", teachers: [math_teacher])
physics = Subject.create!(name: "Physics", teachers: [physics_teacher])
biology = Subject.create!(name: "Biology", teachers: [biology_teacher])
history = Subject.create!(name: "History", teachers: [history_teacher])
english = Subject.create!(name: "English", teachers: [english_teacher])

# Create a teacher who teaches multiple subjects
science_teacher = Teacher.create!(
  firstname: "Albert",
  lastname: "Einstein",
  email: "albert.einstein@school.com",
  phone_number: "7890123456",
  iban: "CH93 0076 2011 6238 5296 2",
  password: "password",
  password_confirmation: "password"
)

# Add the science teacher to math and physics
math.teachers << science_teacher
physics.teachers << science_teacher

puts "Creating academic years and trimesters..."

# Helper method to create a year with trimesters
def create_academic_year(start_year)
  # First trimester: September to December
  first_trimester = Trimester.create!(
    start_date: Date.new(start_year, 9, 1),
    end_date: Date.new(start_year, 12, 20)
  )
  
  # Second trimester: January to March
  second_trimester = Trimester.create!(
    start_date: Date.new(start_year + 1, 1, 10),
    end_date: Date.new(start_year + 1, 3, 31)
  )
  
  # Third trimester: April to June
  third_trimester = Trimester.create!(
    start_date: Date.new(start_year + 1, 4, 10),
    end_date: Date.new(start_year + 1, 6, 30)
  )
  
  # Fourth trimester: July to August (summer school/special programs)
  fourth_trimester = Trimester.create!(
    start_date: Date.new(start_year + 1, 7, 1),
    end_date: Date.new(start_year + 1, 8, 20)
  )
  
  Year.create!(
    first_trimester: first_trimester,
    second_trimester: second_trimester,
    third_trimester: third_trimester,
    fourth_trimester: fourth_trimester
  )
end

# Create three academic years: 2022-2023, 2023-2024, 2024-2025
year_2022_2023 = create_academic_year(2022)
year_2023_2024 = create_academic_year(2023)
year_2024_2025 = create_academic_year(2024)

puts "Creating students..."
# Regular students who will progress normally
students = []
20.times do |i|
  students << Student.create!(
    firstname: Faker::Name.first_name,
    lastname: Faker::Name.last_name,
    email: "student#{i+1}@school.com",
    phone_number: Faker::PhoneNumber.phone_number,
    status: :in_formation,
    password: "password",
    password_confirmation: "password"
  )
end

# Create a student who will fail and repeat a grade
failing_student = Student.create!(
  firstname: "Alex",
  lastname: "Smith",
  email: "alex.smith@school.com",
  phone_number: "9876543210",
  status: :in_formation,
  password: "password",
  password_confirmation: "password"
)

puts "Creating school classes..."

# 2022-2023 Academic Year
class_10a_2022 = SchoolClass.create!(
  name: "10A",
  grade: 10,
  teacher: math_teacher,
  year: year_2022_2023
)

class_10b_2022 = SchoolClass.create!(
  name: "10B",
  grade: 10,
  teacher: physics_teacher,
  year: year_2022_2023
)

class_11a_2022 = SchoolClass.create!(
  name: "11A",
  grade: 11,
  teacher: biology_teacher,
  year: year_2022_2023
)

class_11b_2022 = SchoolClass.create!(
  name: "11B",
  grade: 11,
  teacher: history_teacher,
  year: year_2022_2023
)

# 2023-2024 Academic Year
class_10a_2023 = SchoolClass.create!(
  name: "10A",
  grade: 10,
  teacher: english_teacher,
  year: year_2023_2024
)

class_10b_2023 = SchoolClass.create!(
  name: "10B",
  grade: 10,
  teacher: science_teacher,
  year: year_2023_2024
)

class_11a_2023 = SchoolClass.create!(
  name: "11A",
  grade: 11,
  teacher: math_teacher,
  year: year_2023_2024
)

class_11b_2023 = SchoolClass.create!(
  name: "11B",
  grade: 11,
  teacher: physics_teacher,
  year: year_2023_2024
)

# 2024-2025 Academic Year
class_10a_2024 = SchoolClass.create!(
  name: "10A",
  grade: 10,
  teacher: biology_teacher,
  year: year_2024_2025
)

class_11a_2024 = SchoolClass.create!(
  name: "11A",
  grade: 11,
  teacher: history_teacher,
  year: year_2024_2025
)

class_12a_2024 = SchoolClass.create!(
  name: "12A",
  grade: 12,
  teacher: english_teacher,
  year: year_2024_2025
)

puts "Assigning students to classes..."

# Assign first 10 students to 10A in 2022, then 11A in 2023, then 12A in 2024 (normal progression)
students[0..9].each do |student|
  class_10a_2022.students << student
  class_11a_2023.students << student
  class_12a_2024.students << student
end

# Assign next 10 students to 10B in 2022, then 11B in 2023, then 12A in 2024 (merging classes in final year)
students[10..19].each do |student|
  class_10b_2022.students << student
  class_11b_2023.students << student
  class_12a_2024.students << student
end

# Assign failing student to 10A in 2022, then 10A again in 2023 (repeating), then 11A in 2024
class_10a_2022.students << failing_student
class_10a_2023.students << failing_student
class_11a_2024.students << failing_student

puts "Creating lectures..."

# Helper method to create lectures for a class
def create_lectures(school_class, subjects, year)
  lectures = []
  
  # Days of the week
  days = ["monday", "tuesday", "wednesday", "thursday", "friday"]
  
  # Create lectures for each subject
  subjects.each_with_index do |subject, index|
    # Determine which trimesters this lecture spans
    trimesters = []
    case index % 3
    when 0 # Spans all trimesters
      trimesters = [year.first_trimester, year.second_trimester, year.third_trimester]
    when 1 # Spans first and second trimesters
      trimesters = [year.first_trimester, year.second_trimester]
    when 2 # Only in third trimester
      trimesters = [year.third_trimester]
    end
    
    # Create the lecture
    lecture = Lecture.create!(
      subject: subject,
      teacher: subject.teachers.first,
      school_class: school_class,
      week_day: days[index % 5],
      start_time: Time.parse("#{8 + index}:00"),
      end_time: Time.parse("#{9 + index}:00"),
      trimesters: trimesters
    )
    
    lectures << lecture
  end
  
  lectures
end

# Create lectures for each class
puts "Creating lectures for 2022-2023 academic year..."
lectures_10a_2022 = create_lectures(class_10a_2022, [math, physics, biology, history, english], year_2022_2023)
lectures_10b_2022 = create_lectures(class_10b_2022, [math, physics, biology, history, english], year_2022_2023)
lectures_11a_2022 = create_lectures(class_11a_2022, [math, physics, biology, history, english], year_2022_2023)
lectures_11b_2022 = create_lectures(class_11b_2022, [math, physics, biology, history, english], year_2022_2023)

puts "Creating lectures for 2023-2024 academic year..."
lectures_10a_2023 = create_lectures(class_10a_2023, [math, physics, biology, history, english], year_2023_2024)
lectures_10b_2023 = create_lectures(class_10b_2023, [math, physics, biology, history, english], year_2023_2024)
lectures_11a_2023 = create_lectures(class_11a_2023, [math, physics, biology, history, english], year_2023_2024)
lectures_11b_2023 = create_lectures(class_11b_2023, [math, physics, biology, history, english], year_2023_2024)

puts "Creating lectures for 2024-2025 academic year..."
lectures_10a_2024 = create_lectures(class_10a_2024, [math, physics, biology, history, english], year_2024_2025)
lectures_11a_2024 = create_lectures(class_11a_2024, [math, physics, biology, history, english], year_2024_2025)
lectures_12a_2024 = create_lectures(class_12a_2024, [math, physics, biology, history, english], year_2024_2025)

puts "Creating examinations..."

# Math examination titles
math_exam_titles = [
  "Algebra Fundamentals", 
  "Vectors and Matrices", 
  "Calculus Basics", 
  "Trigonometry", 
  "Probability and Statistics"
]

# Physics examination titles
physics_exam_titles = [
  "Mechanics and Motion", 
  "Electricity and Magnetism", 
  "Waves and Optics", 
  "Thermodynamics", 
  "Quantum Physics Intro"
]

# Biology examination titles
biology_exam_titles = [
  "Cell Structure and Function", 
  "Genetics and Heredity", 
  "Evolution and Natural Selection", 
  "Human Anatomy", 
  "Ecology and Ecosystems"
]

# History examination titles
history_exam_titles = [
  "Ancient Civilizations", 
  "Medieval Europe", 
  "Renaissance and Reformation", 
  "World Wars", 
  "Modern Global Politics"
]

# English examination titles
english_exam_titles = [
  "Grammar and Composition", 
  "Literature Analysis", 
  "Creative Writing", 
  "Public Speaking", 
  "Research Methods"
]

# Helper method to create examinations for a lecture
def create_examinations(lecture, titles, year)
  examinations = []
  
  # Create 3-4 examinations per lecture, distributed across trimesters
  num_exams = rand(3..4)
  
  lecture.trimesters.each_with_index do |trimester, index|
    # Skip some trimesters randomly to have variation
    next if rand < 0.2 && index > 0
    
    # Find a valid date for the examination (matching the lecture's weekday)
    lecture_wday = Date::DAYNAMES.map(&:downcase).index(lecture.week_day)
    valid_dates = []
    
    current_date = trimester.start_date
    while current_date <= trimester.end_date
      if current_date.wday == lecture_wday
        valid_dates << current_date
      end
      current_date += 1.day
    end
    
    # Create 1-2 examinations per trimester
    num_trimester_exams = [1, 2].sample
    num_trimester_exams.times do |i|
      # Select a random date from valid dates
      exam_date = valid_dates.sample
      
      # Select a title - ensure we always have a title even if we run out of unique ones
      if titles.empty?
        # If we've used all titles, create a new one with a sequence number
        title = "#{lecture.subject.name} Exam #{i+1}"
      else
        title = titles.sample
        titles.delete(title) # Remove to avoid duplicates
      end
      
      # Create the examination
      examination = Examination.create!(
        title: title,
        date: exam_date,
        lecture: lecture
      )
      
      examinations << examination
    end
  end
  
  examinations
end

# Create examinations for each lecture
puts "Creating examinations for 2022-2023 academic year..."
all_lectures_2022 = lectures_10a_2022 + lectures_10b_2022 + lectures_11a_2022 + lectures_11b_2022

all_lectures_2022.each do |lecture|
  case lecture.subject.name
  when "Mathematics"
    create_examinations(lecture, math_exam_titles.dup, year_2022_2023)
  when "Physics"
    create_examinations(lecture, physics_exam_titles.dup, year_2022_2023)
  when "Biology"
    create_examinations(lecture, biology_exam_titles.dup, year_2022_2023)
  when "History"
    create_examinations(lecture, history_exam_titles.dup, year_2022_2023)
  when "English"
    create_examinations(lecture, english_exam_titles.dup, year_2022_2023)
  end
end

puts "Creating examinations for 2023-2024 academic year..."
all_lectures_2023 = lectures_10a_2023 + lectures_10b_2023 + lectures_11a_2023 + lectures_11b_2023

all_lectures_2023.each do |lecture|
  case lecture.subject.name
  when "Mathematics"
    create_examinations(lecture, math_exam_titles.dup, year_2023_2024)
  when "Physics"
    create_examinations(lecture, physics_exam_titles.dup, year_2023_2024)
  when "Biology"
    create_examinations(lecture, biology_exam_titles.dup, year_2023_2024)
  when "History"
    create_examinations(lecture, history_exam_titles.dup, year_2023_2024)
  when "English"
    create_examinations(lecture, english_exam_titles.dup, year_2023_2024)
  end
end

puts "Creating examinations for 2024-2025 academic year..."
all_lectures_2024 = lectures_10a_2024 + lectures_11a_2024 + lectures_12a_2024

all_lectures_2024.each do |lecture|
  case lecture.subject.name
  when "Mathematics"
    create_examinations(lecture, math_exam_titles.dup, year_2024_2025)
  when "Physics"
    create_examinations(lecture, physics_exam_titles.dup, year_2024_2025)
  when "Biology"
    create_examinations(lecture, biology_exam_titles.dup, year_2024_2025)
  when "History"
    create_examinations(lecture, history_exam_titles.dup, year_2024_2025)
  when "English"
    create_examinations(lecture, english_exam_titles.dup, year_2024_2025)
  end
end

puts "Creating grades..."

# Helper method to create grades for a student in a class
def create_grades_for_student(student, school_class, performance_level)
  # Get all examinations for this class
  examinations = Examination.joins(lecture: :school_class)
                           .where(lectures: { school_class_id: school_class.id })
  
  examinations.each do |examination|
    # Determine grade based on performance level
    case performance_level
    when :excellent
      grade_value = rand(5.5..6.0).round(2)
    when :good
      grade_value = rand(4.5..5.4).round(2)
    when :average
      grade_value = rand(4.0..4.4).round(2)
    when :poor
      grade_value = rand(3.5..3.9).round(2)
    when :failing
      grade_value = rand(1.0..3.4).round(2)
    end
    
    # Create the grade
    Grade.create!(
      value: grade_value,
      examination: examination,
      student: student,
      current_teacher: examination.lecture.teacher
    )
  end
end

# Create grades for regular students (improving over time)
puts "Creating grades for regular students..."
students[0..9].each do |student|
  # Grade 10 - Average to good performance
  create_grades_for_student(student, class_10a_2022, [:average, :good].sample)
  
  # Grade 11 - Good to excellent performance (improvement)
  create_grades_for_student(student, class_11a_2023, [:good, :excellent].sample)
  
  # Grade 12 - Excellent performance (further improvement)
  create_grades_for_student(student, class_12a_2024, :excellent)
end

students[10..19].each do |student|
  # Grade 10 - Average to good performance
  create_grades_for_student(student, class_10b_2022, [:average, :good].sample)
  
  # Grade 11 - Good to excellent performance (improvement)
  create_grades_for_student(student, class_11b_2023, [:good, :excellent].sample)
  
  # Grade 12 - Excellent performance (further improvement)
  create_grades_for_student(student, class_12a_2024, :excellent)
end

# Create grades for the failing student
puts "Creating grades for the failing student..."
# Grade 10 (2022-2023) - Failing performance
create_grades_for_student(failing_student, class_10a_2022, :failing)

# Grade 10 (2023-2024) - Repeating, improved to average performance
create_grades_for_student(failing_student, class_10a_2023, :average)

# Grade 11 (2024-2025) - Continued to good performance
create_grades_for_student(failing_student, class_11a_2024, :good)

puts "Seed completed successfully!"
