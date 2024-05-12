class CreateConsultations < ActiveRecord::Migration[7.1]
  def change
    create_table :consultations do |t|
      t.integer :deal, default: 0
      t.string :doctor
      t.integer :experience
      t.string :location
      t.string :speciality
      t.float :price_per_hour
      t.text :description
      t.references :user, foreign_key: true


      t.timestamps
    end
  end
end
