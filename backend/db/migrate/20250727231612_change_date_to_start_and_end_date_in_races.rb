class ChangeDateToStartAndEndDateInRaces < ActiveRecord::Migration[7.1]
  def change
    remove_column :races, :date, :date
    add_column :races, :date_start, :date
    add_column :races, :date_end, :date
  end
end
