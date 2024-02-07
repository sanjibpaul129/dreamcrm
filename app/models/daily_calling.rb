class DailyCalling < ApplicationRecord
	belongs_to :personnel
	def self.import(file)
		spreadsheet = DailyCalling.open_spreadsheet(file[0])
  		personnel_id = file[1].to_i
  		header = spreadsheet.row(1)
  		daily_calling = nil
  		(2..spreadsheet.last_row).each do |i|
  			row = Hash[[header,spreadsheet.row(i)].transpose]
  			if row['Name']==nil && row['Phone Number']==nil && row['Time']==nil && row['Duration']==nil && row['Type']==nil
  				break
		    else
		    	daily_calling = new
		    	daily_calling.date = row['Time'].to_datetime
		    	duration = Time.at(row['Duration']).utc.strftime("%H:%M:%S")
		    	daily_calling.duration = (duration[3..4]+"."+duration[6..7]).to_f
		    	if row['Phone Number'].to_s.length == 10
		    		daily_calling.called_number = row['Phone Number']
		    	elsif row['Phone Number'].to_s.length == 12
		    		daily_calling.called_number = row['Phone Number'].to_s[2..row['Phone Number'].to_s.length].to_i
		    	else
		    		daily_calling.called_number = row['Phone Number']
		    	end
		    	daily_calling.call_type = row['Type']
		    	daily_calling.personnel_id = personnel_id
		    	daily_calling.save
		    end
  		end
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
