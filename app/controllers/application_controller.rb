class ApplicationController < ActionController::Base
  def check_table!
    return unless current_table.blank?

    set_redirect
    redirect_to set_table_path
  end

  def current_table
    session[:table]
  end

  def set_redirect
    session[:redirect] = request.path
  end

  def get_and_clear_redirect
    session.delete(:redirect)
  end
end
