class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.text :message
      t.boolean :read, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
