module SessionsHelper

    def sign_in(user)
      remember_token = User.new_remember_token
      cookies.permanent[:remember_token] = remember_token
      user.remember_token = User.encrypt(remember_token)
      user.save
     self.current_user = user
    end

    def current_user=(user)
      @current_user = user
    end

    def current_user?(user)
      @current_user == user
    end

    def current_user
      remember_token = User.encrypt(cookies[:remember_token])
      @current_user ||= User.find_by(remember_token: remember_token)
     end

    def signed_in?
      !self.current_user.nil?
    end

    def sign_out
      self.current_user = nil
      cookies.delete(:remember_token)
    end

    def redirect_back_or(default)
      redirect_to(session[:return_to] || default)
      session.delete(:return_to)
    end

    def store_location
      session[:return_to] = request.url if request.get?
    end

    def cy_ber_coach_signed_in?
      uri = URI.parse("http://diufvm31.unifr.ch:8090/")

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new("/CyberCoachServer/resources/users/messi")
      request["Accept"] = "application/json"

      response = http.request(request)

       if response.code == '200'
         true
       else
         false
       end
    end
end
