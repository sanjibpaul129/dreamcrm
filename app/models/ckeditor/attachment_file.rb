# # frozen_string_literal: true

# class Ckeditor::AttachmentFile < Ckeditor::Asset
#   has_attached_file :data,
#                     url: '/ckeditor_assets/attachments/:id/:filename',
#                     path: ':rails_root/public/ckeditor_assets/attachments/:id/:filename'

#   # has_attached_file :data,
#   #                   :path => "attachments/:id", 
#   #                   :url => ":s3_domain_url"


#   # has_attached_file :data, :storage => :s3, :bucket => ENV['S3_BUCKET_NAME'], :s3_region => ENV['AWS_REGION'], :path => "attachments/:id", :url => ":s3_domain_url"
#   validates_attachment_presence :data
#   validates_attachment_size :data, less_than: 100.megabytes
#   # do_not_validate_attachment_file_type :data

#   def url_thumb
#     @url_thumb ||= Ckeditor::Utils.filethumb(filename)
#   end

# end
