require 'pry'
class ApplicationController < ActionController::API
    include ActionController::Cookies
    before_action :check_session

    def check_session
        
    end
end
