class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :message
      t.references :user, foreign_key: true
      t.string :recipient


      t.timestamps
    end
  end
end
