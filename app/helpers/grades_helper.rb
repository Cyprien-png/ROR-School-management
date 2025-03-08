module GradesHelper
  def can_grade?(examination)
    return false unless current_person.is_a?(Teacher) && examination&.lecture&.subject
    current_person.subjects.include?(examination.lecture.subject)
  end
end
