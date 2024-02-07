class WhatsappImage < ApplicationRecord
belongs_to :whatsapp_template

# has_attached_file :image, 
#                   :storage => :s3, 
#                   :bucket => ENV['S3_BUCKET_NAME'], 
#                   :s3_region => ENV['AWS_REGION'], 
#                   :path => "whatsapp_images/:id", 
#                   :url => ":s3_domain_url"
                  
# validates_attachment_presence :image
# validates_attachment_size :image, :in => 0.megabytes..10.megabytes
# do_not_validate_attachment_file_type :image

end
