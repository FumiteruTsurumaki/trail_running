class ChangeDistanceInRaces < ActiveRecord::Migration[7.1]
  def change
    rename_column :races, :distance_km, :distance
    change_column :races, :distance, :string
  end
end