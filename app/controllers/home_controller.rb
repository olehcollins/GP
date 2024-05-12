class HomeController < ApplicationController
  def index
    @all_consultations = Consultation.all
    render notice: 'testing 1 2 3'
  end
end
