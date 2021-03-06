class SessionsController < ApplicationController
  def new
  end

  def set_table
    session[:table] = params[:table]

    redirect_path = get_and_clear_redirect || root_path
    redirect_to redirect_path
  end
end
