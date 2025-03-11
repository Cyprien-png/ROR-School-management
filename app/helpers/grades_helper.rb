module GradesHelper
  def can_grade?(examination)
    return true if current_person.is_a?(Dean)
    return false unless current_person.is_a?(Teacher) && examination&.lecture&.subject
    current_person.subjects.include?(examination.lecture.subject)
  end

  def can_manage_grades?
    current_person.is_a?(Dean) || current_person.is_a?(Teacher)
  end
end
