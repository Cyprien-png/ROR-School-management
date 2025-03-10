class StudentsController < PeopleController
  include Authorization
  include GradeReportsHelper
  
  before_action :authenticate_person!
  before_action :authorize_dean, only: [:new, :create, :edit, :update, :destroy]
  before_action :authorize_dean_or_self, only: [:grade_report]
  before_action :set_student, only: [:edit, :update, :destroy, :grade_report]

  def new
    @student = Student.new
    render 'students/new'
  end

  def create
    @student = Student.new(student_params.except(:school_class_id))
    
    respond_to do |format|
      if @student.save
        @student.school_classes << SchoolClass.find(student_params[:school_class_id]) if student_params[:school_class_id].present?
        format.html { redirect_to person_url(@student), notice: "Student was successfully created." }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    render 'students/edit'
  end

  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to person_url(@student), notice: "Student was successfully updated." }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @student.soft_delete
    respond_to do |format|
      format.html { redirect_to people_url, notice: "Student was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def grade_report
    # Get all classes and years for the student
    @available_years = @student.school_classes.includes(:year).map(&:year).uniq
    
    # If year_id is provided, use that year, otherwise use the latest year
    if params[:year_id].present?
      @year = @available_years.find { |y| y.id.to_s == params[:year_id] }
      @school_class = @student.school_classes.find_by(year: @year)
    else
      @school_class = @student.school_classes.last
      @year = @school_class&.year
    end
    
    if @school_class.nil?
      redirect_to people_url, alert: "Student is not assigned to any class."
      return
    end

    @semesters = group_trimesters_by_semester(@year)
    @semester = params[:semester]&.to_sym || :first_semester
    
    semester_trimesters = @semesters[@semester]
    @examinations = get_semester_examinations(@student, semester_trimesters)
    @subject_grades = get_subject_grades(@student, @examinations)
    @period_average = calculate_period_average(@subject_grades)
    @promoted = promoted?(@subject_grades)
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(
      :lastname, 
      :firstname, 
      :email, 
      :phone_number, 
      :password,
      :password_confirmation,
      :status,
      :school_class_id
    )
  end
  
  def authorize_dean_or_self
    return true if current_person.is_a?(Dean)
    
    # Allow students to view their own grade reports
    if current_person.is_a?(Student) && current_person.id.to_s == params[:id]
      return true
    end
    
    # Otherwise, deny access
    respond_to do |format|
      flash[:alert] = "You are not authorized to view this grade report."
      format.html { redirect_to root_path }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
    return false
  end
end 