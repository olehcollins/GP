class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.string :status, default: 'pending'
      t.string :location
      t.string :patient
      t.string :doctor
      t.date :date
      t.references :consultation, foreign_key: true
      t.references :user, foreign_key: true


      t.timestamps
    end
  end
end
