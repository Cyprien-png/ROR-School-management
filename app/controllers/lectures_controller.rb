class LecturesController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, except: [:index, :show]
  before_action :set_lecture, only: %i[ show edit update destroy ]
  before_action :set_deleted_lecture, only: [:undelete]

  def deleted
    @lectures = Lecture.with_deleted.where(isDeleted: true)
    Rails.logger.info "Deleted lectures query: #{@lectures.to_sql}"
    Rails.logger.info "Found #{@lectures.count} deleted lectures"
    Rails.logger.info "Deleted lectures IDs: #{@lectures.pluck(:id)}"
  end

  def undelete
    @lecture.update(isDeleted: false)
    redirect_to lectures_path, notice: "Lecture was successfully restored."
  end

  # GET /lectures or /lectures.json
  def index
    # Get all years for the filter
    @years = Year.all.order('first_trimester_id DESC')
    
    # Default to the current year if available, otherwise use the most recent year
    @selected_year = if params[:year_id].present?
      Year.find_by(id: params[:year_id]) || @years.first
    else
      @years.first
    end
    
    # Get all trimesters for the selected year
    if @selected_year
      @trimesters = [
        @selected_year.first_trimester,
        @selected_year.second_trimester,
        @selected_year.third_trimester,
        @selected_year.fourth_trimester
      ]
      
      # Find current trimester based on today's date
      today = Date.today
      current_trimester = @trimesters.find { |t| t.start_date <= today && t.end_date >= today }
      
      # Default to the current trimester if available, otherwise use the first trimester
      @selected_trimester = if params[:trimester_id].present?
        Trimester.find_by(id: params[:trimester_id]) || current_trimester || @trimesters.first
      else
        current_trimester || @trimesters.first
      end
      
      # Get all lectures, then filter by trimester if selected
      @lectures = Lecture.all.order(:week_day, :start_time)
      
      if @selected_trimester
        @lectures = @lectures.joins(:trimesters).where(trimesters: { id: @selected_trimester.id })
      end
    else
      @trimesters = []
      @lectures = Lecture.all.order(:week_day, :start_time)
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
    Rails.logger.info "Before soft delete: Lecture #{@lecture.id} isDeleted=#{@lecture.isDeleted}"
    result = @lecture.soft_delete
    Rails.logger.info "After soft delete: Lecture #{@lecture.id} isDeleted=#{@lecture.reload.isDeleted}, update result: #{result}"

    respond_to do |format|
      format.html { redirect_to lectures_url, notice: "Lecture was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lecture
      @lecture = Lecture.find(params[:id])
    end

    def set_deleted_lecture
      @lecture = Lecture.with_deleted.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lecture_params
      params.require(:lecture).permit(:start_time, :end_time, :week_day, :subject_id, :teacher_id, :school_class_id, trimester_ids: [])
    end
end
