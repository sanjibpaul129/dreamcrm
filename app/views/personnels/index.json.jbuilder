json.array!(@personnels) do |personnel|
  json.extract! personnel, :id, :email, :name, :passwordhash, :passwordsalt, :auth_token, :password_reset_token, :password_reset_sent_at, :mobile
  json.url personnel_url(personnel, format: :json)
end
