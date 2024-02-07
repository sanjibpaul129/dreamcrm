class Expenditure < ApplicationRecord
	belongs_to :source_category
	
	def self.import(file)
		costing_imported = 0
  		errors = []	
  		beginning_of_month = file[1]
  		spreadsheet = Expenditure.open_spreadsheet(file[0])
  		header = spreadsheet.row(1)
  		expenditure = nil
  		missed_adds = []
  		not_found_amount={}

  		BusinessUnit.where(organisation_id: 1).each do |business_unit|
  			project_not_found_amount={business_unit.name => [0.00,'']}
  			not_found_amount[business_unit.name]=[0.00,'']
  		end

  		p not_found_amount

  		(2..spreadsheet.last_row).each do |i|
  			p i
  			p "==========="
    		row = Hash[[header,spreadsheet.row(i)].transpose]
		    if row['Campaign name']==nil && row['Ad Set Name']==nil && row['Ad name']==nil && row['Campaign ID']==nil && row['Ad set ID']==nil && row['Ad ID']==nil && row['Delivery status']==nil && row['Delivery level']==nil && row['Result type']==nil && row['Results']==nil && row['Amount spent (INR)']==nil&& row['Reporting starts']==nil&& row['Reporting ends']==nil
		        break
		    end
	    	if row['Campaign name']==nil
	    		errors = errors+[['No Campaign name', row]]
	    		campaign_name_validation = false	
			end
			if row['Ad Set Name']==nil
	    		errors = errors+[['No Ad Set Name', row]]
	    		ad_set_name_validation = false	
			end
			if row['Ad name']==nil
	    		errors = errors+[['No Ad name', row]]
	    		ad_name_validation = false	
			end
			if row['Campaign ID']==nil
	    		errors = errors+[['No Campaign ID', row]]
	    		campaign_id_validation = false	
			end
			if row['Ad set ID']==nil
	    		errors = errors+[['No Ad set ID', row]]
	    		ad_set_id_validation = false	
			end
			if row['Ad ID']==nil
	    		errors = errors+[['No Ad ID', row]]
	    		ad_id_validation = false	
			end
			if row['Results']==nil
	    		errors = errors+[['No Results', row]]
	    		result_validation = false	
			end
			if row['Amount spent (INR)']==nil
	    		errors = errors+[['No Amount spent (INR)', row]]
	    		amount_validation = false	
			end
		    if campaign_name_validation == false || ad_set_name_validation == false || ad_name_validation == false || campaign_id_validation == false || ad_set_id_validation == false || ad_id_validation == false || result_validation == false || amount_validation == false
		    else
		    	p "inserting into the else section"
		    	facebook_ads = FacebookAd.where(campaign_id: row['Campaign ID'], adset_id: row['Ad set ID'], ad_id: row['Ad ID'])
		    	if facebook_ads == []
		    		missed_adds += ["Campaign name: "+row['Campaign name'].to_s+", Adset Name: "+row['Ad Set Name'].to_s+", Ad Name: "+row['Ad name'].to_s+", Campaign Id: "+row['Campaign ID'].to_s+", Adset Id: "+row['Ad set ID'].to_s+", Ad Id: "+row['Ad ID'].to_s+"\n"]
		    		
		    		project_found=false	
		    		not_found_amount.each do |project, value|
		    			 if row['Campaign name'].to_s.include? project
		    			 	not_found_amount[project][0]+=row['Amount spent (INR)'].to_f
		    			 	not_found_amount[project][1]+="Campaign name: "+row['Campaign name'].to_s+", Adset Name: "+row['Ad Set Name'].to_s+", Ad Name: "+row['Ad name'].to_s+", Campaign Id: "+row['Campaign ID'].to_s+", Adset Id: "+row['Ad set ID'].to_s+", Ad Id: "+row['Ad ID'].to_s+", Amount: "+row['Amount spent (INR)'].to_s+"\n"
		    			 	project_found=true
		    			 end
		    		end

	    			if project_found=false
	    			 	not_found_amount['Dream Pratham'][0]+=row['Amount spent (INR)'].to_f
	    			 	not_found_amount['Dream Pratham'][1]+="Campaign name: "+row['Campaign name'].to_s+", Adset Name: "+row['Ad Set Name'].to_s+", Ad Name: "+row['Ad name'].to_s+", Campaign Id: "+row['Campaign ID'].to_s+", Adset Id: "+row['Ad set ID'].to_s+", Ad Id: "+row['Ad ID'].to_s+", Amount: "+row['Amount spent (INR)'].to_s+"\n"
	    			 	p not_found_amount['Dream Pratham']
	    			 end	

		    	else
		    		p "inserting into the second else section"
		    		facebook_ads.each do |facebook_ad|
			    		expenditure = new
					    expenditure.source_category_id = facebook_ad.source_category_id
					    expenditure.period = beginning_of_month
					    count = facebook_ads.count
					    if count > 1
					    	amount = (row['Amount spent (INR)'].to_f/count)
					    	expenditure.amount = amount
					    else
					    	expenditure.amount = row['Amount spent (INR)']
					    end
					    expenditure.business_unit_id = facebook_ad.business_unit_id
				     	expenditure.save
				        costing_imported+=1	
			    	end
			    end
		  	end
	  	end
		not_found_amount.each do |project,value|
		expenditure = new
	    expenditure.source_category_id = SourceCategory.find_by(description: 'FACEBOOK', organisation_id: 1).id
	    expenditure.period = beginning_of_month
	    expenditure.amount = value[0]
	    expenditure.business_unit_id = BusinessUnit.find_by_name(project).id
     	expenditure.remarks=value[1]
     	expenditure.save
     	end
	  	errors=errors.uniq { |s| s.second }
	  	UserMailer.costing_report_import_errors([errors, missed_adds]).deliver
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