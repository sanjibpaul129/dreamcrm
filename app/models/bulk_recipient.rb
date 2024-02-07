class BulkRecipient < ApplicationRecord
belongs_to :organisation

def self.import(file, organisation_id)
  bulk_recipients_imported=0
  errors=[]	
  spreadsheet= BulkRecipient.open_spreadsheet(file)
  header=spreadsheet.row(1)
  bulk_recipient=nil
  (2..spreadsheet.last_row).each do |i|
    row=Hash[[header,spreadsheet.row(i)].transpose]
    if row['email']!=""
      if BulkRecipient.where(email: row['email'].to_s, organisation_id: organisation_id) != []
        project_email_validation=false
        errors=errors+[['Duplicate email', row, BulkRecipient.where(email: row['email'].to_s)]]
      end
    end
    if row['mobile']!=""
      if organisation_id != 8
        if BulkRecipient.where(mobile: row['mobile'].to_s, organisation_id: organisation_id) != []
          project_mobile_validation=false
          errors=errors+[['Duplicate Mobile', row, BulkRecipient.where(mobile: row['mobile'].to_s)]]
        end
      end
    end
    if row['field_one']!=nil
    end
    if row['field_two']!=nil
    end
    if row['field_three']!=nil
    end
    if row['field_four']!=nil
    end
    if row['field_five']!=nil
    end

    if project_mobile_validation==false || project_email_validation==false 
    else
      bulk_recipient=new
      bulk_recipient.email=row['email']
      bulk_recipient.mobile=row['mobile']
      bulk_recipient.field_one=row['field_one']
      bulk_recipient.field_two=row['field_two']
      bulk_recipient.field_three=row['field_three']
      bulk_recipient.field_four=row['field_four']
      bulk_recipient.field_five=row['field_five']
      bulk_recipient.organisation_id=organisation_id
      bulk_recipient.save!
      bulk_recipients_imported+=1
    end
  end
  errors=errors.uniq { |s| s.second }
  # UserMailer.bulk_recipient_import_errors([errors, bulk_recipients_imported]).deliver
  return errors
end

  def self.open_spreadsheet(file)

    tmp = file.tempfile
    okfile = File.join("public", file.original_filename)
    FileUtils.cp tmp.path, okfile


    case File.extname(file.original_filename)
    #when ".csv" then Roo::Csv.new (file.path nil, :ignore)

    when ".xlsx" then Roo::Excelx.new (okfile)
    # when ".xls" then Roo::Excel.new (file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

end
