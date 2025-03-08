# Clean up existing data in the correct order
ActiveRecord::Base.connection.disable_referential_integrity do
  ActiveRecord::Base.connection.execute("DELETE FROM school_classes_students")
  ActiveRecord::Base.connection.execute("DELETE FROM subjects_teachers")
  ActiveRecord::Base.connection.execute("DELETE FROM lectures_trimesters")
  Grade.unscoped.delete_all
  Examination.unscoped.delete_all
  SchoolClass.unscoped.delete_all
  Subject.unscoped.delete_all
  Lecture.unscoped.delete_all
  Person.unscoped.delete_all
  Year.unscoped.delete_all
  Trimester.unscoped.delete_all
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

# Create Academic Year
year_2024_2025 = Year.create!(
  first_trimester: Trimester.create!(start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31)),
  second_trimester: Trimester.create!(start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31)),
  third_trimester: Trimester.create!(start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30)),
  fourth_trimester: Trimester.create!(start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31))
)

# Create Subjects
subjects = [
  Subject.create!(name: "Mathematics"),
  Subject.create!(name: "Programming"),
  Subject.create!(name: "Database Systems"),
  Subject.create!(name: "Web Development"),
  Subject.create!(name: "Network Security"),
  Subject.create!(name: "Software Engineering"),
  Subject.create!(name: "Operating Systems"),
  Subject.create!(name: "Project Management")
]

# Create Teachers with subjects
teachers = [
  Teacher.create!(
    lastname: "Smith",
    firstname: "John",
    email: "john.smith@example.com",
    phone_number: "1234567890",
    iban: "CH9300762011623852957",
    password: "password",
    password_confirmation: "password"
  ),
  Teacher.create!(
    lastname: "Brown",
    firstname: "Mary",
    email: "mary.brown@example.com",
    phone_number: "9876543210",
    iban: "CH9300762011623852958",
    password: "password",
    password_confirmation: "password"
  ),
  Teacher.create!(
    lastname: "Garcia",
    firstname: "Carlos",
    email: "carlos.garcia@example.com",
    phone_number: "5559876543",
    iban: "CH9300762011623852959",
    password: "password",
    password_confirmation: "password"
  ),
  Teacher.create!(
    lastname: "Weber",
    firstname: "Sarah",
    email: "sarah.weber@example.com",
    phone_number: "5551234987",
    iban: "CH9300762011623852960",
    password: "password",
    password_confirmation: "password"
  )
]

# Assign subjects to teachers (2 subjects per teacher)
teachers[0].subjects << subjects[0..1]  # Mathematics and Programming
teachers[1].subjects << subjects[2..3]  # Database Systems and Web Development
teachers[2].subjects << subjects[4..5]  # Network Security and Software Engineering
teachers[3].subjects << subjects[6..7]  # Operating Systems and Project Management

# Create Students with realistic Swiss names
student_data = [
  # SI-T2a Students
  { lastname: "Müller", firstname: "Thomas" },
  { lastname: "Schmid", firstname: "Laura" },
  { lastname: "Keller", firstname: "Michael" },
  { lastname: "Weber", firstname: "Sophie" },
  { lastname: "Schneider", firstname: "David" },
  { lastname: "Fischer", firstname: "Emma" },
  { lastname: "Meyer", firstname: "Nicolas" },
  { lastname: "Brunner", firstname: "Julia" },
  { lastname: "Steiner", firstname: "Lucas" },
  { lastname: "Baumann", firstname: "Léa" },
  
  # SI-T2b Students
  { lastname: "Favre", firstname: "Marc" },
  { lastname: "Dubois", firstname: "Chloé" },
  { lastname: "Martin", firstname: "Antoine" },
  { lastname: "Rochat", firstname: "Emilie" },
  { lastname: "Blanc", firstname: "Simon" },
  { lastname: "Bonvin", firstname: "Marie" },
  { lastname: "Roux", firstname: "Alexandre" },
  { lastname: "Maillard", firstname: "Sarah" },
  { lastname: "Girard", firstname: "Luc" },
  { lastname: "Chevalier", firstname: "Julie" }
]

