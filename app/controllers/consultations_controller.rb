class ConsultationsController < ApplicationController
  before_action :set_consultation, only: [:show, :destroy]
  before_action :set_status, only: [:show]
  before_action :send_message
  # skip_before_action :authenticate_user!, only: [:index, :show]


  def index
    @current_user_fn = "#{current_user.first_name.capitalize} #{current_user.last_name.capitalize}"
    @consultation = Consultation.new
    @appointment = Appointment.new
    @consultations = current_user.consultations
    patient_appointments = []

    @consultations.each do |consultation|
      appointments = consultation.appointments
      appointments.each do |appointment|
        patient_appointments << appointment
      end
    end

    @message_dr = ''
    @message_p = ''
    send_message()
    if @appointments
      @p_dr_appt = @appointments.select do |appt|
          appt.status == 'pending'
        end
      if @p_dr_appt.size > 0
        @message_dr = "You have #{@p_dr_appt.size} pending Patient Appointments!"
      else
        @message_dr = "You have no pending Patient Appointments"
      end

      @p_patient_appt = Appointment.where(status: 'pending', user_id: current_user).count
      if @p_patient_appt > 0
        @message_p = "You have #{@p_patient_appt.size} pending Dr Appointments!"
      else
        @message_p = "You have no pending Dr Appointments"
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

  def consultation_params
    params.require(:consultation).permit(:price_per_hour, :description, :doctor, :location,:speciality,:experience, photos: [])
  end

  def set_consultation
    @consultation = Consultation.find(params[:id])
  end

  def get_all_patients
    all_patients_apptms = []
    current_user.consultations.each do |consultation|
      appointments = consultation.appointments
      appointments.each do |appointment|
        all_patients_apptms << appointment
      end
    end
    all_patients_apptms
  end

  def send_message
    patient_appointments = get_all_patients
    message_to_dr = ''
    message_to_patient = ''
    if patient_appointments
      pending_p_aptms = patient_appointments.select { |aptm|  aptm.status == 'pending'}.size
      if pending_p_aptms > 0
        message_to_dr = "You have #{pending_p_aptms} patients to see"
      else
        message_to_dr = "You have no patients to see"
      end
    end
    pending_dr_aptms = Appointment.where(status: 'pending', user_id: current_user).count
    if pending_dr_aptms > 0
      message_to_patient = "You have #{pending_dr_aptms} pending Dr Appointments!"
    else
      message_to_patient = "You have no pending Dr Appointments"
    end
    @note_for_doctor = message_to_dr
    @note_for_patient = message_to_patient
  end

  def get_my_doctors
    doctor = false
    dr_appointments = current_user.appointments
    get_appointment_details(dr_appointments, doctor)
  end

  def get_my_patients
    doctor = true
    patient_appointments = get_all_patients
    get_appointment_details(patient_appointments, doctor)
  end

  def set_status
    if user_signed_in?
      get_my_doctors
      get_my_patients
    end
  end



  def get_appointment_details(appointments, doctor)
    array = []
    appointments.each do |aptm|
      date = aptm.date
      location = aptm.location
      speciality = aptm.consultation.speciality
      if doctor
        patient = User.find(aptm.user_id)
        full_name = "#{patient.first_name.capitalize} #{patient.last_name.capitalize}"
        person = patient
        email = patient.email
        photo = patient.profile_photo.key
      else
        doctor = User.find(@consultation.user_id)
        full_name = "Dr #{doctor.first_name.capitalize} #{doctor.last_name.capitalize}"
        person = doctor
        email = doctor.email
        photo = doctor.profile_photo.key
      end

      array << {full_name: full_name, email: email, date: date, apt: aptm, photo: photo, status: aptm.status, location: location, speciality: speciality, person:person }
    end
    array
  end
end
