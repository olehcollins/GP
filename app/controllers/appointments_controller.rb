class AppointmentsController < ApplicationController
  before_action :set_consultation, only: [:new, :create]
  before_action :set_request, except: [:index, :new, :destroy]
  # before_action :set_status, only: [:index]


  def index
    @appt_arr = []
    if params[:format] == 'patients'
      consultations = Consultation.where(user_id: current_user.id)
      consultations.each do |cons|
        appointments = cons.appointments
        appointments.each do |apt|
          full_name = apt.patient
          status = apt.status
          email = User.find(apt.user_id).email
          date = apt.date
          location = apt.location
          photo = User.find(apt.user_id).profile_photo.key
          @appt_arr << {full_name: full_name, status: status, email: email, date: date, location: location, photo: photo, doctor: true, aptm: apt}
        end
      end
    else
      @dr_app = Appointment.where(user_id: current_user.id)
      @appt_arr = @dr_app.map do |apt|
        dr = User.find(apt.consultation.user_id)
        full_name = "#{dr.first_name.capitalize} #{dr.last_name.capitalize}"
        status = apt.status
        email = current_user.email
        date = apt.date
        location = apt.location
        photo = dr.profile_photo.key
        consultation = apt.consultation
        @pt_apt = {full_name: full_name, status: status, email: email, date: date, location: location, photo: photo, consultation:consultation, doctor: false, aptm: apt}
      end
    end
  end

  def cancel
    appointment = Appointment.find(params[:appointment_id])
    patient =  appointment.patient
    appointment.status = "#{patient} is requesting to cancel their appointment"
    redirect_to dr_appointments_path('doctors')
  end

  def approve
    if @appointment.status == 'pending'
      @appointment.status = 'approved'

    else
      @appointment.status = 'pending'
    end

    if @appointment.save
      redirect_to consultations_path, notice: "Appointment was successfully update."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def deny
    @appointment.status = 'denied'
    if @appointment.status == 'denied'
      if @appointment.destroy
        render notice: 'you appointment was cancelled'
      end
    end
  end


  def new
    @appointment = Appointment.new
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.consultation = @consultation
    @appointment.user_id = current_user.id
    patient = "#{current_user.first_name.capitalize} #{current_user.last_name.capitalize}"
    @appointment.patient = patient
    doctor = User.find(@consultation.user_id)
    doctor_fullname = "#{doctor.first_name.capitalize} #{doctor.last_name.capitalize}"
    @appointment.doctor = doctor_fullname
    @appointment.request = "#{patient} is requesting an appointment"
    @appointment.location = @consultation.location

    if @appointment.save
      redirect_to consultation_path(@consultation), notice: "Appointment was successfully created."
    else
      raise
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    doctor = User.find(@appointment.consultation.user_id)
    if doctor != current_user
      doctor.notifications << "#{@appointment.patient} has cancelled their appointment schedule for the #{@appointment.date}"
    else
      patient.notifications << "#{@appointment.doctor} has cancelled your appointment schedule for the #{@appointment.date}"
    end
    @appointment.destroy
    redirect_to consultations_path, notice: "Appointment was successfully deleted."
  end

  private


  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:date)
  end

  def set_consultation
    @consultation = Consultation.find(params[:consultation_id])
  end

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
end
