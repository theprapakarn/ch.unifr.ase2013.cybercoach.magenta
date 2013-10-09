class BidsController < ApplicationController
  before_action :signed_in_user, only: [:show, :index, :new, :edit, :update]
  before_action :correct_user, only: [:edit, :update]
  before_action :set_bid, only: [:show, :edit, :update, :destroy]

  # GET /bids
  # GET /bids.json
  def index
    @bids = Bid.all
  end

  # GET /bids/1
  # GET /bids/1.json
  def show
  end

  # GET /bids/new
  def new
    @bid = Bid.new
  end

  # GET /bids/1/edit
  def edit
  end

  # POST /bids
  # POST /bids.json
  def create
    @car = Car.find(params[:car_id])
    @bid = @car.bids.create(bid_params)
    @bid.user = current_user

    respond_to do |format|
      if @car.save
        format.html { redirect_to cars_path notice: 'Car was successfully created.'}
        format.json { head :no_content }
      else
        format.html { render action: 'new' }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bids/1
  # PATCH/PUT /bids/1.json
  def update
    respond_to do |format|
      if @bid.update(bid_params)
        format.html { redirect_to @bid, notice: 'Bid was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bid.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bids/1
  # DELETE /bids/1.json
  def destroy
    @car = Car.find(params[:car_id])
    @bid = @car.bids.find(params[:id])
    @bid.destroy

    respond_to do |format|
      format.html { redirect_to cars_url }
      format.json { head :no_content }
    end
  end

  def create_modal
    @car = Car.find(params[:car_id])
    @bids = @car.bids
    @bid = @car.bids.create(bid_params)
    @bid.user = current_user
      if @bid.save
        @errors = @bid.errors
        respond_to :js
      else
        @bids.reload()
        @errors = @bid.errors
        respond_to :js
      end
  end

  def modal
    @car = Car.find(params[:car_id])
    @bids = @car.bids
    respond_to :js
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_bid
    @bid = Bid.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bid_params
    params.require(:bid).permit(:price)
  end

  def signed_in_user
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def correct_user
    @bid = Bid.find(params[:id])
    redirect_to(root_url) unless current_user?(@bid.user)
  end

end
