json.array!(@leads) do |lead|
  json.extract! lead, :id, :business_unit_id, :personnels_id, :budget, :status, :personnel_remarks, :name, :email, :lost_reason_id, :address, :occupation_id, :requirement, :area, :mobile, :preferred_location_id, :marketing_instance_id, :source_category_id, :customer_remarks, :newspaper_id, :channel_id, :station_id, :magazine_id, :community_id, :nationality_id, :pan, :dob, :company, :designation, :first_applicant, :second_applicant
  json.url lead_url(lead, format: :json)
end
