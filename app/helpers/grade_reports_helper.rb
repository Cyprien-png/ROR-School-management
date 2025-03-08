module GradeReportsHelper
  def group_trimesters_by_semester(year)
    {
      first_semester: [year.first_trimester, year.second_trimester],
      second_semester: [year.third_trimester, year.fourth_trimester]
    }
  end

  def get_semester_examinations(student, semester_trimesters)
    Examination.includes(:lecture, :grades)
              .joins(lecture: [:subject, :trimesters])
              .where(trimesters: { id: semester_trimesters.map(&:id) })
              .where(lectures: { school_class_id: student.school_classes.pluck(:id) })
              .order(:date)
  end

  def get_subject_grades(student, examinations)
    grades_by_subject = {}
    
    examinations.each do |exam|
      subject = exam.lecture.subject
      grades_by_subject[subject] ||= { grades: [], examinations: [] }
      grades_by_subject[subject][:examinations] << exam
      
      grade = exam.grades.find_by(student: student)
      grades_by_subject[subject][:grades] << (grade&.value || nil)
    end
    
    grades_by_subject
  end

  def calculate_subject_average(grades)
    return nil if grades.empty? || grades.all?(&:nil?)
    valid_grades = grades.compact
    (valid_grades.sum / valid_grades.size).round(2)
  end

  def promoted?(subject_grades)
    subject_grades.values.all? do |data|
      average = calculate_subject_average(data[:grades])
      average.nil? || average >= 4.00
    end
  end

  def format_grade(grade)
    grade.nil? ? "//" : number_with_precision(grade, precision: 2)
  end

  def promotion_status_color(promoted)
    promoted ? "text-black" : "text-red-600"
  end

  def promotion_status_message(promoted)
    if promoted
      "Student is promoted to the next semester."
    else
      "Student is not promoted due to insufficient grades (average below 4.00 in one or more subjects)."
    end
  end
end 