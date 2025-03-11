class GradesController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_grade_manager, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_grade, only: %i[ show edit update destroy ]
  before_action :authorize_grade_modification, only: [:edit, :update, :destroy]
  before_action :authorize_access_to_grade, only: [:show]
  before_action :load_available_examinations, only: [:new, :create, :edit, :update]

  # GET /grades or /grades.json
  def index
    @grades = if current_person.is_a?(Student)
      Grade.includes(:student, examination: { lecture: [:subject, :school_class, :teacher] })
          .where(student: current_person)
    elsif current_person.is_a?(Teacher)
      Grade.includes(:student, examination: { lecture: [:subject, :school_class, :teacher] })
          .joins(examination: { lecture: :subject })
          .joins("INNER JOIN subjects_teachers ON subjects_teachers.subject_id = subjects.id")
          .where(subjects_teachers: { teacher_id: current_person.id })
    else
      Grade.includes(:student, examination: { lecture: [:subject, :school_class, :teacher] }).all
    end
  end

  # GET /grades/1 or /grades/1.json
  def show
  end

  # GET /grades/new
  def new
    @grade = Grade.new
    @grade.examination_id = params[:examination_id] if params[:examination_id].present?
  end

  # GET /grades/1/edit
  def edit
    # Show all examinations for deans, only subject-specific ones for teachers
    @available_examinations = if current_person.is_a?(Dean)
      Examination.includes(lecture: [:subject, :school_class]).all
    elsif current_person.is_a?(Teacher)
      Examination.includes(lecture: [:subject, :school_class])
                .joins(lecture: :subject)
                .joins("INNER JOIN subjects_teachers ON subjects_teachers.subject_id = subjects.id")
                .where(subjects_teachers: { teacher_id: current_person.id })
    else
      []
    end
  end

  # POST /grades or /grades.json
  def create
    @grade = Grade.new(grade_params)
    @grade.current_teacher = current_person
    
    unless can_modify_grade?(@grade)
      respond_to do |format|
        format.html { redirect_to grades_url, alert: unauthorized_message }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
      return
    end

    respond_to do |format|
      if @grade.save
        format.html { redirect_to grade_url(@grade), notice: "Grade was successfully created." }
        format.json { render :show, status: :created, location: @grade }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grades/1 or /grades/1.json
  def update
    @grade.current_teacher = current_person
    
    respond_to do |format|
      if @grade.update(grade_params)
        format.html { redirect_to grade_url(@grade), notice: "Grade was successfully updated." }
        format.json { render :show, status: :ok, location: @grade }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grades/1 or /grades/1.json
  def destroy
    @grade.current_teacher = current_person
    @grade.soft_delete

    respond_to do |format|
      format.html { redirect_to grades_url, notice: "Grade was successfully archived." }
      format.json { head :no_content }
    end
  end

  private
    def set_grade
      @grade = Grade.includes(:student, examination: { lecture: [:subject, :school_class, :teacher] }).find(params[:id])
    end

    def grade_params
      params.require(:grade).permit(:value, :examination_id, :student_id)
    end

    def authorize_grade_manager
      unless current_person.is_a?(Dean) || current_person.is_a?(Teacher)
        redirect_to root_path, alert: "Only deans and teachers can manage grades."
      end
    end

    def authorize_grade_modification
      unless can_modify_grade?(@grade)
        redirect_to grades_url, alert: unauthorized_message
      end
    end

    def can_modify_grade?(grade)
      return true if current_person.is_a?(Dean)
      return false unless current_person.is_a?(Teacher) && grade.examination&.lecture&.subject
      current_person.subjects.include?(grade.examination.lecture.subject)
    end

    def authorize_access_to_grade
      unless can_access_grade?(@grade)
        redirect_to grades_url, alert: "You are not authorized to view this grade."
      end
    end

    def can_access_grade?(grade)
      return true if current_person.is_a?(Dean)
      return grade.student_id == current_person.id if current_person.is_a?(Student)
      return can_modify_grade?(grade) if current_person.is_a?(Teacher)
      false
    end

    def unauthorized_message
      if current_person.is_a?(Teacher)
        "You can only manage grades for subjects you teach."
      else
        "You are not authorized to perform this action."
      end
    end

    def load_available_examinations
      @examinations = if current_person.is_a?(Dean)
        Examination.includes(lecture: [:subject, :school_class]).all
      elsif current_person.is_a?(Teacher)
        Examination.includes(lecture: [:subject, :school_class])
                  .joins(lecture: :subject)
                  .joins("INNER JOIN subjects_teachers ON subjects_teachers.subject_id = subjects.id")
                  .where(subjects_teachers: { teacher_id: current_person.id })
      else
        []
      end
    end
end
