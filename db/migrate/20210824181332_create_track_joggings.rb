class CreateTrackJoggings < ActiveRecord::Migration[6.1]
  def change
    create_table :jogging_events do |t|
      t.belongs_to :user
      t.datetime :date
      t.integer :time
      t.string :location
      t.integer :distance
      t.text :weather_condition

      t.timestamps
    end
  end
end
