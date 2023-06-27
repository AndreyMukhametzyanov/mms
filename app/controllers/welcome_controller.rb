class WelcomeController < ApplicationController
  def index
  end

  def check
    render json: { status: :ok }
  end
end
