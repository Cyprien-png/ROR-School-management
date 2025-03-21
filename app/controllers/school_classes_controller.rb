class SchoolClassesController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, except: [:index, :show]
  before_action :set_school_class, only: %i[ show edit update destroy add_student remove_student ]
  before_action :set_deleted_school_class, only: [:undelete]

  def deleted
    @school_classes = SchoolClass.with_deleted.where(isDeleted: true)
    Rails.logger.info "Deleted school classes query: #{@school_classes.to_sql}"
    Rails.logger.info "Found #{@school_classes.count} deleted school classes"
    Rails.logger.info "Deleted school classes IDs: #{@school_classes.pluck(:id)}"
    render :deleted
  end

  def undelete
    @school_class.update(isDeleted: false)
    redirect_to school_classes_path, notice: "School class was successfully restored."
  end

  # POST /school_classes/1/add_student
  def add_student
    student = Student.find(params[:student_id])
    
    # Check if student is already in a class with the same academic year
    if student.school_classes.where(year_id: @school_class.year_id).exists?
      year = @school_class.year
      year_range = "#{year.first_trimester.start_date.year}-#{year.fourth_trimester.end_date.year}"
      redirect_to @school_class, alert: "Student is already assigned to a class in the academic year #{year_range}"
      return
    end
    
    @school_class.students << student
    redirect_to @school_class, notice: "Student was successfully added to the class."
  end

  # DELETE /school_classes/1/remove_student
  def remove_student
    student = Student.find(params[:student_id])
    @school_class.students.delete(student)
    redirect_to @school_class, notice: "Student was successfully removed from the class."
  end

  # GET /school_classes or /school_classes.json
  def index
    @school_classes = SchoolClass.all
  end

  # GET /school_classes/1 or /school_classes/1.json
  def show
  end

  # GET /school_classes/new
  def new
    @school_class = SchoolClass.new
  end

  # GET /school_classes/1/edit
  def edit
  end

  # POST /school_classes or /school_classes.json
  def create
    @school_class = SchoolClass.new(school_class_params)

    respond_to do |format|
      if @school_class.save
        format.html { redirect_to school_class_url(@school_class), notice: "School class was successfully created." }
        format.json { render :show, status: :created, location: @school_class }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @school_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /school_classes/1 or /school_classes/1.json
  def update
    respond_to do |format|
      if @school_class.update(school_class_params)
        format.html { redirect_to school_class_url(@school_class), notice: "School class was successfully updated." }
        format.json { render :show, status: :ok, location: @school_class }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @school_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /school_classes/1 or /school_classes/1.json
  def destroy
    Rails.logger.info "Before soft delete: SchoolClass #{@school_class.id} isDeleted=#{@school_class.isDeleted}"
    result = @school_class.soft_delete
    Rails.logger.info "After soft delete: SchoolClass #{@school_class.id} isDeleted=#{@school_class.reload.isDeleted}, update result: #{result}"

    respond_to do |format|
      format.html { redirect_to school_classes_url, notice: "School class was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def year_trimesters
    @school_class = SchoolClass.find(params[:id])
    year = @school_class.year
    trimesters = [
      year.first_trimester,
      year.second_trimester,
      year.third_trimester,
      year.fourth_trimester
    ]
    
    render json: trimesters.map { |t| { id: t.id, start_date: t.start_date, end_date: t.end_date } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school_class
      @school_class = SchoolClass.find(params[:id])
    end

    def set_deleted_school_class
      @school_class = SchoolClass.with_deleted.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def school_class_params
      params.require(:school_class).permit(:name, :grade, :year_id, :teacher_id)
    end
end
