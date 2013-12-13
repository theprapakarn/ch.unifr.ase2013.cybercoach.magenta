class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def register
    @user = User.new(username: params[:username], email: params[:email],
                     password: params[:password], password_confirmation: params[:confirmpassword])
    @user.save

    participant = Participant.where('user_id = ?', "#{@user.id}").first

    if participant != nil
      participant.user = @user
      participant.public_visible = "2"
      participant.first_name = params[:firstname]
      participant.last_name = params[:lastname]
      participant.birth_date = params[:birthdate]
      participant.gender = params[:gender]
      participant.save()
    end
    @user.email_password =  params[:emailpassword]
    @user.save

    sign_in(@user)
    redirect_to root_url
  end

  def isuserexist
    @user = User.where('LOWER(username) = ?', "#{params[:username].downcase}").first
    if (@user)
      render status: 401
      render status: :forbidden
    else
      if(User.is_exist_cy_ber_coach(params[:username]) == false)
        render nothing: true, status: 200
     else
       render status: 401
       render status: :forbidden
     end
    end
  end

  def isemailexist
    @user = User.where('LOWER(email) = ?', "#{params[:email].downcase}").first
    if (@user)
      render status: 500
      render status: :forbidden
    else
      render nothing: true, status: 200
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def edit
    @user = User.find(params[:id])
  end

  def update
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def new_modal
    @user = User.new()
    respond_to :js
  end


  def create_modal
    @user = User.new(car_params)

    if @user.save
      @errors = @user.errors
      @success = "Saved"
      respond_to :js
    else
      @errors = @user.errors
      respond_to :js
    end
  end

  def edit_modal
    @user = User.find(params[:id])
    respond_to :js
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params_2
    params.permit(:username, :email, :password, :password_confirmation)
  end
end
