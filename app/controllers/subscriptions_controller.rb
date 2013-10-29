class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    @subscriptions = Subscription.all
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    subscription = Subscription.find(params[:id])

    @subscription = SubscriptionsHelper.fetch(subscription)
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    subscription = Subscription.new

    if params[:participant_id]
      @participant = Participant.find(params[:participant_id])
      subscription.participant = @participant
    end

    if params[:partnership_id]
      @partnership = Partnership.find(params[:partnership_id])
      subscription.partnership = @partnership
    end

    #subscription = @participant.subscriptions.create()

    sport = Sport.new
    sport.reference = params[:sport_id]
    sport.name = params[:sport_id]
    sport.is_proxy = true

    subscription.public_visible = 2
    subscription.sport = sport

    subscription.save
    @subscription = subscription
    #respond_to do |format|
    #if @subscription.save
    #  format.html { redirect_to @subscription, notice: 'Subscription was successfully created.' }
    #  format.json { render action: 'show', status: :created, location: @subscription }
    #else
    #  format.html { render action: 'new' }
    #  format.json { render json: @subscription.errors, status: :unprocessable_entity }
    #end
    #end
  end

  # PATCH/PUT /subscriptions/1
  # PATCH/PUT /subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to @subscription, notice: 'Subscription was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to subscriptions_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscription_params
    params.require(:subscription).permit(:sport_id)
  end
end
