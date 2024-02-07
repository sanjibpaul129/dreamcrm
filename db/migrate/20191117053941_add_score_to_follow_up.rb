class AddScoreToFollowUp < ActiveRecord::Migration[5.2]
  def change
    add_column :follow_ups, :score, :integer
  end
end
