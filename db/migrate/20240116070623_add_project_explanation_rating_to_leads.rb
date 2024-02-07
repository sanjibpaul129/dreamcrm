class AddProjectExplanationRatingToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :project_explanation_rating, :integer
  end
end
