# # frozen_string_literal: true

# class Ckeditor::Picture < Ckeditor::Asset
#   has_attached_file :data,
#                     url: '/ckeditor_assets/pictures/:id/:style_:basename.:extension',
#                     path: ':rails_root/public/ckeditor_assets/pictures/:id/:style_:basename.:extension',
#                     styles: { content: '800>', thumb: '118x100#' }

#   # has_attached_file :data, 
#   #                   :path => "pictures/:id", 
#   #                   :url => ":s3_domain_url"
   

#   # has_attached_file :data, 
#   #                   :storage => :s3, 
#   #                   :bucket => ENV['S3_BUCKET_NAME'], 
#   #                   :s3_region => ENV['AWS_REGION'], 
#   #                   :path => "pictures/:id", 
#   #                   :url => ":s3_domain_url", 
#   #                   styles: { content: '800>', thumb: '118x100#' }
                    

#   validates_attachment_presence :data
#   validates_attachment_size :data, less_than: 2.megabytes
#   validates_attachment_content_type :data, content_type: /\Aimage/
#   # do_not_validate_attachment_file_type :data

#   def url_content
#     url(:content)
#   end
# end
