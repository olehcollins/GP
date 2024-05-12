class ConsultationsController < ApplicationController
  before_action :set_consultation, only: [:show, :destroy]
  before_action :set_status, only: [:show]
  # skip_before_action :authenticate_user!, only: [:index, :show]


  def index
    @current_user_fn = "#{current_user.first_name.capitalize} #{current_user.last_name.capitalize}"
    @consultation = Consultation.new
    @appointment = Appointment.new
    @consultations = current_user.consultations
    @patient_appointments = []

    @consultations.each do |consultation|
      appointments = consultation.appointments
      appointments.each do |appointment|
        @patient_appointments << appointment
      end
    end

    @message_dr = ''
    @message_p = ''
    if @appointments
      @p_dr_appt = @appointments.select do |appt|
          appt.status == 'pending'
        end
      if @p_dr_appt.size != 0
        @message_dr = "You have #{@p_dr_appt.size} pending Patient Appointments!"
      end

      @p_patient_appt = Appointment.where(status: 'pending', user_id: current_user).count
      if @p_patient_appt != 0
        @message_p = "You have #{@p_patient_appt.size} pending Dr Appointments!"
      end
    end
  end

  def show
    @appointments = @consultation.appointments
    @appointment = Appointment.new
  end

  def new
    @consultation = Consultation.new
  end

  def create
    # raise
    @consultation = Consultation.new(consultation_params)
    @current_user_fn = "#{current_user.first_name.capitalize} #{current_user.last_name.capitalize}"
    @consultation.doctor = @current_user_fn
    @consultation.user = current_user
    if @consultation.save
      redirect_to consultation_path(@consultation), notice: "Consultaion was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # @consultation.photos.purge
    @consultation.destroy
    redirect_to consultations_path, notice: "Consultaion was successfully deleted."
  end

  private

  def set_status
    if user_signed_in?
      @patient_appointments = @consultation.appointments
      @dr_appointments = current_user.appointments
      if current_user == @consultation.user
        @doctor = true
        @patients = []
        @patient_appointments.each do |apt|
          patient = User.find(apt.user_id)
          full_name = "#{patient.first_name.capitalize} #{patient.last_name.capitalize}"
          email = patient.email
          date = apt.date
          @patients << {full_name: full_name, email: email, date: date, apt: apt}
        end
      else
        @doctor = false
        @doctors = []
        @dr_appointments.each do |apt|
          doctor = User.find(@consultation.user_id)
          full_name = "#{doctor.first_name.capitalize} #{doctor.last_name.capitalize}"
          email = doctor.email
          date = apt.date
          speciality = apt.consultation.speciality
          @doctors << {full_name: full_name, email: email, date: date, apt: apt, status: apt.status, speciality: speciality}
        end
      end
    end
  end

  def consultation_params
    params.require(:consultation).permit(:price_per_hour, :description, :doctor, :location,:speciality,:experience, photos: [])
  end

  def set_consultation
    @consultation = Consultation.find(params[:id])
  end
end
