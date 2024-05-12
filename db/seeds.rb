# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

8.times do |i|
  consultation = Consultation.new()
  consultation.user_id = 1
  dr = User.find(1)
  dr_fn = "#{dr.first_name.capitalize} #{dr.last_name.capitalize}"
  consultation.doctor = dr_fn
  # consultation.deal = 10
  consultation.price_per_hour = 30
  consultation.location = 'london'
  consultation.experience = 5
  consultation.speciality = 'dentist'
  consultation.description = 'Transform your smile at our state-of-the-art dentist clinic! Our expert team offers comprehensive dental care, from routine cleanings to advanced treatments. Experience personalized care in a comfortable environment. Book your appointment today!'
  if consultation.save
    puts "create' #{i} 'consultation"
  else
    return 'error'
  end
end
