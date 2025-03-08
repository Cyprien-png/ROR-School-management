class GradesController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_teacher, except: [:index, :show]
  before_action :set_grade, only: %i[ show edit update destroy ]
  before_action :authorize_teacher_for_grade, only: [:edit, :update, :destroy]

  # GET /grades or /grades.json
  def index
    @grades = Grade.includes(:student, examination: { lecture: [:subject, :school_class, :teacher] }).all
  end

  # GET /grades/1 or /grades/1.json
  def show
  end

  # GET /grades/new
  def new
    @grade = Grade.new
    # Only show examinations for subjects the teacher teaches
    @available_examinations = if current_person.is_a?(Teacher)
      Examination.includes(lecture: [:subject, :school_class])
                .joins(lecture: :subject)
                .joins("INNER JOIN subjects_teachers ON subjects_teachers.subject_id = subjects.id")
                .where(subjects_teachers: { teacher_id: current_person.id })
    else
      []
    end
  end

  # GET /grades/1/edit
  def edit
    # Only show examinations for subjects the teacher teaches
    @available_examinations = if current_person.is_a?(Teacher)
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
    
    unless teacher_can_grade?(@grade.examination)
      respond_to do |format|
        format.html { redirect_to grades_url, alert: "You can only create grades for subjects you teach." }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
      return
    end

    respond_to do |format|
      if @grade.save
        format.html { redirect_to grade_url(@grade), notice: "Grade was successfully created." }
        format.json { render :show, status: :created, location: @grade }
      else
        # Reload available examinations on validation error
        @available_examinations = Examination.includes(lecture: [:subject, :school_class])
                                          .joins(lecture: :subject)
                                          .joins("INNER JOIN subjects_teachers ON subjects_teachers.subject_id = subjects.id")
                                          .where(subjects_teachers: { teacher_id: current_person.id })
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
        # Reload available examinations on validation error
        @available_examinations = Examination.includes(lecture: [:subject, :school_class])
                                          .joins(lecture: :subject)
                                          .joins("INNER JOIN subjects_teachers ON subjects_teachers.subject_id = subjects.id")
                                          .where(subjects_teachers: { teacher_id: current_person.id })
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
    # Use callbacks to share common setup or constraints between actions.
    def set_grade
      @grade = Grade.includes(:student, examination: { lecture: [:subject, :school_class, :teacher] }).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grade_params
      params.require(:grade).permit(:value, :examination_id, :student_id)
    end

    def authorize_teacher
      unless current_person.is_a?(Teacher)
        redirect_to root_path, alert: "Only teachers can manage grades."
      end
    end

    def authorize_teacher_for_grade
      unless teacher_can_grade?(@grade.examination)
        redirect_to grades_url, alert: "You can only manage grades for subjects you teach."
      end
    end

    def teacher_can_grade?(examination)
      return false unless current_person.is_a?(Teacher) && examination&.lecture&.subject
      current_person.subjects.include?(examination.lecture.subject)
    end
end
