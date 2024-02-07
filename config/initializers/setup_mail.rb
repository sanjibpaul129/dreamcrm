ActionMailer::Base.smtp_settings = {
  :port           => '25',
  :address        => 'smtp.postmarkapp.com',
  :user_name      => '015b79e4-e7e4-47a7-aa07-028d22c29ddc',
  :password       => '015b79e4-e7e4-47a7-aa07-028d22c29ddc',
  :domain         => 'dreamcrm.herokuapp.com',
  :authentication => :plain,
}
ActionMailer::Base.delivery_method = :smtp