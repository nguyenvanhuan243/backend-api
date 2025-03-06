class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  def sign_in
    email = params["email"]
    password = params["password"]
    puts "##### #{email}"
    puts "##### #{password}"

    unless email.present?
      return render json: {
        message: "Your email is missing",
      }, status: :bad_request # 400 status code
    end

    unless password.present?
      return render json: {
        message: "Your password is missing",
      }, status: :bad_request # 400 status code
    end

    user = User.find_by(email: email)

    unless Digest::MD5.hexdigest(params[:password]) == user.password
      return render json: {
        message: "Your password is not correct",
      }, status: :bad_request # 400 status code
    end

    payload = {
      user_id: user.id,
      created_at: user.created_at,
      expired_time: Time.now + 120.minutes
    }

    render json: {
      access_token: 'Bearer ' + Authenticate.issue(payload)
    }, status: 200
  end

  # api/create-new-user
  def create_user
    email    = params['email']
    password = params['password']

    unless email.present?
      return render json: {
        message: "Your email is missing",
      }, status: :bad_request # 400 status code
    end

    unless password.present?
      return render json: {
        message: "Your password is missing",
      }, status: :bad_request # 400 status code
    end

    password = Digest::MD5.hexdigest(params[:password])

    user = User.create(
      email: email,
      password: password
    )

    unless user.id.present?
      return render json: {
        message: user.errors.full_messages,
      }, status: :unprocessable_entity
    end

    render json: {
      message: "Created user successfully",
      user: {
        user_id: user.id,
        email: user.email
      }
    }, status: :created
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :password)
    end
end
