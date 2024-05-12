class HomeController < ApplicationController

  def home
    if user_signed_in?
      notifications = current_user.notifications.count
      flash[:notice] = "You have #{notifications} new messages " if notifications > 0
    end
  end

  def index
    @all_consultations = Consultation.all
  end

  private
end