students = student_data.map.with_index do |data, index|
  Student.create!(
    lastname: data[:lastname],
    firstname: data[:firstname],
    email: "#{data[:firstname].downcase}.#{data[:lastname].downcase}@example.com",
    phone_number: "555#{format('%07d', index+1)}",
    status: :in_formation,
    password: "password",
    password_confirmation: "password"
  )
end

# Create School Classes
sit2a = SchoolClass.create!(
  name: "SI-T2a",
  grade: 2,
  year: year_2024_2025,
  teacher: teachers[0]  # John Smith is the main teacher
)

sit2b = SchoolClass.create!(
  name: "SI-T2b",
  grade: 2,
  year: year_2024_2025,
  teacher: teachers[1]  # Mary Brown is the main teacher
)

# Assign students to classes
sit2a.students << students[0..9]   # First 10 students
sit2b.students << students[10..19] # Last 10 students

# Create lectures for both classes
[sit2a, sit2b].each do |school_class|
  # Monday to Friday
  (0..4).each do |day_offset|
    # 4 time slots per day
    [
      ["08:30", "10:00"],
      ["10:20", "11:50"],
      ["13:15", "14:45"],
      ["15:05", "16:35"]
    ].each_with_index do |(start_time, end_time), time_slot|
      # Rotate through subjects based on day and time slot
      subject_index = (day_offset + time_slot) % subjects.length
      subject = subjects[subject_index]
      teacher = teachers.find { |t| t.subjects.include?(subject) }
      
      Lecture.create!(
        start_time: start_time,
        end_time: end_time,
        week_day: [:monday, :tuesday, :wednesday, :thursday, :friday][day_offset],
        subject: subject,
        teacher: teacher,
        school_class: school_class,
        trimesters: [year_2024_2025.first_trimester]  # Start with first trimester
      )
    end
  end
end

# Create examinations for each subject
subjects.each do |subject|
  Lecture.where(subject: subject).each do |lecture|
    # Find valid dates for this lecture in the first trimester
    trimester = year_2024_2025.first_trimester
    lecture_weekday = Date::DAYNAMES.map(&:downcase).index(lecture.week_day.to_s)
    
    # Find the first date that matches the lecture's weekday
    first_date = trimester.start_date
    while first_date.wday != lecture_weekday
      first_date += 1.day
    end
    
    # Create two examinations per lecture
    [
      { title: "#{subject.name} Mid-Term", weeks_offset: 6 },  # Mid-term around week 6
      { title: "#{subject.name} Final", weeks_offset: 11 }     # Final around week 11
    ].each do |exam_data|
      # Calculate examination date by adding weeks to the first valid date
      exam_date = first_date + exam_data[:weeks_offset].weeks
      
      # If the calculated date is after the trimester end, move back by weeks until it fits
      while exam_date > trimester.end_date
        exam_date -= 1.week
      end
      
      examination = Examination.create!(
        title: exam_data[:title],
        date: exam_date,
        lecture: lecture
      )
      
      # Create grades for most students (randomly skip some)
      lecture.school_class.students.each do |student|
        next if rand < 0.1 # Skip 10% of students randomly
        
        Grade.create!(
          value: rand(4.0..6.0).round(2),
          examination: examination,
          student: student,
          current_teacher: lecture.teacher
        )
      end
    end
  end
end

puts "Seed data created successfully!"
puts "Created:"
puts "- 1 Dean"
puts "- #{teachers.count} Teachers"
puts "- #{subjects.count} Subjects"
puts "- #{students.count} Students"
puts "- 2 Classes (SI-T2a and SI-T2b)"
puts "- #{Lecture.count} Lectures"
puts "- #{Examination.count} Examinations"
puts "- #{Grade.count} Grades"
