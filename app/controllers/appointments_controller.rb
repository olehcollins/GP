class AppointmentsController < ApplicationController
  require 'json'
  before_action :set_consultation, only: [:new, :create]
  before_action :set_appointment, only: [:approve, :destroy, ]

  def inbox
    set_messages
  end

  def index
    if params[:format] == 'patients'
      @doctor = true
      patient_appointments = []
      consultations = Consultation.where(user_id: current_user.id)
      consultations.each do |cons|
        cons.appointments.each do |aptm|
          patient_appointments << aptm
        end
      end
      @appt_arr = set_appointment_details(patient_appointments)
    else
      @doctor = false
      dr_appointments = Appointment.where(user_id: current_user.id)
      @appt_arr = set_appointment_details(dr_appointments)
    end

  end



  def cancel
    appointment = Appointment.find(params[:appointment_id])
    patient =  appointment.patient
    appointment.status = "#{patient} is requesting to cancel their appointment"
    redirect_to dr_appointments_path('doctors')
  end

  def approve
    @appointment.status = 'approved'
    if @appointment.save
      redirect_to consultations_path, notice: "Appointment was successfully updated."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @appointment = Appointment.new
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.consultation = @consultation
    @appointment.user_id = current_user.id
    patient_name = "#{current_user.first_name.capitalize} #{current_user.last_name.capitalize}"
    @appointment.patient = patient_name
    doctor = User.find(@consultation.user_id)
    doctor_fullname = "Dr #{doctor.first_name.capitalize} #{doctor.last_name.capitalize}"
    @appointment.doctor = doctor_fullname
    @appointment.location = @consultation.location
    date = @appointment.date
    speciality = @consultation.speciality
    location = @appointment.location
    sender_photo = current_user.profile_photo.key

    notification_data = {
      user: doctor,
      message: {
        sender_id: current_user.id,
        appointment_id: @appointment.id,
        consultation_id: @consultation.id,
        sender_name: patient_name,
        recipient: doctor_fullname,
        location: location,
        speciality: speciality,
        date: date,
        sender_photo: sender_photo,
        content: "#{patient_name} is requesting an appointment on the #{date}, at #{location} for #{speciality}"
      }
    }

    if @appointment.save
      send_request(notification_data, @consultation)
    else
      raise
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.destroy
    redirect_to consultations_path, notice: "Appointment was successfully deleted."
  end

  private

  def set_appointment_details(appointments)
    appt_arr = []
    appointments.each do |aptm|
      status = aptm.status
      date = aptm.date
      location = aptm.location
      consultation = aptm.consultation
      speciality = aptm.consultation.speciality

      if @doctor
        patient = User.find(aptm.user_id)
        full_name = "#{patient.first_name.capitalize} #{patient.last_name.capitalize}"
        email = patient.email
        photo = patient.profile_photo.key
      else
        dr = User.find(aptm.consultation.user_id)
        full_name = "Dr #{dr.first_name.capitalize} #{dr.last_name.capitalize}"
        photo = dr.profile_photo.key
        email = dr.email
      end

      appt_arr << {full_name: full_name, status: status, email: email, date: date, location: location, photo: photo, aptm: aptm, speciality: speciality, consultation: consultation}
    end
    @appt_arr = appt_arr
  end

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:date)
  end

  def set_consultation
    @consultation = Consultation.find(params[:consultation_id])
  end

  def send_request(data, instance_path)
    json_data = data.to_json
    notification = Notification.new(message: json_data, user: data[:user])
    if notification.save
      redirect_to consultation_path(instance_path), notice: "Appointment was successfully requested."
    else
      raise
    end
  end

  def set_messages
    @messages = []
    if user_signed_in?
      notifications = current_user.notifications
      if notifications
        notifications.each do |noti|
          message =  JSON.parse(noti.message)
          @messages << message["message"]
        end
      end
    end
    @messages
  end
  # def doctor_response
  #   data = {
  #     user: current_user,
  #     message: {
  #       content: "your request has been declined"
  #     }
  #   }
  #   test = Notification.new(data)
  #   if user_signed_in?
  #     message = eval(test.message)
  #     flash[:notice] = message[:content]
  #     # raise
  #   end
  # end
end
