class CreateRaces < ActiveRecord::Migration[7.1]
  def change
    create_table :races do |t|
      t.string :name
      t.date :date
      t.string :location
      t.float :distance_km
      t.integer :elevation_gain_m
      t.string :entry_url
      t.string :official_url
      t.text :description
      t.boolean :beginner_friendly
      t.integer :status
      t.string :scraped_from_url
      t.datetime :scraped_at

      t.timestamps
    end
  end
end
