class CarsController < ApplicationController
  before_action :signed_in_user, only: [:show, :index, :new, :edit, :update]
  before_action :correct_user, only: [:edit, :update]
  # GET /cars
  # GET /cars.json
  def index
    @cars = Car.all
  end

  # GET /cars/1
  # GET /cars/1.json
  def show
    @car = Car.find(params[:id])
  end

  # GET /cars/new
  def new
    @car = Car.new
    @car.user = current_user
  end

  # GET /cars/1/edit
  def edit
    @car = Car.find(params[:id])
    @car.user = current_user
  end

  # POST /cars
  # POST /cars.json
  def create
    @car = current_user.cars.build(car_params)

    respond_to do |format|
      if @car.save
        format.html { redirect_to cars_path notice: 'Car was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render action: 'new' }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cars/1
  # PATCH/PUT /cars/1.json
  def update
    @car = Car.find(params[:id])

    respond_to do |format|
      if @car.update(car_params)
        format.html { redirect_to cars_path notice: 'Car was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render redirect_to cars_path }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  def destroy
    @car = Car.find(params[:id])
    @car.destroy
    respond_to do |format|
      format.html { redirect_to cars_url }
      format.json { head :no_content }
    end
  end

  def create_modal
    @car = Car.new(car_params)
    @car.user = current_user
    if @car.save
      @errors = @car.errors
      respond_to :js
    else
      @errors = @car.errors
      respond_to :js
    end
  end

  def update_modal
    @car = Car.find(params[:id])
    @car.user = current_user
    if @car.update(car_params)
      @errors = @car.errors
      respond_to :js
    else
      @errors = @car.errors
      respond_to :js
    end
  end

  def new_modal
    @car = Car.new()
    respond_to :js
  end

  def edit_modal
    @car = Car.find(params[:id])
    respond_to :js
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_car
    @car = Car.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def car_params
    params.require(:car).permit(:model, :brand)
  end

  def signed_in_user
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def correct_user
    @car = Car.find(params[:id])
    redirect_to(root_url) unless current_user?(@car.user)
  end
end
