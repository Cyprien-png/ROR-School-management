module GradeReportsHelper
  def group_trimesters_by_semester(year)
    {
      first_semester: [year.first_trimester, year.second_trimester],
      second_semester: [year.third_trimester, year.fourth_trimester]
    }
  end

  def get_semester_examinations(student, semester_trimesters)
    start_date = semester_trimesters.map(&:start_date).min
    end_date = semester_trimesters.map(&:end_date).max

    Examination.includes(:lecture, :grades)
              .joins(lecture: [:subject, :trimesters])
              .where(trimesters: { id: semester_trimesters.map(&:id) })
              .where(lectures: { school_class_id: student.school_classes.pluck(:id) })
              .where(date: start_date..end_date)
              .order(:date)
  end

  def get_subject_grades(student, examinations)
    grades_by_subject = {}
    
    examinations.each do |exam|
      subject = exam.lecture.subject
      grades_by_subject[subject] ||= { 
        grades: [], 
        examinations: [],
        total: 0,
        count: 0
      }
      
      grades_by_subject[subject][:examinations] << exam
      grade = exam.grades.find_by(student: student)
      
      if grade&.value
        grades_by_subject[subject][:grades] << grade.value
        grades_by_subject[subject][:total] += grade.value
        grades_by_subject[subject][:count] += 1
      else
        grades_by_subject[subject][:grades] << nil
      end
    end
    
    grades_by_subject
  end

  def calculate_subject_average(grades)
    return nil if grades.empty? || grades.all?(&:nil?)
    valid_grades = grades.compact
    (valid_grades.sum / valid_grades.size).round(2)
  end

  def calculate_period_average(subject_grades)
    # Get all subject averages (only for subjects that have at least one grade)
    subject_averages = []
    
    subject_grades.each do |subject, data|
      next if data[:grades].empty? || data[:grades].all?(&:nil?)
      avg = calculate_subject_average(data[:grades])
      subject_averages << avg if avg
    end
    
    # Return nil if no valid averages
    return nil if subject_averages.empty?
    
    # Calculate the average of all subject averages
    (subject_averages.sum / subject_averages.size).round(2)
  end

  def promoted?(subject_grades)
    return false if subject_grades.empty?
    
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
    status = if promoted
      "Student is promoted to the next semester."
    else
      "Student is not promoted due to insufficient grades (average below 4.00 in one or more subjects)."
    end
    
    if @period_average
      "#{status} Overall average: #{number_with_precision(@period_average, precision: 2)}"
    else
      status
    end
  end
end 