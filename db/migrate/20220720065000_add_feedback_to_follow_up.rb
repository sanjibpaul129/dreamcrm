class AddFeedbackToFollowUp < ActiveRecord::Migration[5.2]
  def change
    add_column :follow_ups, :feedback, :boolean
  end
end
