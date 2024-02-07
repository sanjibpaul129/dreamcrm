class WishToCustomer < ApplicationRecord

def self.import(file, organisation_id)
  wish_to_customers_imported=0
  errors=[]	
  spreadsheet= WishToCustomer.open_spreadsheet(file)
  header=spreadsheet.row(1)
  wish_to_customer=nil
  (2..spreadsheet.last_row).each do |i|
    row=Hash[[header,spreadsheet.row(i)].transpose]
    if row['name']!=""
      if WishToCustomer.where(name: row['name'].to_s, organisation_id: organisation_id) != []
        project_name_validation=false
        errors=errors+[['Duplicate name', row, WishToCustomer.where(name: row['name'].to_s)]]
      end
    end
    if row['email']!=""
      if WishToCustomer.where(email: row['email'].to_s, organisation_id: organisation_id) != []
        project_email_validation=false
        errors=errors+[['Duplicate email', row, WishToCustomer.where(email: row['email'].to_s)]]
      end
    end
    if row['mobile']!=""
      if organisation_id != 8
        if WishToCustomer.where(mobile: row['mobile'].to_s, organisation_id: organisation_id) != []
          project_mobile_validation=false
          errors=errors+[['Duplicate Mobile', row, WishToCustomer.where(mobile: row['mobile'].to_s)]]
        end
      end
    end
    if row['dob']!=""
      if WishToCustomer.where(dob: row['dob'].to_s, organisation_id: organisation_id) != []
        project_dob_validation=false
        errors=errors+[['Duplicate dob', row, WishToCustomer.where(dob: row['dob'].to_s)]]
      end
    end
    if row['doa']!=""
      if WishToCustomer.where(doa: row['doa'].to_s, organisation_id: organisation_id) != []
        project_doa_validation=false
        errors=errors+[['Duplicate doa', row, WishToCustomer.where(doa: row['doa'].to_s)]]
      end
    end
    
    if row['field_one']!=nil
    end
    if row['field_two']!=nil
    end
    if row['field_three']!=nil
    end
    
    if project_mobile_validation==false || project_email_validation==false 
    else
      wish_to_customer=new
      wish_to_customer.email=row['email']
      wish_to_customer.mobile=row['mobile']
      wish_to_customer.field_one=row['field_one']
      wish_to_customer.field_two=row['field_two']
      wish_to_customer.field_three=row['field_three']
      wish_to_customer.name=row['name']
      wish_to_customer.dob=row['dob']
      wish_to_customer.doa=row['doa']
      wish_to_customer.organisation_id=organisation_id
      wish_to_customer.save!
      wish_to_customers_imported+=1
    end
  end
  errors=errors.uniq { |s| s.second }
  # UserMailer.wish_to_customer_import_errors([errors, wish_to_customers_imported]).deliver
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
