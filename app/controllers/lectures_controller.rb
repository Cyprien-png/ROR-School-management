class LecturesController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, except: [:index, :show]
  before_action :set_lecture, only: [:show, :edit, :update, :destroy]

  # GET /lectures or /lectures.json
  def index
    # Get all years for filtering
    @years = Year.where(isDeleted: false).order(created_at: :desc)
    
    # Default to the current year or the most recent year
    @selected_year = if params[:year_id].present?
      @years.find { |y| y.id.to_s == params[:year_id] }
    else
      @years.first
    end
    
    # Get trimesters for the selected year
    @trimesters = if @selected_year
      [@selected_year.first_trimester, @selected_year.second_trimester, 
       @selected_year.third_trimester, @selected_year.fourth_trimester].compact
    else
      []
    end
    
    # Default to the current trimester or the first trimester of the year
    @selected_trimester = if params[:trimester_id].present?
      @trimesters.find { |t| t.id.to_s == params[:trimester_id] }
    else
      # Find current trimester based on date
      current_date = Date.today
      current_trimester = @trimesters.find { |t| t.start_date <= current_date && t.end_date >= current_date }
      current_trimester || @trimesters.first
    end
    
    # Get all lectures
    @lectures = Lecture.all.order(:week_day, :start_time)
    
    # Filter lectures by trimester if selected
    if @selected_trimester
      @lectures = @lectures.joins(:trimesters).where(trimesters: { id: @selected_trimester.id })
    end
  end

  # GET /lectures/1 or /lectures/1.json
  def show
  end

  # GET /lectures/new
  def new
    @lecture = Lecture.new
  end

  # GET /lectures/1/edit
  def edit
  end

  # POST /lectures or /lectures.json
  def create
    @lecture = Lecture.new(lecture_params)

    respond_to do |format|
      if @lecture.save
        format.html { redirect_to lecture_url(@lecture), notice: "Lecture was successfully created." }
        format.json { render :show, status: :created, location: @lecture }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lecture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lectures/1 or /lectures/1.json
  def update
    respond_to do |format|
      if @lecture.update(lecture_params)
        format.html { redirect_to lecture_url(@lecture), notice: "Lecture was successfully updated." }
        format.json { render :show, status: :ok, location: @lecture }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lecture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lectures/1 or /lectures/1.json
  def destroy
    @lecture.destroy!

    respond_to do |format|
      format.html { redirect_to lectures_url, notice: "Lecture was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lecture
      @lecture = Lecture.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lecture_params
      params.require(:lecture).permit(:start_time, :end_time, :week_day, :subject_id, :teacher_id, :school_class_id, trimester_ids: [])
    end
end
