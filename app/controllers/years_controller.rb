class YearsController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, except: [:index, :show]
  before_action :set_year, only: %i[ show edit update destroy ]

  # GET /years or /years.json
  def index
    @years = Year.all
  end

  # GET /years/1 or /years/1.json
  def show
  end

  # GET /years/new
  def new
    @year = Year.new
    @year.build_first_trimester
    @year.build_second_trimester
    @year.build_third_trimester
    @year.build_fourth_trimester
  end

  # GET /years/1/edit
  def edit
  end

  # POST /years or /years.json
  def create
    @year = Year.new(year_params)

    respond_to do |format|
      if @year.save
        format.html { redirect_to year_url(@year), notice: "Year was successfully created." }
        format.json { render :show, status: :created, location: @year }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @year.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /years/1 or /years/1.json
  def update
    respond_to do |format|
      if @year.update(year_params)
        format.html { redirect_to year_url(@year), notice: "Year was successfully updated." }
        format.json { render :show, status: :ok, location: @year }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @year.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /years/1 or /years/1.json
  def destroy
    @year.update!(isDeleted: true)

    respond_to do |format|
      format.html { redirect_to years_url, notice: "Year was successfully archived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_year
      @year = Year.unscoped.find_by!(id: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def year_params
      params.require(:year).permit(
        first_trimester_attributes: [:id, :start_date, :end_date],
        second_trimester_attributes: [:id, :start_date, :end_date],
        third_trimester_attributes: [:id, :start_date, :end_date],
        fourth_trimester_attributes: [:id, :start_date, :end_date]
      )
    end
end
