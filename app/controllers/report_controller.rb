class ReportController < ApplicationController

def budget_status

    @from=(Date.today)-1.day
    @to=(Date.today)

    @google_project_budgets=[{:name => 'Dream World City', :daily_budget => 0},{:name => 'Dream Valley', :daily_budget => 0},{:name => 'Dream One', :daily_budget => 0},{:name => 'Dream Eco City', :daily_budget => 0},{:name => 'Ecocity Bungalows', :daily_budget => 0}]

    google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345', 'Dream Gurukul' => '9885817994'}

    google_ad_accounts.each do |project,ad_account_id|

    ad_account=ad_account_id

    urlstring =  "https://www.googleapis.com/oauth2/v3/token"
    result = HTTParty.post(urlstring,
    :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
    :headers => {'Content-Type' => 'application/json'} )
    access_token=result["access_token"]
    urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_account+"/googleAds:searchStream"
    result = HTTParty.post(urlstring,
    :body => {"query": "SELECT campaign.name, campaign_budget.amount_micros FROM campaign WHERE campaign.status='ENABLED' AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
    project_budget=@google_project_budgets.select{|project_budget| project_budget[:name] == project }[0]
      result[0]["results"].each do |campaign|
          project_budget[:daily_budget]=project_budget[:daily_budget]+(campaign['campaignBudget']['amountMicros'].to_i/1000000)
      end
    end

 @google_project_budgets+=[{:name => 'Dream Palazzo', :daily_budget => 0},{:name => 'Dream Exotica', :daily_budget => 0}]



  info_array=[]

  ad_accounts=['836531817211431', '7714807368559327', '426767712305587', '592042111747674']

  ad_accounts.each do |ad_account|
  url_string_1="https://graph.facebook.com/v14.0/act_"
  url_string_2="/insights?level=adset&campaign%2C&account&time_range=%7B%22since%22%3A%22"
  url_string_3="%22%2C%22until%22%3A%22"
  url_string_4="%22%7D&fields=campaign_name%2Cadset_id&access_token=EAAGMztM7V2wBAEtxszz5mlrZCUljRemIHcqoCDZCl8VKSpqJDUqYgKAUkfB0qZBu31u6enNecnebna7iVKMCHYY9XRJuLOZBCGW8xgdnLRkN09hDyDSalNZCdZA4xiKX2HBI4gRmK8ZAJ5iYlcSgjZAdvaGn4eXzscsESwoUp5dqbZBStm9ZCEueiF"
  url_string=url_string_1+ad_account+url_string_2+(@from.to_date.strftime('%Y-%m-%d'))+url_string_3+(@to.to_date.strftime('%Y-%m-%d'))+url_string_4
  result = HTTParty.get(url_string)
  info_array+=result['data']
  end



@project_budgets=[{:name => 'Dream World City', :daily_budget => 0},{:name => 'Dream Valley', :daily_budget => 0},{:name => 'Dream One', :daily_budget => 0},{:name => 'Dream Eco City', :daily_budget => 0},{:name => 'Ecocity Bungalows', :daily_budget => 0},{:name => 'Dream Palazzo', :daily_budget => 0},{:name => 'Dream Exotica', :daily_budget => 0}]

ad_accounts=['836531817211431', '7714807368559327', '426767712305587', '592042111747674']

  ad_accounts.each do |ad_account|
  url_string_1="https://graph.facebook.com/v14.0/act_"
  url_string_2="/adsets?time_range=%7B%22since%22%3A%22"
  url_string_3="%22%2C%22until%22%3A%22"
  url_string_4="%22%7D&fields=daily_budget%2Ceffective_status%2Ccampaign_name&access_token=EAAGMztM7V2wBAEtxszz5mlrZCUljRemIHcqoCDZCl8VKSpqJDUqYgKAUkfB0qZBu31u6enNecnebna7iVKMCHYY9XRJuLOZBCGW8xgdnLRkN09hDyDSalNZCdZA4xiKX2HBI4gRmK8ZAJ5iYlcSgjZAdvaGn4eXzscsESwoUp5dqbZBStm9ZCEueiF"
  url_string=url_string_1+ad_account+url_string_2+(@from.to_date.strftime('%Y-%m-%d'))+url_string_3+(@to.to_date.strftime('%Y-%m-%d'))+url_string_4
  result = HTTParty.get(url_string)
    result['data'].each do |adset|
      if adset['effective_status']=='ACTIVE'
        if FacebookAd.find_by_adset_id(adset['id']) != nil
        project_budget=@project_budgets.select{|project_budget| project_budget[:name] == FacebookAd.find_by_adset_id(adset['id']).business_unit.name }[0]
        project_budget[:daily_budget]=project_budget[:daily_budget]+(adset['daily_budget'].to_i/100)
        else
        campaign_info=info_array.select{|adset_info| adset_info["adset_id"] == adset['id']}[0]
          if campaign_info != nil
            campaign_name=campaign_info["campaign_name"]
            @project_budgets.each do |project_budget|
              if campaign_name.gsub(/\s+/, '').downcase.include?(project_budget[:name].gsub(/\s+/, '').downcase)
                project_budget[:daily_budget]=project_budget[:daily_budget]+(adset['daily_budget'].to_i/100)
              end
            end
          end
        end
    end
    end
  end

facebook_source_id=SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . FACEBOOK').id
google_source_id=SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Google').id

@proposed_budgets=[{:name => 'Dream World City', :budget => 0},{:name => 'Dream Valley', :budget => 0},{:name => 'Dream One', :budget => 0},{:name => 'Dream Eco City', :budget => 0},{:name => 'Ecocity Bungalows', :budget => 0},{:name => 'Dream Palazzo', :budget => 0},{:name => 'Dream Exotica', :budget => 0}]

@proposed_budgets.each do |proposed_budget|
  business_unit_id=BusinessUnit.find_by_name(proposed_budget[:name]).id
  fb_budget=Expenditure.where(source_category_id: facebook_source_id, business_unit_id: business_unit_id, period: Time.now.beginning_of_month).last.try(:budgeted_amount)
  proposed_budget[:budget]+=fb_budget if fb_budget != nil
  google_budget=Expenditure.where(source_category_id: google_source_id, business_unit_id: business_unit_id, period: Time.now.beginning_of_month).last.try(:budgeted_amount)
  proposed_budget[:budget]+=google_budget if google_budget != nil
end

end

def digital_report
  @projects = []
  BusinessUnit.where(organisation_id: 1).each do |business_unit|
    if business_unit.name == "Dream World City" || business_unit.name == "Dream Valley" || business_unit.name == "Dream One" || business_unit.name == "Dream One Hotel Apartment" || business_unit.name == "Dream Eco City" || business_unit.name == "Ecocity Bungalows"
      @projects += [[business_unit.name, business_unit.id]]
    end
  end
  if params[:project] == nil
    project_selected = BusinessUnit.find_by_name('Dream One').id
  else
    project_selected = params[:project][:selected]
  end
  @business_unit_id = project_selected
  @from = (Date.today)-30
  @to = (Date.today)
  if params[:lead] != nil
    @from = params[:lead][:from].to_date
    @to = params[:lead][:to].to_date
  end
  @with_details = nil
  if params[:with_details] == nil
    @with_details = nil
  else
    @with_details = true
  end
  @digital_report_data=[]
  #facebook
  # Source
  @facebook_conversions = []
  facebook_report = {}
  facebook_report["source"] = "Facebook"
  # Budget
  # PlannedENQ
  month_days = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  budget_total = 0
  planned_enquiry_total = 0
  months = ((@to.year * 12 + @to.month) - (@from.year * 12 + @from.month))+1
  if months == 0
    expenditure = Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . FACEBOOK').id, period: @from.beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    if expenditure == nil
      month_budget = 0
      month_planned_enquiry = 0
    else
      month_budget = expenditure.budgeted_amount
      month_planned_enquiry = expenditure.budgeted_enquiries
    end
    days = ((@to-@from).to_i)+1
    budget_total += (days.to_f/month_days[@from.month].to_f)*month_budget.to_f
    planned_enquiry_total += (days.to_f/month_days[@from.month].to_f)*month_planned_enquiry.to_f
  end
  month_count=0
  months.times do
    expenditure=Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . FACEBOOK').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    if expenditure==nil
      month_budget=0
      month_planned_enquiry=0
    else
      month_budget=expenditure.budgeted_amount
      month_planned_enquiry=expenditure.budgeted_enquiries
    end
    if (@from+month_count.month).month==@from.month
      from_date=@from
    else
      from_date=(@from+month_count.month).beginning_of_month
    end
    if (@from+month_count.month).month==@to.month
      to_date=@to
    else
      to_date=(@from+month_count.month).end_of_month
    end
    days=((to_date-from_date).to_i)+1
    budget_total+=(days.to_f/month_days[(@from+month_count.month).month].to_f)*month_budget.to_f
    planned_enquiry_total+=(days.to_f/month_days[(@from+month_count.month).month].to_f)*month_planned_enquiry.to_f
    month_count+=1
  end
  # Actual
  facebook_report["Budget Amount"]=budget_total.to_i
  spend_array = []
  ad_accounts = ['836531817211431', '7714807368559327', '426767712305587', '592042111747674']
  ad_accounts.each do |ad_account|
    url_string_1="https://graph.facebook.com/v18.0/act_"
    url_string_2="/insights?level=adset&campaign%2C&account&time_range=%7B%22since%22%3A%22"
    url_string_3="%22%2C%22until%22%3A%22"
    url_string_4="%22%7D&fields=campaign_name%2Ccampaign_id%2Cspend&access_token=EAAyexB6elyEBOwP97Q5J7K1pZCgkntNSZBcDIQ3WdZB6uSoV5L3ZAZBTLMDBfmZAVEZCC5t4uUE7ZCrOt534hP3CnZCfIxda4Udy5QdUbVBzplchccZBYy6Dmyr4iZBjV5uSFpqZB7zfRyuBtQAqPjAemIcql7ZBmUwClYmRhZBt70D9VIjjhZCF5rRIOiiddx1LeEZD"
    url_string=url_string_1+ad_account+url_string_2+(@from.to_date.strftime('%Y-%m-%d'))+url_string_3+(@to.to_date.strftime('%Y-%m-%d'))+url_string_4
    result = HTTParty.get(url_string)
    spend_array+=result['data']
  end
  actual_amount = 0
  spend_array.each do |adset_hash|
    if adset_hash['campaign_name'].downcase.include? ('conversion')
      @facebook_conversions+=[{'Campaign'=> adset_hash['campaign_name'], 'Ad Spend'=> adset_hash['spend']}]
    end
    if adset_hash['campaign_name'].downcase.include? ('post')
      @facebook_conversions+=[{'Campaign'=> adset_hash['campaign_name'], 'Ad Spend'=> adset_hash['spend']}]
    end
    if adset_hash['campaign_name'].downcase.include? ('awar')
      @facebook_conversions+=[{'Campaign'=> adset_hash['campaign_name'], 'Ad Spend'=> adset_hash['spend']}]
    end
    if adset_hash['campaign_name'].downcase.include? ('traffic')
      @facebook_conversions+=[{'Campaign'=> adset_hash['campaign_name'], 'Ad Spend'=> adset_hash['spend']}]
    end
    if FacebookAd.find_by(campaign_id: adset_hash['campaign_id'], business_unit_id: @business_unit_id)==nil
    else
      actual_amount+=adset_hash['spend'].to_i
    end
  end
  facebook_report["Actual Amount"]=actual_amount.to_i
  facebook_report["Planned Enquiries"]=planned_enquiry_total.to_i
  # ActualENQ(removal of duplicate and test leads)
  facebook_actual_enquiries = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . FACEBOOK%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day).count
  # Duplicate lead (existing with same source)
  # actual_enquiries = facebook_actual_enquiries-(Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . FACEBOOK%", "Duplicate lead (existing with same source)", @from.to_datetime, @to.to_datetime+1.day).count)
  facebook_duplicate_leads = (Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . FACEBOOK%", "Duplicate lead (existing with same source)", @from.to_datetime, @to.to_datetime+1.day).count)
  # Testing Purpose
  # actual_enquiries = actual_enquiries-(Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . FACEBOOK%", "Testing Purpose", @from.to_datetime, @to.to_datetime+1.day).count)
  facebook_testing_leads = (Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . FACEBOOK%", "Testing Purpose", @from.to_datetime, @to.to_datetime+1.day).count)
  actual_enquiries = (facebook_actual_enquiries-(facebook_duplicate_leads+facebook_testing_leads))
  facebook_report["Actual Enquiries"]=actual_enquiries
  # TargetCPL
  facebook_report["Target CPL"]=450
  # ActualCPL
  facebook_report["Actual CPL"]=(actual_amount.to_f/actual_enquiries.to_f).to_i
  # PlannedQL
  facebook_report["Planned QL"]=(planned_enquiry_total*0.15).to_i
  # ActualQL
  facebook_report["Actual QL"]=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.qualified_on is not ?', "%Online . FACEBOOK%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
  if @with_details == true
    # Site Visited leads
    facebook_site_visited_lead = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.site_visited_on is not ?', "%Online . FACEBOOK%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
    facebook_report["Site Visits"] = facebook_site_visited_lead
    # Booked Leads
    facebook_booked_lead = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}, cancelled_on: nil).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.booked_on is not ? and lost_reason_id is ?', "%Online . FACEBOOK%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil, nil).count
    facebook_report["All Booking"] = facebook_booked_lead
  end
  # TargetCPQL
  facebook_report["Target CPQL"]=3000
  # ActualCPQL
  if facebook_report["Actual QL"]==0
    facebook_report["Actual CPQL"]=0
  else
    facebook_report["Actual CPQL"]=(actual_amount.to_f/(facebook_report['Actual QL']).to_f).to_i
  end
  if @with_details == true
    # ActualCPSV
    if facebook_report["Site Visits"]==0 || facebook_report["Site Visits"] == nil
      facebook_report["Actual CPSV"] = 0
    else
      facebook_report["Actual CPSV"]=(actual_amount.to_f/(facebook_report['Site Visits']).to_f).to_i
    end
  end
  @facebook_report=facebook_report
  #google
  # Source
  google_report = {}
  google_report["source"] = "Google"
  # Budget
  # PlannedENQ
  month_days=[nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  budget_total=0
  planned_enquiry_total=0
  months=((@to.year * 12 + @to.month) - (@from.year * 12 + @from.month))+1
  if months==0
    expenditure = Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Google').id, period: @from.beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    if expenditure==nil
      month_budget = 0
      month_planned_enquiry = 0
    else
      month_budget = expenditure.budgeted_amount
      month_planned_enquiry = expenditure.budgeted_enquiries
    end
    days = ((@to-@from).to_i)+1
    budget_total+=(days.to_f/month_days[@from.month].to_f)*month_budget.to_f
    planned_enquiry_total+=(days.to_f/month_days[@from.month].to_f)*month_planned_enquiry.to_f
  end
  month_count = 0
  months.times do
    expenditure = Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Google').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    if expenditure == nil
      month_budget = 0
      month_planned_enquiry = 0
    else
      month_budget = expenditure.budgeted_amount
      month_planned_enquiry = expenditure.budgeted_enquiries
    end
    if (@from+month_count.month).month == @from.month
      from_date = @from
    else
      from_date = (@from+month_count.month).beginning_of_month
    end
    if (@from+month_count.month).month == @to.month
      to_date = @to
    else
      to_date = (@from+month_count.month).end_of_month
    end
    days = ((to_date-from_date).to_i)+1
    budget_total+=(days.to_f/month_days[(@from+month_count.month).month].to_f)*month_budget.to_f
    planned_enquiry_total+=(days.to_f/month_days[(@from+month_count.month).month].to_f)*month_planned_enquiry.to_f
    month_count+=1
  end
  # Actual
  google_report["Budget Amount"] = budget_total.to_i
  google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
  project_name = BusinessUnit.find(@business_unit_id).name
  ad_account = google_ad_accounts[project_name]
  urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_account+"/googleAds:searchStream"
  result = HTTParty.post(urlstring,
  :body => {"query": "SELECT campaign.name, metrics.cost_micros FROM campaign WHERE segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
  :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+(Organisation.find(1).google_access_token), 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
  ad_spend = 0
  if result[0]["results"] != nil
    result[0]["results"].each do |campaign|
      if project_name == 'Dream One'
        if campaign["campaign"]["name"].downcase.include? ('studio')
        else
          ad_spend+=campaign["metrics"]["costMicros"].to_f/1000000
        end
      elsif project_name == 'Dream One Hotel Apartment'
        if campaign["campaign"]["name"].downcase.include? ('studio')
          ad_spend+=campaign["metrics"]["costMicros"].to_f/1000000
        end
      else
        ad_spend+=campaign["metrics"]["costMicros"].to_f/1000000
      end
    end
  else
    urlstring =  "https://www.googleapis.com/oauth2/v3/token"
    result = HTTParty.post(urlstring,
    :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
    :headers => {'Content-Type' => 'application/json'} )
    access_token=result["access_token"]
    urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_account+"/googleAds:searchStream"
    result = HTTParty.post(urlstring,
    :body => {"query": "SELECT campaign.name, metrics.cost_micros FROM campaign WHERE segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
    Organisation.find(1).update(google_access_token: access_token)
    p result
    p "====================="
    result[0]["results"].each do |campaign|
      ad_spend+=campaign["metrics"]["costMicros"].to_f/1000000
    end
  end
  google_report["Actual Amount"]=ad_spend.to_i
  google_report["Planned Enquiries"]=planned_enquiry_total.to_i
  # ActualENQ(removal of duplicate and test leads)
  google_actual_enquiries=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Google%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day).count
  #super receptionist
  # actual_enquiries+=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Super Receptionist%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day).count
  sr_actual_enquiries = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Super Receptionist%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day).count
  # Duplicate lead (existing with same source)
  google_duplicate_leads=Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Google%", "Duplicate lead (existing with same source)", @from.to_datetime, @to.to_datetime+1.day).count
  sr_duplicate_leads=Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Super Receptionist%", "Duplicate lead (existing with same source)", @from.to_datetime, @to.to_datetime+1.day).count
  # actual_enquiries=actual_enquiries-(Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Google%", "Duplicate lead (existing with same source)", @from.to_datetime, @to.to_datetime+1.day).count)
  # Testing Purpose
  google_testing_leads=Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Google%", "Testing Purpose", @from.to_datetime, @to.to_datetime+1.day).count
  sr_testing_leads=Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Super Receptionist%", "Testing Purpose", @from.to_datetime, @to.to_datetime+1.day).count
  duplicate_testing = (google_duplicate_leads+google_testing_leads+sr_duplicate_leads+sr_testing_leads)
  # actual_enquiries=actual_enquiries-(Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('source_categories.heirarchy like ? AND lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "%Online . Google%", "Testing Purpose", @from.to_datetime, @to.to_datetime+1.day).count)
  actual_enquiries=((google_actual_enquiries+sr_actual_enquiries)-duplicate_testing)
  google_report["Actual Enquiries"]=actual_enquiries
  # TargetCPL
  google_report["Target CPL"]=450
  # ActualCPL
  google_report["Actual CPL"]=(ad_spend.to_f/actual_enquiries.to_f).to_i
  # PlannedQL
  google_report["Planned QL"]=(planned_enquiry_total*0.15).to_i
  # ActualQL
  google_qualified_leads=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.qualified_on is not ?', "%Online . Google%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
  google_qualified_leads+=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.qualified_on is not ?', "%Online . Super Receptionist%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
  google_report["Actual QL"]=google_qualified_leads
  if @with_details == true
    # Site Visited leads
    google_site_visited_leads=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.site_visited_on is not ?', "%Online . Google%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
    google_site_visited_leads+=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.site_visited_on is not ?', "%Online . Super Receptionist%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
    google_report["Site Visits"] = google_site_visited_leads
    # Booked Leads
    google_booked_leads = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}, cancelled_on: nil).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.booked_on is not ? and lost_reason_id is ?', "%Online . Google%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil, nil).count
    google_booked_leads+=Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}, cancelled_on: nil).where('source_categories.heirarchy like ? and leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.booked_on is not ? and lost_reason_id is ?', "%Online . Super Receptionist%", @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil, nil).count
    google_report["All Booking"]=google_booked_leads
  end
  # TargetCPQL
  google_report["Target CPQL"]=3000
  # ActualCPQL
  if google_report["Actual QL"]==0
    google_report["Actual CPQL"]=0
  else
    google_report["Actual CPQL"]=(ad_spend.to_f/(google_report['Actual QL']).to_f).to_i
  end
  if @with_details == true
    # ActualCPSV
    if google_report["Site Visits"]==0 || google_report["Site Visits"] == nil
      google_report["Actual CPSV"]=0
    else
      google_report["Actual CPSV"]=(ad_spend.to_f/(google_report['Site Visits']).to_f).to_i
    end
  end
  @google_report=google_report
  #Others
  # Source
  @other_conversions = []
  other_report = {}
  other_report["source"] = "Others"
  # Budget
  # PlannedENQ
  month_days = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  budget_total = 0
  planned_enquiry_total = 0
  months = ((@to.year * 12 + @to.month) - (@from.year * 12 + @from.month))+1
  if months == 0
    expenditure = Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Housing').id, period: @from.beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    expenditure += Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Magicbricks').id, period: @from.beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    expenditure += Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . 99 Acres').id, period: @from.beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    if expenditure == nil
      month_budget = 0
      month_planned_enquiry = 0
    else
      month_budget = expenditure.budgeted_amount
      month_planned_enquiry = expenditure.budgeted_enquiries
    end
    days = ((@to-@from).to_i)+1
    budget_total += (days.to_f/month_days[@from.month].to_f)*month_budget.to_f
    planned_enquiry_total += (days.to_f/month_days[@from.month].to_f)*month_planned_enquiry.to_f
  end
  month_count = 0
  months.times do
    expenditure = Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Housing').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    if expenditure == nil
      expenditure = Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Magicbricks').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
      if expenditure == nil
        expenditure = Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . 99 Acres').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
      else
        expenditure += Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . 99 Acres').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
      end
    else
      expenditure += Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . Magicbricks').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
      expenditure += Expenditure.find_by(source_category_id: SourceCategory.find_by(organisation_id: 1, heirarchy: 'Online . 99 Acres').id, period: (@from+month_count.month).beginning_of_month.to_datetime, business_unit_id: @business_unit_id)
    end
    if expenditure == nil
      month_budget = 0
      month_planned_enquiry = 0
    else
      month_budget = expenditure.budgeted_amount
      month_planned_enquiry = expenditure.budgeted_enquiries
    end
    if (@from+month_count.month).month == @from.month
      from_date = @from
    else
      from_date = (@from+month_count.month).beginning_of_month
    end
    if (@from+month_count.month).month == @to.month
      to_date = @to
    else
      to_date = (@from+month_count.month).end_of_month
    end
    days = ((to_date-from_date).to_i)+1
    budget_total+=(days.to_f/month_days[(@from+month_count.month).month].to_f)*month_budget.to_f
    planned_enquiry_total+=(days.to_f/month_days[(@from+month_count.month).month].to_f)*month_planned_enquiry.to_f
    month_count+=1
  end
  other_report["Budget Amount"] = budget_total.to_i
  other_report["Actual Amount"] = 0
  # Actual
  other_report["Planned Enquiries"] = planned_enquiry_total.to_i
  # ActualENQ(removal of duplicate and test leads)
  all_actual_enquiries = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ?', @business_unit_id, @from.to_datetime, @to.to_datetime+1.day).count
  # Duplicate lead (existing with same source)
  # actual_enquiries = actual_enquiries-(Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "Duplicate lead (existing with same source)", @from.to_datetime, @to.to_datetime+1.day).count)
  all_duplicate_leads = (Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "Duplicate lead (existing with same source)", @from.to_datetime, @to.to_datetime+1.day).count)
  # Testing Purpose
  # actual_enquiries = actual_enquiries-(Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "Testing Purpose", @from.to_datetime, @to.to_datetime+1.day).count)
  all_testing_leads = (Lead.includes(:source_category, :lost_reason).where(:source_categories => {organisation_id: 1}, business_unit_id: @business_unit_id).where('lost_reasons.description = ? and leads.generated_on >= ? and leads.generated_on < ?', "Testing Purpose", @from.to_datetime, @to.to_datetime+1.day).count)
  other_actual_enquiries = all_actual_enquiries-(facebook_actual_enquiries+google_actual_enquiries+sr_actual_enquiries)
  other_duplicate_leads = all_duplicate_leads-(facebook_duplicate_leads+google_duplicate_leads+sr_duplicate_leads)
  other_testing_leads = all_testing_leads-(facebook_testing_leads+google_testing_leads+sr_testing_leads)
  actual_enquiries = other_actual_enquiries-(other_duplicate_leads+other_testing_leads)

  other_report["Actual Enquiries"] = actual_enquiries
  # TargetCPL
  other_report["Target CPL"] = 0
  # ActualCPL
  other_report["Actual CPL"] = 0
  # PlannedQL
  other_report["Planned QL"] = (planned_enquiry_total*0.15).to_i
  # ActualQL
  actual_qualified = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.qualified_on is not ?', @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
  actual_qualified = actual_qualified-(facebook_report["Actual QL"]+google_report["Actual QL"])
  other_report["Actual QL"] = actual_qualified
  if @with_details == true
    # Site Visited leads
    sv_leads = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}).where('leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.site_visited_on is not ?', @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil).count
    sv_leads = sv_leads-(facebook_site_visited_lead+google_site_visited_leads)
    other_report["Site Visits"] = sv_leads
    # Booked Leads
    booked_leads = Lead.includes(:source_category).where(:source_categories => {organisation_id: 1}, cancelled_on: nil).where('leads.business_unit_id = ? and leads.generated_on >= ? and leads.generated_on < ? and leads.booked_on is not ? and lost_reason_id is ?', @business_unit_id, @from.to_datetime, @to.to_datetime+1.day, nil, nil).count
    booked_leads = booked_leads-(facebook_booked_lead + google_booked_leads)
    other_report["All Booking"] = booked_leads
  end
  # TargetCPQL
  other_report["Target CPQL"] = 0
  # ActualCPQL
  other_report["Actual CPQL"] = 0
  if @with_details == true
    # ActualCPSV
    other_report["Actual CPSV"] = 0
  end
  @other_report=other_report
end

def facebook_expandable
  @with_details=params[:with_details]
  @from=(Date.today)-30
    @to=(Date.today)
    if params[:lead] != nil
      @from=params[:lead][:from]
      @to=params[:lead][:to]
    end
  @sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
  lost_reasons=LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
  lost_reasons=lost_reasons-[57,49]
  lost_reasons=lost_reasons+[nil]

  if current_personnel.email == "nitesh.m@orangesoftech.net"
    @projects=[]
    BusinessUnit.where(organisation_id: 1).each do |business_unit|
      if business_unit.name == "Ecocity Exotica" || business_unit.name == "Dream Gurukul"
        @projects += [[business_unit.name, business_unit.id]]
      end
    end
  else
    @projects=selections_with_all(BusinessUnit, :name)
  end
  if params[:project]==nil
    project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
    @business_unit_id = "-1"
  else
    if params[:project][:selected] == "-1"
      project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      @business_unit_id = "-1"
    else
      project_selected=params[:project][:selected]
      @business_unit_id=project_selected
    end
  end

  if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
    @site_executives=selections_with_all_active(Personnel, :name)
    if params[:site_executive]==nil
      @executive=-1
    elsif params[:site_executive][:picked]==-1
      @executive=-1
    else
      @executive=params[:site_executive][:picked].to_i
    end
    if @executive==-1
      @leads_generated_raw=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
      @leads_generated=@leads_generated_raw.group("leads.source_category_id").count
    else
      @leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
      @leads_generated=@leads_generated_raw.group("leads.source_category_id").count
    end
  else
    @leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
    @leads_generated=@leads_generated_raw.group("leads.source_category_id").count
  end
  @site_visited_from_leads_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id").count
  @booked_from_leads_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true).group("leads.source_category_id").count
  @lost_from_leads_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id").count
  @qualified_from_leads_generated=@leads_generated_raw.where.not(qualified_on: nil).group('leads.source_category_id').count
  @isv_from_leads_generated=@leads_generated_raw.where.not(interested_in_site_visit_on: nil).group('leads.source_category_id').count

  total_sources=@leads_generated.keys.uniq

  all_sources=[]
  facebook_source=SourceCategory.find_by(organisation_id: 1, description: 'FACEBOOK')
  if total_sources.include?(facebook_source.id)
    all_sources+=[facebook_source.id]
  end
  facebook_campaigns=SourceCategory.where(predecessor: facebook_source.id)
  facebook_campaigns.each do |facebook_campaign|
    if total_sources.include?(facebook_campaign.id)
    all_sources+=[facebook_campaign.id]
    end
    facebook_adsets=SourceCategory.where(predecessor: facebook_campaign.id)
    facebook_adsets.each do |adset|
      if total_sources.include?(adset.id)
      all_sources+=[adset.id]
      end
      facebook_ads=SourceCategory.where(predecessor: adset.id)
      facebook_ads.each do |ad|
        if total_sources.include?(ad.id)
        all_sources+=[ad.id]
        end
      end
    end
  end

  spend_array=[]

  ad_accounts=['836531817211431', '7714807368559327', '426767712305587', '592042111747674', '1095385955203355']

  ad_accounts.each do |ad_account|
  url_string_1="https://graph.facebook.com/v14.0/act_"
  url_string_2="/insights?level=ad&adset&campaign%2C&account&time_range=%7B%22since%22%3A%22"
  url_string_3="%22%2C%22until%22%3A%22"
  url_string_4="%22%7D&fields=campaign_name%2Cspend%2Creach%2Cimpressions%2Cclicks%2Ccpc%2Cctr%2Cfrequency%2Cad_id%2Cad_name%2Cadset_id%2Cadset_name&access_token=EAAyexB6elyEBOwP97Q5J7K1pZCgkntNSZBcDIQ3WdZB6uSoV5L3ZAZBTLMDBfmZAVEZCC5t4uUE7ZCrOt534hP3CnZCfIxda4Udy5QdUbVBzplchccZBYy6Dmyr4iZBjV5uSFpqZB7zfRyuBtQAqPjAemIcql7ZBmUwClYmRhZBt70D9VIjjhZCF5rRIOiiddx1LeEZD"
  url_string=url_string_1+ad_account+url_string_2+(@from.to_date.strftime('%Y-%m-%d'))+url_string_3+(@to.to_date.strftime('%Y-%m-%d'))+url_string_4
  result = HTTParty.get(url_string)
  spend_array+=result['data']
  end


  @source_tree={}
  successors=[]
  successor_chain=0
  all_sources.each do |source|
    if @leads_generated[source]==nil
      leads_generated=0
    else
      leads_generated=@leads_generated[source]
    end
    if @site_visited_from_leads_generated[source]==nil
      site_visited_from_leads_generated=0
    else
      site_visited_from_leads_generated=@site_visited_from_leads_generated[source]
    end
    if @booked_from_leads_generated[source]==nil
      booked_from_leads_generated=0
    else
      booked_from_leads_generated=@booked_from_leads_generated[source]
    end
    if @lost_from_leads_generated[source]==nil
      lost_from_leads_generated=0
    else
      lost_from_leads_generated=@lost_from_leads_generated[source]
    end
    if @qualified_from_leads_generated[source]==nil
      qualified_leads_from_generated=0
    else
      qualified_leads_from_generated=@qualified_from_leads_generated[source]
    end
    if @isv_from_leads_generated[source]==nil
      isv_leads_from_generated=0
    else
      isv_leads_from_generated=@isv_from_leads_generated[source]
    end

    ad_hash=spend_array.select{|ad_detail| ad_detail["ad_id"] == FacebookAd.find_by_source_category_id(source).try(:ad_id) }[0]

    if ad_hash==nil
      ad_spend=0
    elsif ad_hash['spend']==nil
      ad_spend=0
    else
      ad_spend=ad_hash['spend'].to_i
    end

    if ad_hash==nil
      reach=0
    elsif ad_hash['reach']==nil
      reach=0
    else
      reach=ad_hash['reach'].to_i
    end

    if ad_hash==nil
      impressions=0
    elsif ad_hash['impressions']==nil
      impressions=0
    else
      impressions=ad_hash['impressions'].to_i
    end

    if ad_hash==nil
      clicks=0
    elsif ad_hash['clicks']==nil
      clicks=0
    else
      clicks=ad_hash['clicks'].to_i
    end

    predecessor_id=@sources.find(source).predecessor
    successors=[]
    if predecessor_id==nil && @source_tree[source]==nil
      @source_tree[source]=[leads_generated,leads_generated,{},site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated,qualified_leads_from_generated,qualified_leads_from_generated,isv_leads_from_generated,isv_leads_from_generated,ad_spend,ad_spend,reach,reach,impressions,impressions,clicks,clicks]
    elsif predecessor_id==nil
      @source_tree[source][1]=leads_generated
      @source_tree[source][4]=site_visited_from_leads_generated
      @source_tree[source][6]=booked_from_leads_generated
      @source_tree[source][8]=lost_from_leads_generated
      @source_tree[source][10]=qualified_leads_from_generated
      @source_tree[source][12]=isv_leads_from_generated
      @source_tree[source][14]=ad_spend
      @source_tree[source][16]=reach
      @source_tree[source][18]=impressions
      @source_tree[source][20]=clicks
    else
      successors+=[source]
      until predecessor_id==nil do
        predecessor=@sources.find(predecessor_id)
        successors+=[predecessor_id]
        predecessor_id=predecessor.predecessor
      end
      successors=successors.reverse
      successor_chain=nil
      @source=source
      successors.each do |successor|
        if successor==successors.first
          if @source_tree[successor]==nil
            @source_tree[successor]=[leads_generated,0,{},site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0,ad_spend,0,reach,0,impressions,0,clicks,0]
          else
            @source_tree[successor][0]=@source_tree[successor][0]+leads_generated
            @source_tree[successor][3]=@source_tree[successor][3]+site_visited_from_leads_generated
            @source_tree[successor][5]=@source_tree[successor][5]+booked_from_leads_generated
            @source_tree[successor][7]=@source_tree[successor][7]+lost_from_leads_generated
            @source_tree[successor][9]=@source_tree[successor][9]+qualified_leads_from_generated
            @source_tree[successor][11]=@source_tree[successor][11]+isv_leads_from_generated
            @source_tree[successor][13]=@source_tree[successor][13]+ad_spend
            @source_tree[successor][15]=@source_tree[successor][15]+reach
            @source_tree[successor][17]=@source_tree[successor][17]+impressions
            @source_tree[successor][19]=@source_tree[successor][19]+clicks
          end
        successor_chain=@source_tree[successor][2]
        else
          if successor_chain[successor]==nil
            if successor==successors.last
                successor_chain[successor]=[leads_generated,leads_generated,{},site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated, qualified_leads_from_generated, qualified_leads_from_generated, isv_leads_from_generated, isv_leads_from_generated, ad_spend, ad_spend, reach, reach, impressions, impressions, clicks, clicks]
            else
              successor_chain[successor]=[leads_generated,0,{},site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0,ad_spend,0,reach,0,impressions,0,clicks,0]
            end
          else
            successor_chain[successor][0]=successor_chain[successor][0]+leads_generated
            successor_chain[successor][3]=successor_chain[successor][3]+site_visited_from_leads_generated
            successor_chain[successor][5]=successor_chain[successor][5]+booked_from_leads_generated
            successor_chain[successor][7]=successor_chain[successor][7]+lost_from_leads_generated
            successor_chain[successor][9]=successor_chain[successor][9]+qualified_leads_from_generated
            successor_chain[successor][11]=successor_chain[successor][11]+isv_leads_from_generated
            successor_chain[successor][13]=successor_chain[successor][13]+ad_spend
            successor_chain[successor][15]=successor_chain[successor][15]+reach
            successor_chain[successor][17]=successor_chain[successor][17]+impressions
            successor_chain[successor][19]=successor_chain[successor][19]+clicks
          end
        successor_chain=successor_chain[successor][2]
        end
      end
    end
  end
  @source_tree=Hash[@source_tree.sort_by{|k, v| v[0]}.reverse]
end

  def maintainance_bill_report_index
  	@customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.full_name, flat.id]]
      end
    end
    @customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
    if request.post?
      @flat_id=params[:flat][:flat_id][0]
      @maintainance_bills=MaintainenceBill.where(flat_id: @flat_id.to_i).sort_by{|maintainance_bill| maintainance_bill.date}
      @flat=Flat.find(@flat_id.to_i)
      @money_receipts=MoneyReceipt.where(flat_id: @flat_id.to_i).sort_by{|money_receipt| money_receipt.date}
      @both_documents=@maintainance_bills+@money_receipts
      @both_documents=@both_documents.sort_by{|document| document.date}
    end
  end

  # def populate_bill_report
  # 	@flat_id=params[:id]
  # 	@maintainance_bills=MaintainenceBill.where(flat_id: @flat_id.to_i).sort_by{|maintainance_bill| maintainance_bill.date}
  # 	@customer=Flat.find(@flat_id.to_i)
  #   @money_receipts=MoneyReceipt.where(flat_id: @flat_id.to_i).sort_by{|money_receipt| money_receipt.date}
  # 	@both_documents=@maintainance_bills+@money_receipts
  #   @both_documents=@both_documents.sort_by{|document| document.date}
  # 	respond_to do |format|
  #       format.js { render :action => "populate_bill_report"}
  #   end
  # end

  def individual_customer_ledger
    @flat_id=params[:format]
    @maintainance_bills=MaintainenceBill.where(flat_id: @flat_id.to_i)
    @customer=Flat.find(params[:format])
    @money_receipts=MoneyReceipt.where(flat_id: @flat_id.to_i)
    @maintenance_credit_notes=MaintenanceCreditNoteEntry.where(lead_id: Flat.find(@flat_id).lead_id)
    @both_documents=@maintainance_bills+@money_receipts+@maintenance_credit_notes
    @both_documents=@both_documents.sort_by{|document| document.date}
  end

  def individual_customer_ledger_with_interest
    @flat_id=params[:format]
    @maintainance_bills=MaintainenceBill.where(flat_id: @flat_id.to_i)
    @customer=Flat.find(params[:format])
    @money_receipts=MoneyReceipt.where(flat_id: @flat_id.to_i)
    @maintenance_credit_notes=MaintenanceCreditNoteEntry.where(lead_id: Flat.find(@flat_id).lead_id)
    @both_documents=@maintainance_bills+@money_receipts+@maintenance_credit_notes
    @both_documents=@both_documents.sort_by{|document| document.date}
  end

  def outstanding_report_index
    if params[:business_unit]==nil
    @flats=Flat.includes(:reminder_logs, :block =>[:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'}).where.not(lead_id: nil)
    @business_units=selections(BusinessUnit, :name)
    @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @business_units=selections(BusinessUnit, :name)
      @flats=Flat.includes(:reminder_logs, :block =>[:business_unit]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where.not(lead_id: nil)
    end
  end

  def outstanding_reminder
    flat_ids = params[:flat_ids]
    whatsapps_sent = 0
    sent_customers = ''
    whatsapps_sent_to_customers = ''
    flat_ids.each do |flat|
      data = Flat.find(flat.to_i)
      lead = Lead.find(data.lead_id)
      if params[:commit] == 'No Reminder'
        flat = Flat.find(flat.to_i)
        flat.update(no_reminder: true)
        sent_customers = 'No Reminder marking done.'
      elsif params[:commit] == '7d Reminder'
        flat = Flat.find(flat.to_i)
        flat.update(no_reminder: nil)
        sent_customers = '7 Days Reminder markind done.'
      elsif params[:commit] == '3d Reminder'
        flat = Flat.find(flat.to_i)
        flat.update(no_reminder: false)
        sent_customers = '3 Days Reminder marking done.'
      elsif params[:commit] == 'Send E-mail Reminder'
        if lead.email == nil || lead.email == ''
        else
          UserMailer.bulk_outstanding_reminder(data).deliver
          reminder_log = ReminderLog.new
          reminder_log.flat_id = flat.to_i
          reminder_log.sent_on = DateTime.now
          reminder_log.save
        end
        sent_customers = 'Email Reminder sent successfully.'
      elsif params[:commit] == 'Send Whatsapp Reminder'
        if lead.mobile == nil || lead.mobile == '' || whatsapps_sent > 5
        else
          message = 'Dear '+lead.name.to_s+",\n"+'Your payment amounting to Rs.'+(data.outstanding).to_s+' for your apartment '+data.name.to_s+"-"+(data.block.name)+', in '+(data.block.business_unit.name)+' is due. Kindly make the payment at the earliest to avoid any complication or extra charges.'+"\n"+"\n"+'Regards,' +"\n"+"Rupsa Banerjee"+"\n"+"9007576657"+"\n"+'The Jain Group'
          urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
            customer_result = HTTParty.post(urlstring,
               :body => { :to_number => '+91'+lead.mobile,
                 :message => message,
                  :type => "text"
                  }.to_json,
                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
          whatsapps_sent += 1
          reminder_log = ReminderLog.new
          reminder_log.flat_id = flat.to_i
          reminder_log.sent_on = DateTime.now
          reminder_log.whatsapp = true
          reminder_log.save
          if customer_result["sent"]
            if whatsapps_sent_to_customers == ''
              whatsapps_sent_to_customers += 'WhatsApp sent successfully to:'+"\n"+lead.name+"\n"
            else
              whatsapps_sent_to_customers += lead.name+"\n"
            end
            sent_customers += 'WhatsApp sent successfully to:'+lead.name
          end
          sleep(3)
        end
      end
    end
    if whatsapps_sent_to_customers == ''
    else
      urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
      result = HTTParty.post(urlstring,
         :body => { :to_number => '+91'+current_personnel.mobile,
           :message => whatsapps_sent_to_customers,
            :type => "text"
            }.to_json,
            :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
    end

    flash[:success] = sent_customers
    redirect_to :back
  end

  def reminder_log_index
    if params[:business_unit]==nil
      @reminder_logs=ReminderLog.includes(:flat => [:block => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:reminder_log][:from]
      @business_units=selections(BusinessUnit, :name)
      @to=params[:reminder_log][:to]
      @reminder_logs=ReminderLog.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where('reminder_logs.sent_on >= ? and reminder_logs.sent_on <= ?', @from, @to)
    end
  end

  def maintenance_bill_register
    if params[:business_unit]==nil
      @maintainance_bills=MaintainenceBill.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:maintenance_bill][:from]
      @business_units=selections(BusinessUnit, :name)
      @to=params[:maintenance_bill][:to]
      @maintainance_bills=MaintainenceBill.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where('maintainence_bills.date >= ? and maintainence_bills.date <= ?', @from, @to)
    end
  end

  def particular_maintenance_bill_destroy
    maintenance_bill=MaintainenceBill.find(params[:format])
    maintenance_bill.destroy

    flash[:success]='Bill deleted successfully'
    redirect_to report_maintenance_bill_register_url
  end

  def bulk_maintenance_bill_delete
    params[:maintenance_bill_ids].each do |maintenance_bill_id|
      MaintainenceBill.find(maintenance_bill_id).destroy
    end

    flash[:success]='Bulk Maintenance Bill deleted successfully'
    redirect_to report_maintenance_bill_register_url
  end

  def money_receipt_register
    if params[:business_unit]==nil
      @money_receipts=MoneyReceipt.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
      @from=Time.now.beginning_of_month.to_date
      @to=Time.now.end_of_month.to_date
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:money_receipt][:from]
      @to=params[:money_receipt][:to]
      @business_units=selections(BusinessUnit, :name)
      @money_receipts=MoneyReceipt.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id,id: @business_unit_id.to_i}).where('money_receipts.date >= ? and money_receipts.date <= ?', @from, @to)
    end
  end

  def particular_money_receipt_destroy
    money_receipt=MoneyReceipt.find(params[:format])
    money_receipt.destroy

    flash[:success]='Money Receipt deleted successfully'
    redirect_to report_money_receipt_register_url
  end

  def money_receipt_bulk_deletion
    params[:money_receipt_ids].each do|money_receipt_id|
      MoneyReceipt.find(money_receipt_id).destroy
    end
    flash[:success]='Bulk Money Receipt deleted successfully'
    redirect_to report_money_receipt_register_url
  end

  def export_maintenance_outstanding_report
    @flats=Flat.includes(:block =>[:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where.not(lead_id: nil)
    respond_to do |format|
        format.xls
    end
  end

  def individual_remarks_edit
    @flat=Flat.find(params[:format])
    @flat_action='individual_flat_remarks_edit'
  end

  def individual_flat_remarks_edit
    flat = Flat.find(params[:flat_id])
    flat.update(remarks: params[:remarks])

    flash[:success]=' remarks updated successfully'
    redirect_to report_outstanding_report_index_url
  end

  def money_receipt_submit
    if params[:commit]=='View Details'
      redirect_to controller: 'report', action: 'money_receipt_register', params: request.request_parameters
    elsif params[:commit]=='Last 6 month status'
      redirect_to controller: 'report', action: 'maintenance_collection_graph', params: request.request_parameters
    end
  end

  def maintenance_collection_graph
    @series=[]
    months=[]
    total_hash={}
    total_array=[]

    month=Time.now.month
    year=Time.now.year

    month_count=5
    @months=[]

    6.times do |index|
      year=((Time.now)-(month_count.months)).year
      month=((Time.now)-(month_count.months)).month
      total_array+=[MoneyReceipt.joins(:flat => [:block => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where("extract(year from money_receipts.created_at) = ? AND extract(month from money_receipts.created_at) = ?", year, month).count]
      month_count=month_count-1
      p total_array
    end

    total_hash[:name]='Total'
    total_hash[:data]=total_array
    month_count=5
    projects=['Dream Apartments-HO','Dream Eco City','Dream Exotica', 'Dream Palazzo', 'Dream Residency Manor', 'Dream Vally']
    projects.each do |site|
      money_receipts_hash={}
      money_receipts_data=[]
      @months=@months+[Date::MONTHNAMES[((Time.now)-(month_count.months)).month]]
      year=((Time.now)-(month_count.months)).year
      month=((Time.now)-(month_count.months)).month
      money_receipts_hash[:name]=site
      money_receipts_data+=[MoneyReceipt.joins(:flat => [:block => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: site}).where("extract(year from money_receipts.created_at) = ? AND extract(month from money_receipts.created_at) = ?", year, month).count]
      money_receipts_hash[:data]=money_receipts_data
      month_count=month_count-1
      money_receipts_hash[:visible]=false
      @series+=[money_receipts_hash]
    end

    @series+=[total_hash]
    @series=@series.to_json.html_safe
    @months=@months.to_json.html_safe

    # @business_unit_id=params[:business_unit][:business_unit_id]
    # total_hash={}
    # total_hash[:name]='Total'

    # money_receipts_hash={}
    # money_receipts_data=[]
    # money_receipts_hash[:name]='Maintenance Money Receipts'
    # month_count=5
    # @months=[]

    # count=6
    # 6.times do
    #   @months=@months+[Date::MONTHNAMES[((Time.now)-(month_count.months)).month]]
    #   year=((Time.now)-(month_count.months)).year
    #   month=((Time.now)-(month_count.months)).month
    #   money_receipts_data+=[MoneyReceipt.joins(:flat => [:block => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where("extract(year from money_receipts.created_at) = ? AND extract(month from money_receipts.created_at) = ?", year, month).count]
    #   month_count=month_count-1
    # end

    # money_receipts_hash[:data]=money_receipts_data
    # @series=[money_receipts_hash].to_json.html_safe
    # @months=@months.to_json.html_safe
  end

  def monthly_target_index
    @monthly_targets = MonthlyTarget.all
  end

  def monthly_target_new
    @business_units = selections(BusinessUnit, :name)
  end

  def monthly_target_create
    monthly_target = MonthlyTarget.new
    monthly_target.business_unit_id = params[:business_unit][:business_unit_id]
    monthly_target.month = params[:date][:month]
    monthly_target.year = params[:date][:year]
    monthly_target.leads = params[:monthly_target][:leads]
    monthly_target.bookings =  params[:monthly_target][:booking]
    monthly_target.collection = params[:monthly_target][:collection]
    monthly_target.activities = params[:monthly_target][:activity]
    monthly_target.save

    redirect_to report_monthly_target_index_url

  end

  def monthly_target_edit
    @monthly_target = MonthlyTarget.find(params[:format])
    @business_units = selections(BusinessUnit, :name)
  end

  def monthly_target_update
    @monthly_target = MonthlyTarget.find(params[:monthly_target_id])
    @monthly_target.update(month: params[:date][:month], year: params[:date][:year], leads: params[:monthly_target][:leads], bookings: params[:monthly_target][:booking], collection: params[:monthly_target][:collection], activities: params[:monthly_target][:activity], business_unit_id: params[:business_unit][:business_unit_id])

    flash[:success]='Monthly Target Updated successfully'
    redirect_to report_monthly_target_index_url

  end

  def progress_bar
    if params[:report_type] == nil
    else
      @report_type = params[:report_type]
      @do_monthly_target = MonthlyTarget.includes(:business_unit).where(:business_units => {name: 'Dream One'}).where('monthly_targets.month = ?', Date.today.month)[0]
      @dwc_monthly_target = MonthlyTarget.includes(:business_unit).where(:business_units => {name: 'Dream World City'}).where('monthly_targets.month = ?', Date.today.month)[0]
      if @do_monthly_target.bookings_achieved == nil
        @do_booking_percentage = 0
      else
        if @do_monthly_target.bookings_achieved > @do_monthly_target.bookings
          @do_booking_percentage = 100
        else
          @do_booking_percentage = ((@do_monthly_target.bookings_achieved.to_f/@do_monthly_target.bookings.to_f)*100)
        end
      end
      if @do_monthly_target.leads_achieved == nil
        @do_leads_percentage = 0
      else
        if @do_monthly_target.leads_achieved > @do_monthly_target.leads
          @do_leads_percentage = 100
        else
          @do_leads_percentage = ((@do_monthly_target.leads_achieved.to_f/@do_monthly_target.leads.to_f)*100)
        end
      end
      if @do_monthly_target.collection_achieved == nil
        @do_collection_percentage = 0
      else
        if @do_monthly_target.collection_achieved > @do_monthly_target.collection
          @do_collection_percentage = 100
        else
          @do_collection_percentage = ((@do_monthly_target.collection_achieved.to_f/@do_monthly_target.collection.to_f)*100)
        end
      end
      if @do_monthly_target.activities_achieved  == nil
        @do_activities_achieved = 0
      else
        @do_activities_achieved = ((@do_monthly_target.activities_achieved.to_f/@do_monthly_target.activities.to_f)*100)
      end
      if @dwc_monthly_target.bookings_achieved == nil
        @dwc_booking_percentage = 0
      else
        if @dwc_monthly_target.bookings_achieved > @dwc_monthly_target.bookings
          @dwc_booking_percentage = 100
        else
          @dwc_booking_percentage = ((@dwc_monthly_target.bookings_achieved.to_f/@dwc_monthly_target.bookings.to_f)*100)
        end
      end
      if @dwc_monthly_target.leads_achieved == nil
        @dwc_leads_percentage = 0
      else
        if @dwc_monthly_target.leads_achieved > @dwc_monthly_target.leads
          @dwc_leads_percentage = 100
        else
          @dwc_leads_percentage = ((@dwc_monthly_target.leads_achieved.to_f/@dwc_monthly_target.leads.to_f)*100)
        end
      end
      if @dwc_monthly_target.collection_achieved == nil
        @dwc_collection_percentage = 0
      else
        if @dwc_monthly_target.collection_achieved > @dwc_monthly_target.collection
          @dwc_collection_percentage = 100
        else
          @dwc_collection_percentage = ((@dwc_monthly_target.collection_achieved.to_f/@dwc_monthly_target.collection.to_f)*100)
        end
      end
      if @dwc_monthly_target.activities_achieved  == nil
        @dwc_activities_achieved = 0
      else
        @dwc_activities_achieved = ((@dwc_monthly_target.activities_achieved.to_f/@dwc_monthly_target.activities.to_f)*100)
      end
    end
  end

  def credit_note_register
    if params[:business_unit]==nil
      @credit_note_entries=MaintenanceCreditNoteEntry.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @business_units=selections(BusinessUnit, :name)
      @credit_note_entries=MaintenanceCreditNoteEntry.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id.to_i})
    end
    # @credit_note_entries=MaintenanceCreditNoteEntry.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  def connected_calls
    if params[:from] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @connected_calls = {}
    else
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @connected_calls = {}
      Personnel.where(organisation_id: 1, access_right: 2, expanded: true).each do |personnel|
        not_connected_calls = TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: personnel.mobile, call_type: "Missed", call_outcome: "LegB").where('duration > ?', 0.0).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from, @to.beginning_of_day+1.day).count
        TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: personnel.mobile, call_type: "Missed", call_outcome: "LegA").where('duration > ?', 0.0).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from, @to.beginning_of_day+1.day).sort_by{|s| s.lead_id}.each do |telephony_call|
          if FollowUp.where(lead_id: telephony_call.lead_id, telephony_call_id: telephony_call.id) == []
          else
            not_connected_calls += 1
          end
        end
        connected_calls = TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: personnel.mobile, call_type: "Connected").where('telephony_calls.start_time >= ? AND telephony_calls.start_time < ?', @from, @to.end_of_day).count
        total_calls = (not_connected_calls+connected_calls)
        if total_calls == 0
        else
          connected_call_percentage = ((connected_calls.to_f/total_calls.to_f)*100).round
          @connected_calls[personnel.name] = [total_calls, connected_calls, connected_call_percentage]
        end
      end
    end
  end

  def import_call_logs
    executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
    @executives=[]
    executives.each do |executive|
      @executives+=[[executive.name, executive.id]]
    end
    @executives.sort
  end

  def call_logs_import
    DailyCalling.import([params[:file], params[:personnel_id]])
    flash[:success]="Call Logs imported!"
    redirect_to :back
  end

  def call_audit_report
    if current_personnel.status == "Back Office"
      @executives = [[current_personnel.name, current_personnel.id]]
    else
      executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ? ', nil, 2, 4)
      @executives=[]
      executives.each do |executive|
        @executives+=[[executive.name, executive.id]]
      end
    end
    @executives.sort
    if params[:personnel_id] == nil
      @audit_report = {}
      @from = DateTime.now.beginning_of_month
      @to = DateTime.now
    else
      @executive = params[:personnel_id].to_i
      from = params[:from]
      to = params[:to]
      @from = Date.parse(from)
      @to = Date.parse(to)
      if @to <= DateTime.now.to_date.beginning_of_week-1.day
        @audit_report = {}
        total_calls = 0
        total_matched = 0
        total_unmatched = 0
        # total_not_called = 0
        crm_connected_calls = 0
        crm_connected_call_matched = 0
        crm_connected_call_unmatched = 0
        connected_unmatched_lead_ids = {}
        # crm_connected_call_not_called = 0
        crm_connected_call_duration = 0
        crm_not_connected_calls = 0
        crm_not_connected_call_matched = 0
        crm_not_connected_call_unmatched = 0
        not_connected_unmatched_lead_ids = {}
        # crm_not_connected_call_not_called = 0
        @common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Incoming Call facility is not available in this number', 'Invalid Number', "", "Lead Rescheduled", "Lead transferred"]
        (@from..@to).each do |date_range|
          daily_callings = DailyCalling.where(personnel_id: @executive).where('date >= ? AND date < ?', date_range.to_datetime.beginning_of_day, date_range.to_datetime+1.day)
          followups = FollowUp.where(personnel_id: @executive).where('communication_time >= ? AND communication_time < ?', date_range.to_datetime.beginning_of_day, date_range.to_datetime+1.day)
          followups.each do |followup|
            connected_call = false
            not_connected_call = false
            common_followup_remarks_matched = false
            @common_followup_remarks.each do |common_followup_remark|
              if common_followup_remark == followup.remarks
                common_followup_remarks_matched = true
                break
              else
                common_followup_remarks_matched = false
              end
            end
            if common_followup_remarks_matched == true
            # if @common_followup_remarks.include?(followup.remarks)
              crm_not_connected_calls += 1
              if daily_callings.where(called_number: followup.lead.mobile).count > 1
                daily_callings.where(called_number: followup.lead.mobile).each do |daily_calling|
                  if daily_calling.duration > 0.0
                    not_connected_call = false
                  else
                    not_connected_call = true
                    break
                  end
                end
                if not_connected_call == true
                  crm_not_connected_call_matched += 1
                else
                  if not_connected_unmatched_lead_ids[date_range] == nil
                    not_connected_unmatched_lead_ids[date_range] = [followup.lead_id]
                  else
                    not_connected_unmatched_lead_ids[date_range] += [followup.lead_id]
                  end
                  crm_not_connected_call_unmatched += 1
                end
              else
                if daily_callings.where(called_number: followup.lead.mobile) == []
                  crm_not_connected_call_unmatched += 1
                  if not_connected_unmatched_lead_ids[date_range] == nil
                    not_connected_unmatched_lead_ids[date_range] = [followup.lead_id]
                  else
                    not_connected_unmatched_lead_ids[date_range] += [followup.lead_id]
                  end
                  # crm_not_connected_call_not_called += 1
                else
                  if daily_callings.where(called_number: followup.lead.mobile)[0].duration > 0.0
                    crm_not_connected_call_unmatched += 1
                    if not_connected_unmatched_lead_ids[date_range] == nil
                      not_connected_unmatched_lead_ids[date_range] = [followup.lead_id]
                    else
                      not_connected_unmatched_lead_ids[date_range] += [followup.lead_id]
                    end
                  else
                    crm_not_connected_call_matched += 1
                  end
                end
              end
            else
              crm_connected_calls += 1
              if daily_callings.where(called_number: followup.lead.mobile).count > 1
                daily_callings.where(called_number: followup.lead.mobile).each do |daily_calling|
                  if daily_calling.duration > 0.0
                    connected_call = true
                    crm_connected_call_duration += daily_calling.duration
                    break
                  else
                    connected_call = false
                  end
                end
                if connected_call == true
                  crm_connected_call_matched += 1
                else
                  crm_connected_call_unmatched += 1
                  if connected_unmatched_lead_ids[date_range]== nil
                    connected_unmatched_lead_ids[date_range] = [followup.lead_id]
                  else
                    connected_unmatched_lead_ids[date_range] += [followup.lead_id]
                  end
                end
              else
                if daily_callings.where(called_number: followup.lead.mobile) == []
                  crm_connected_call_unmatched += 1
                  if connected_unmatched_lead_ids[date_range]== nil
                    connected_unmatched_lead_ids[date_range] = [followup.lead_id]
                  else
                    connected_unmatched_lead_ids[date_range] += [followup.lead_id]
                  end
                  # crm_connected_call_not_called += 1
                else
                  if daily_callings.where(called_number: followup.lead.mobile)[0].duration > 0.0
                    crm_connected_call_matched += 1
                    crm_connected_call_duration += daily_callings.where(called_number: followup.lead.mobile)[0].duration
                  else
                    crm_connected_call_unmatched += 1
                    if connected_unmatched_lead_ids[date_range]== nil
                      connected_unmatched_lead_ids[date_range] = [followup.lead_id]
                    else
                      connected_unmatched_lead_ids[date_range] += [followup.lead_id]
                    end
                  end
                end
              end
            end
          end
        end
        hours = (crm_connected_call_duration/60).round
        minutes = (crm_connected_call_duration%60).round
        total_duration = "("+hours.to_s+":"+minutes.to_s+")"
        connected_unmatched = [crm_connected_call_unmatched, connected_unmatched_lead_ids]
        not_connected_unmatched = [crm_not_connected_call_unmatched, not_connected_unmatched_lead_ids]
        total_calls = crm_connected_calls+crm_not_connected_calls
        total_matched = crm_connected_call_matched+crm_not_connected_call_matched
        total_unmatched = crm_connected_call_unmatched+crm_not_connected_call_unmatched
        # total_not_called = crm_connected_call_not_called+crm_not_connected_call_not_called
        @audit_report = {"CRM Followups" => [total_calls, total_unmatched, total_matched], "CRM Connected Calls" => [crm_connected_calls, connected_unmatched, crm_connected_call_matched.to_s+total_duration.to_s], "CRM Not connected calls" => [crm_not_connected_calls, not_connected_unmatched, crm_not_connected_call_matched]}
      else
        flash[:danger] = "Max date range should be last sunday."
        redirect_to :back
      end
    end
  end

  def detailed_audit_report
    if params.select{|key, value| value == ">" }.keys[0] != nil
      redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])
    else
      @leads_with_dates = params[:lead_data]
    end
  end

  def em_report_index
    if params[:from] == nil
      @from = DateTime.now.beginning_of_month
      @to = DateTime.now
    else
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @telecaller_data = {}
      @site_executive_data = {}
      source_categories = SourceCategory.where(organisation_id: current_personnel.organisation_id, inactive: [nil, false]).where('heirarchy like ?', '%Online%').pluck(:id).uniq
      all_sources = source_categories
      all_sources += [nil]
      @personnels = []
      Personnel.where(organisation_id: 1).where('access_right = ? OR access_right is ?', 2, nil).each do |personnel|
        if personnel.name == "Tapan Samanta" || personnel.name == "Rahul Singh" || personnel.name == "Nitesh Maheshwari" || personnel.name == "Kazi Shahadat Hossain"
        else
          @personnels += [personnel]
        end
      end
      @personnels.each do |personnel|
        if personnel.access_right == 2
          if personnel.name == "Olivia De"
            dec_connected_calls = 0
            eb_connected_calls = 0
            dec_qualified = 0
            eb_qualified = 0
            dec_site_visited = 0
            eb_site_visited = 0
            dec_score = 0.00
            eb_score = 0.00
            dec_connected_calls = TelephonyCall.includes(:lead).where(:leads => {business_unit_id: 5}).where(agent_number: personnel.mobile, call_type: 'Connected').where('telephony_calls.start_time >= ? and telephony_calls.start_time < ?', @from.beginning_of_day, @to.end_of_day).count
            dec_connected_call_duration = TelephonyCall.includes(:lead).where(:leads => {business_unit_id: 5}).where(agent_number: personnel.mobile, call_type: 'Connected').where('telephony_calls.start_time >= ? and telephony_calls.start_time < ?', @from.beginning_of_day, @to.end_of_day).sum(:duration).round(2)
            dec_connected_call_duration = (dec_connected_call_duration/3600).round(2)
            dec_qualified = FollowUp.includes(:lead).where(:leads => {business_unit_id: 5, source_category_id: all_sources}, personnel_id: personnel.id, status: false, osv: true).where('leads.qualified_on >= ? AND leads.qualified_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
            dec_site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: 5, source_category_id: all_sources}, personnel_id: personnel.id, osv: true, status: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
            dec_score = ((dec_site_visited.to_f/dec_connected_calls.to_f)-1).round(2)
            eb_connected_calls = TelephonyCall.includes(:lead).where(:leads => {business_unit_id: 68}).where(agent_number: personnel.mobile, call_type: 'Connected').where('telephony_calls.start_time >= ? and telephony_calls.start_time < ?', @from.beginning_of_day, @to.end_of_day).count
            eb_connected_call_duration = TelephonyCall.includes(:lead).where(:leads => {business_unit_id: 68}).where(agent_number: personnel.mobile, call_type: 'Connected').where('telephony_calls.start_time >= ? and telephony_calls.start_time < ?', @from.beginning_of_day, @to.end_of_day).sum(:duration).round(2)
            eb_connected_call_duration = (eb_connected_call_duration/3600).round(2)
            eb_qualified = FollowUp.includes(:lead).where(:leads => {business_unit_id: 68, source_category_id: all_sources}, personnel_id: personnel.id, status: false, osv: true).where('leads.qualified_on >= ? AND leads.qualified_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
            eb_site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: 68, source_category_id: all_sources}, personnel_id: personnel.id, osv: true, status: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
            eb_score = ((eb_site_visited.to_f/eb_connected_calls.to_f)-1).round(2)
            @telecaller_data[personnel.name] = {"Project" => "Dream Eco City", "Role" => "Telecaller", "Connected" => dec_connected_calls, "Duration" => dec_connected_call_duration, "Qualified" => dec_qualified, "Site Visit" => dec_site_visited, "Score" => dec_score}
            @telecaller_data[personnel.name+"."] = {"Project" => "Ecocity Bungalow", "Role" => "Telecaller", "Connected" => eb_connected_calls, "Duration" => eb_connected_call_duration, "Qualified" => eb_qualified, "Site Visit" => eb_site_visited, "Score" => eb_score}
          else
            total_connected_calls = TelephonyCall.where(agent_number: personnel.mobile, call_type: 'Connected').where('start_time >= ? and start_time < ?', @from.beginning_of_day, @to.end_of_day).count
            total_connected_call_duration = TelephonyCall.where(agent_number: personnel.mobile, call_type: 'Connected').where('start_time >= ? and start_time < ?', @from.beginning_of_day, @to.end_of_day).sum(:duration).round(2)
            total_connected_call_duration = (total_connected_call_duration/3600).round(2)
            total_qualified = FollowUp.includes(:lead).where(:leads => {business_unit_id: personnel.business_unit_id, source_category_id: all_sources}, personnel_id: personnel.id, status: false, osv: true).where('leads.qualified_on >= ? AND leads.qualified_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
            total_site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: personnel.business_unit_id, source_category_id: all_sources}, personnel_id: personnel.id, status: nil, osv: true).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
            score = ((total_site_visited.to_f/total_connected_calls.to_f)-1).round(2)
            @telecaller_data[personnel.name] = {"Project" => personnel.business_unit.name, "Role" => "Telecaller", "Connected" => total_connected_calls, "Duration" => total_connected_call_duration, "Qualified" => total_qualified, "Site Visit" => total_site_visited, "Score" => score}
          end
        elsif personnel.access_right == nil
          if personnel.name == "RUPAM GOSWAMI" || personnel.name == "Subrata Das"
            dec_sv_conducted = 0
            dec_sale = 0
            eb_sv_conducted = 0
            eb_sale = 0
            dec_score = 0.00
            eb_score = 0.00
            dec_site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: 5, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq
            eb_site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: 68, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq
            dec_site_visited.each do |lead_id|
              lead = Lead.find(lead_id.to_i)
              if lead.follow_ups.where(personnel_id: personnel.id) == []
              else
                dec_sv_conducted += 1
                if lead.booked_on != nil && lead.lost_reason_id == nil
                  dec_sale += 1
                elsif lead.status == nil && lead.osv == false && lead.lost_reason_id == nil && lead.booked_on == nil
                  dec_sale += 1
                end
              end
            end
            if dec_sale == 0 || dec_sv_conducted == 0
              dec_score = 1
            else
              dec_score = ((dec_sale.to_f/dec_sv_conducted.to_f)-1).round(2)
            end
            eb_site_visited.each do |lead_id|
              lead = Lead.find(lead_id.to_i)
              if lead.follow_ups.where(personnel_id: personnel.id) == []
              else
                eb_sv_conducted += 1
                if lead.booked_on != nil && lead.lost_reason_id == nil
                  eb_sale += 1
                elsif lead.status == nil && lead.osv == false && lead.lost_reason_id == nil && lead.booked_on == nil
                  eb_sale += 1
                end
              end
            end
            if eb_sale == 0 || eb_sv_conducted == 0
              eb_score = 1
            else
              eb_score = ((eb_sale.to_f/eb_sv_conducted.to_f)-1).round(2)
            end
            @site_executive_data[personnel.name] = {"Project" => "Dream Eco City", "Role" => "Site Executive", "sv_conducted" => dec_sv_conducted, "total_sale" => dec_sale, "Score" => dec_score}
            @site_executive_data[personnel.name+"."] = {"Project" => "Ecocity Bungalow", "Role" => "Site Executive", "sv_conducted" => eb_sv_conducted, "total_sale" => eb_sale, "Score" => eb_score}
          elsif personnel.name == "Subhajit Patra"
            palazzo_sv_conducted = 0
            palazzo_sale = 0
            manor_sv_conducted = 0
            manor_sale = 0
            palazzo_score = 0.00
            manor_score = 0.00
            palazzo_site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: 7, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq
            manor_site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: 8, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq
            palazzo_site_visited.each do |lead_id|
              lead = Lead.find(lead_id.to_i)
              if lead.follow_ups.where(personnel_id: personnel.id) == []
              else
                palazzo_sv_conducted += 1
                if lead.booked_on != nil && lead.lost_reason_id == nil
                  palazzo_sale += 1
                elsif lead.status == nil && lead.osv == false && lead.lost_reason_id == nil && lead.booked_on == nil
                  palazzo_sale += 1
                end
              end
            end
            if palazzo_sale == 0 || palazzo_sv_conducted == 0
              palazzo_score = 1
            else
              palazzo_score = ((palazzo_sale.to_f/palazzo_sv_conducted.to_f)-1).round(2)
            end
            manor_site_visited.each do |lead_id|
              lead = Lead.find(lead_id.to_i)
              if lead.follow_ups.where(personnel_id: personnel.id) == []
              else
                manor_sv_conducted += 1
                if lead.booked_on != nil && lead.lost_reason_id == nil
                  manor_sale += 1
                elsif lead.status == nil && lead.osv == false && lead.lost_reason_id == nil && lead.booked_on == nil
                  manor_sale += 1
                end
              end
            end
            if manor_sale == 0 || manor_sv_conducted == 0
              manor_score = 1
            else
              manor_score = ((manor_sale.to_f/manor_sv_conducted.to_f)-1).round(2)
            end
            @site_executive_data[personnel.name] = {"Project" => "Dream Palazzo", "Role" => "Site Executive", "sv_conducted" => palazzo_sv_conducted, "total_sale" => palazzo_sale, "Score" => palazzo_score}
            @site_executive_data[personnel.name+"."] = {"Project" => "Dream Residency Manor", "Role" => "Site Executive", "sv_conducted" => manor_sv_conducted, "total_sale" => manor_sale, "Score" => manor_score}
          else
            total_sv_conducted = 0
            total_sale = 0
            site_visited_leads = FollowUp.includes(:lead).where(:leads => {business_unit_id: personnel.business_unit_id, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:lead_id).uniq
            site_visited_leads.each do |lead_id|
              lead = Lead.find(lead_id.to_i)
              if lead.follow_ups.where(personnel_id: personnel.id) == []
              else
                total_sv_conducted += 1
                if lead.booked_on != nil && lead.lost_reason_id == nil
                  total_sale += 1
                elsif lead.status == nil && lead.osv == false && lead.lost_reason_id == nil && lead.booked_on == nil
                  total_sale += 1
                end
              end
            end
            if total_sale == 0 || total_sv_conducted == 0
              score = 1
            else
              score = ((total_sale.to_f/total_sv_conducted.to_f)-1).round(2)
            end
            @site_executive_data[personnel.name] = {"Project" => personnel.business_unit.name, "Role" => "Site Executive", "sv_conducted" => total_sv_conducted, "total_sale" => total_sale, "Score" => score}
          end
        end
      end
    end
  end

  def sales_em
    if params[:from] == nil
      @from = DateTime.now.beginning_of_month
      @to = DateTime.now
      @gurukul_data = {}
    else
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @gurukul_data = {}
      personnels = Personnel.where(name: ["Moumita Mitra", "Shradhya Saha", "Lily John", "Rima Mandal"])
      personnels.each do |personnel|
        p personnel.name
        p "=================="
        if personnel.name == "Moumita Mitra" || personnel.name == "Shradhya Saha"
          fresh_facebook_leads = 0
          qualified_from_facebook = 0
          fresh_google_leads = 0
          qualified_from_google = 0
          online_fresh_leads = 0
          qualified_from_online = 0
          fresh_hoarding_leads = 0
          qualified_from_hoarding = 0
          fresh_newspaper_leads = 0
          qualified_from_newspaper = 0
          offline_fresh_leads = 0
          qualified_from_offline = 0
          
          fresh_facebook_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where('leads.generated_on >= ? AND leads.generated_on < ? AND source_categories.heirarchy like ?',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%FACEBOOK%").pluck(:lead_id).uniq.count
          # fresh_facebook_leads += Lead.includes(:personnel, :source_category, :follow_ups).where(:source_categories => {organisation_id: current_personnel.organisation_id}, :follow_ups => {lead_id: nil}).where(business_unit_id: 70, personnel_id: personnel.id).where(lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ? and source_categories.heirarchy like ?',(@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day, "%FACEBOOK%").count
          qualified_from_facebook = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {qualified_on: nil}).where('(leads.generated_on >= ? AND leads.generated_on < ? AND source_categories.heirarchy like ?)',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%FACEBOOK%").pluck(:lead_id).uniq.count
          fresh_google_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(personnel_id: personnel.id, :leads => {business_unit_id: 70, lost_reason_id: lost_reasons}).where('(leads.generated_on >= ? AND leads.generated_on < ?) AND (source_categories.heirarchy like ? OR source_categories.heirarchy like ?)',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%Google%", "%Super Receptionist%").pluck(:lead_id).uniq.count
          # fresh_google_leads += Lead.includes(:personnel, :source_category, :follow_ups).where(:source_categories => {organisation_id: current_personnel.organisation_id}, :follow_ups => {lead_id: nil}).where(business_unit_id: 70, personnel_id: personnel.id).where(lost_reason_id: lost_reasons).where('(leads.generated_on >= ? AND leads.generated_on < ?) and (source_categories.heirarchy like ? or source_categories.heirarchy like ?)',(@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day, "%Google%", "%Super Receptionist%").count
          qualified_from_google = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {qualified_on: nil}).where('(leads.generated_on >= ? AND leads.generated_on < ?) AND (source_categories.heirarchy like ? OR source_categories.heirarchy like ?)',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%Google%", "%Super Receptionist%").pluck(:lead_id).uniq.count
          online_fresh_leads = fresh_facebook_leads + fresh_google_leads
          qualified_from_online = qualified_from_facebook + qualified_from_google
          
          fresh_hoarding_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(personnel_id: personnel.id, :leads => {business_unit_id: 70, lost_reason_id: lost_reasons}).where('leads.generated_on >= ? AND leads.generated_on < ? AND source_categories.heirarchy like ?',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%Hoarding%").pluck(:lead_id).uniq.count
          qualified_from_hoarding = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {qualified_on: nil}).where('(leads.generated_on >= ? AND leads.generated_on < ? AND source_categories.heirarchy like ?)',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%Hoarding%").pluck(:lead_id).uniq.count
          fresh_newspaper_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(personnel_id: personnel.id, :leads => {business_unit_id: 70, lost_reason_id: lost_reasons}).where('leads.generated_on >= ? AND leads.generated_on < ? AND source_categories.heirarchy like ?',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%NewsPaper%").pluck(:lead_id).uniq.count
          qualified_from_newspaper = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {qualified_on: nil}).where('(leads.generated_on >= ? AND leads.generated_on < ? AND source_categories.heirarchy like ?)',@from.to_datetime-5.hours-30.minutes, (@to.to_datetime-5.hours-30.minutes)+1.day, "%NewsPaper%").pluck(:lead_id).uniq.count
          offline_fresh_leads = fresh_hoarding_leads + fresh_newspaper_leads
          qualified_from_offline = qualified_from_hoarding + qualified_from_newspaper
          @gurukul_data[personnel.name] = ["TC Level 1", online_fresh_leads, qualified_from_online, offline_fresh_leads, qualified_from_offline, 0, 0, 0, 0]
          p fresh_facebook_leads
          p fresh_google_leads
          p "====================================="
        else
          qualified_facebook_leads = 0
          site_visited_from_facebook = 0
          qualified_google_leads = 0
          site_visited_from_google = 0
          online_qualified_leads = 0
          site_visited_from_online = 0
          qualified_hoarding_leads = 0
          site_visited_from_hoarding = 0
          qualified_newspaper_leads = 0
          site_visited_from_newspaper = 0
          offline_qualified_leads = 0
          site_visited_from_offline = 0
          qualified_facebook_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where('(leads.qualified_on >= ? AND leads.qualified_on < ? AND source_categories.heirarchy like ?)',@from-5.hours-30.minutes, (@to-5.hours-30.minutes)+1.day, "%FACEBOOK%").pluck(:lead_id).uniq.count
          site_visited_from_facebook = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {site_visited_on: nil}).where('source_categories.heirarchy like ?', "%FACEBOOK%").pluck(:lead_id).uniq.count
          qualified_google_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where('(leads.qualified_on >= ? AND leads.qualified_on < ?) AND (source_categories.heirarchy like ? OR source_categories.heirarchy like ?)',@from-5.hours-30.minutes, (@to-5.hours-30.minutes)+1.day, "%Google%", "%Super Receptionist%").pluck(:lead_id).uniq.count
          site_visited_from_google = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {site_visited_on: nil}).where('(source_categories.heirarchy like ? OR source_categories.heirarchy like ?)',"%Google%", "%Super Receptionist%").pluck(:lead_id).uniq.count
          online_qualified_leads = qualified_facebook_leads + qualified_google_leads
          site_visited_from_online = site_visited_from_facebook + site_visited_from_google
          
          qualified_hoarding_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where('(leads.qualified_on >= ? AND leads.qualified_on < ? AND source_categories.heirarchy like ?)',@from-5.hours-30.minutes, (@to-5.hours-30.minutes)+1.day, "%Hoarding%").pluck(:lead_id).uniq.count
          site_visited_from_hoarding = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {site_visited_on: nil}).where('source_categories.heirarchy like ?', "%Hoarding%").pluck(:lead_id).uniq.count
          qualified_newspaper_leads = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where('(leads.qualified_on >= ? AND leads.qualified_on < ? AND source_categories.heirarchy like ?)',@from-5.hours-30.minutes, (@to-5.hours-30.minutes)+1.day, "%NewsPaper%").pluck(:lead_id).uniq.count
          site_visited_from_newspaper = FollowUp.includes(:personnel, :lead => [:source_category]).where(:leads => {business_unit_id: 70, lost_reason_id: lost_reasons}, personnel_id: personnel.id).where.not(:leads => {site_visited_on: nil}).where('source_categories.heirarchy like ?', "%NewsPaper%").pluck(:lead_id).uniq.count
          offline_qualified_leads = qualified_hoarding_leads + qualified_newspaper_leads
          site_visited_from_offline = site_visited_from_hoarding + site_visited_from_newspaper
          @gurukul_data[personnel.name] = ["TC Level 2", 0, 0, 0, 0, online_qualified_leads, site_visited_from_online, offline_qualified_leads, site_visited_from_offline]
        end
      end
    end
  end

  def export_detailed_audit_report
    @leads_with_dates = params[:lead_data]
    respond_to do |format|
        format.xls
    end
  end

  def call_report
    @personnels = []
    Personnel.where(organisation_id: 1, access_right: 2).each do |personnel|
      @personnels += [[personnel.name, personnel.id]]
    end
    if params[:personnel_id] == nil
      @personnel = []
      @personnel_id = -1
      @telephony_calls = {}
      @from = DateTime.now-2.days
      @to = DateTime.now
      @cut_before_connected = []
      @cut_after_one_ring = []
    else
      @personnel = Personnel.find(params[:personnel_id].to_i)
      @personnel_id = @personnel.id
      @from = params[:from].to_date
      @to = params[:to].to_date
      @telephony_calls = {}
      @cut_before_connected = []
      @cut_after_one_ring = []
      (@from..@to).each do |date|
        TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: @personnel.mobile, duration: 0.0, call_type: "None").where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', date, date.beginning_of_day+1.day).sort_by{|x| x.lead_id}.each do |telephony_call|
          if FollowUp.where(lead_id: telephony_call.lead_id, telephony_call_id: telephony_call.id) == []
          else
            @cut_before_connected += [telephony_call]
          end
        end
        TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: @personnel.mobile, call_type: "Missed", call_outcome: "LegA").where('duration <= ?', 30.0).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from, @to.beginning_of_day+1.day).sort_by{|s| s.lead_id}.each do |telephony_call|
          if FollowUp.where(lead_id: telephony_call.lead_id, telephony_call_id: telephony_call.id) == []
          else
            @cut_after_one_ring += [telephony_call]
          end
        end
      end
      # cut_before_connected = TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: @personnel.mobile, duration: 0.0, call_type: "None").where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from, @to.beginning_of_day+1.day).count
      cut_before_connected = @cut_before_connected.count
      only_cut_by_customer = TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: @personnel.mobile, call_type: "Missed", call_outcome: "LegB").where('duration > ?', 0.0).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from, @to.beginning_of_day+1.day).count
      # cut_after_one_ring = TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: @personnel.mobile, call_type: "Missed", call_outcome: "LegA").where('duration <= ?', 5.0).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from, @to.beginning_of_day+1.day).count
      cut_after_one_ring = @cut_after_one_ring.count
      call_cut_after_customer_disconnected = TelephonyCall.includes(:lead).where.not(:leads => {source_category_id: 868}).where(agent_number: @personnel.mobile, call_type: "Missed", call_outcome: "LegA").where('duration > ?', 0.0).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from, @to.beginning_of_day+1.day).count
      @telephony_calls["Call cut by telecaller before customer's phone ringing"] = cut_before_connected
      @telephony_calls["First customer cut the call then agent cut the call"] = call_cut_after_customer_disconnected
      @telephony_calls["Call cut by telecaller after one or two ring"] = cut_after_one_ring
      @telephony_calls["Only customer cut the call"] = only_cut_by_customer
    end
  end

def google_report
    @projects = selections(BusinessUnit, :name)

    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from]
      @to = params[:to]
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      # campaign_ids = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}
      total_leads = 0
      qualified_leads = 0
      sv_leads = 0
      all_leads = []
      # campaign_ids.each do |campaign_id|
    urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
      result = HTTParty.post(urlstring,
           :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.status='ENABLED' AND segments.date BETWEEN '"+@from.to_date.strftime('%Y-%m-%d')+"' AND '"+@to.to_date.strftime('%Y-%m-%d')+"'"}.to_json,
           :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
      if result[0]["results"] != nil
        result[0]["results"].each do |data|
            ad_resource_name=data["adGroupAd"]["ad"]["resourceName"]
            ad_id=ad_resource_name[((ad_resource_name.length-(ad_resource_name.reverse.index('/')))..(ad_resource_name.length-1))]
            total_leads = GoogleLeadDetail.where(creative: ad_id).where('created_at >= ? AND created_at < ?', @from, @to.to_date+1.day).count
            all_leads += [GoogleLeadDetail.where(creative: ad_id).where('created_at >= ? AND created_at < ?', @from, @to.to_date+1.day).pluck(:lead_id)]
            qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('leads.qualified_on is not ?', nil).where('google_lead_details.creative = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',ad_id, @from, @to.to_date.beginning_of_day+1.day).count
            sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('leads.site_visited_on is not ?', nil).where('google_lead_details.creative = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',ad_id, @from, @to.to_date.beginning_of_day+1.day).count
            if total_leads>0
            @google_lead_details[ad_id] = [data["campaign"]["name"], data["adGroup"]["name"], total_leads, qualified_leads, sv_leads]
            end
        end
      end
      p "================================"
      p all_leads
      p "================================"
      # end
    end
  end

  def keyword_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now-7.days
      @to = DateTime.now
      @google_data = {}
    else
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @project_selected = params[:business_unit_id].to_i
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      @google_data = {}
      total_leads_generated = GoogleLeadDetail.includes(:lead => [:source_category]).where(:leads => {business_unit_id: @project_selected, lost_reason_id: lost_reasons}).where('source_categories.heirarchy like ?', "%Google%").where('leads.generated_on >= ? AND leads.generated_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
      campaign_hash = total_leads_generated.group_by{|x| x.campaignid}
      if params[:source] == nil
        campaign_wise_adgroup_data = {}
        campaign_hash.each do |key, value|
          campaign_data = {}
          if key == nil
          else
            if GoogleCampaign.where(campaign_id: key) == []
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              campaign_data["Blank"] = [leads_generated, qualified_leads, sv_leads, booked_leads]
              campaign_wise_adgroup_data[campaign_data] = {}
            else
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [leads_generated, qualified_leads, sv_leads, booked_leads]
              campaign_wise_adgroup_data[campaign_data] = {}
            end
          end
        end
        @google_data["campaigns"] = campaign_wise_adgroup_data
      elsif params[:source] == "campaign"
        clicked_campaign_name = params[:campaign_name]
        campaign_wise_adgroup_data = {}
        campaign_hash.each do |key, value|
          campaign_data = {}
          if key == nil
          else
            if key == ""
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              campaign_data["Blank"] = [leads_generated, qualified_leads, sv_leads, booked_leads]
              campaign_wise_adgroup_data[campaign_data] = {}
            else
              if GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name == clicked_campaign_name
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [leads_generated, qualified_leads, sv_leads, booked_leads]
                adgroup_hash = value.group_by{|x| x.adgroupid}
                adgroup_data = {}
                adgroup_hash.each do |adgroup_id, google_lead_details|
                  adgroup_leads_generated = 0
                  adgroup_qualified_leads = 0
                  adgroup_sv_leads = 0
                  adgroup_booked_leads = 0
                  google_lead_details.each do |google_lead_detail|
                    adgroup_leads_generated += 1
                    lead = Lead.find(google_lead_detail.lead_id)
                    if lead.qualified_on == nil
                    else
                      adgroup_qualified_leads += 1
                    end
                    if lead.site_visited_on == nil
                    else
                      adgroup_sv_leads += 1
                    end
                    if lead.booked_on == nil
                    else
                      if lead.lost_reason_id == nil
                        adgroup_booked_leads += 1
                      end
                    end
                  end
                  adgroup_data[GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name] = [adgroup_leads_generated, adgroup_qualified_leads, adgroup_sv_leads, adgroup_booked_leads]
                end
                campaign_wise_adgroup_data[campaign_data] = adgroup_data
              else
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [leads_generated, qualified_leads, sv_leads, booked_leads]
                campaign_wise_adgroup_data[campaign_data] = {}
              end
            end
          end
        end
        @google_data["adgroups"] = campaign_wise_adgroup_data
      elsif params[:source] == "adgroup_kw"
        clicked_adgroup_name = params[:adgroup_name]
        clicked_campaign_name = params[:campaign_name]
        campaign_wise_adgroup_wise_data = {}
        adgroup_wise_kw_data = {}
        campaign_hash.each do |key, value|
          campaign_data = {}
          if key == nil
          else
            if key == ""
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              campaign_data["Blank"] = [leads_generated, qualified_leads, sv_leads, booked_leads]
              campaign_wise_adgroup_wise_data[campaign_data] = {}
            else
              if GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name == clicked_campaign_name
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [leads_generated, qualified_leads, sv_leads, booked_leads]
                adgroup_hash = value.group_by{|x| x.adgroupid}
                adgroup_hash.each do |adgroup_id, adgroup_detail|
                  adgroup_data = {}
                  if GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name == clicked_adgroup_name
                    adgroup_leads_generated = 0
                    adgroup_qualified_leads = 0
                    adgroup_sv_leads = 0
                    adgroup_booked_leads = 0
                    adgroup_detail.each do |google_lead_detail|
                      adgroup_leads_generated += 1
                      lead = Lead.find(google_lead_detail.lead_id)
                      if lead.qualified_on == nil
                      else
                        adgroup_qualified_leads += 1
                      end
                      if lead.site_visited_on == nil
                      else
                        adgroup_sv_leads += 1
                      end
                      if lead.booked_on == nil
                      else
                        if lead.lost_reason_id == nil
                          adgroup_booked_leads += 1
                        end
                      end
                    end
                    adgroup_data[GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name] = [adgroup_leads_generated, adgroup_qualified_leads, adgroup_sv_leads, adgroup_booked_leads]
                    keyword_hash = adgroup_detail.group_by{|x| x.keyword}
                    keyword_data = {}
                    keyword_hash.each do |keyword, google_lead_details|
                      keyword_leads_generated = 0
                      keyword_qualified_leads = 0
                      keyword_sv_leads = 0
                      keyword_booked_leads = 0
                      google_lead_details.each do |google_lead_detail|
                        keyword_leads_generated += 1
                        lead = Lead.find(google_lead_detail.lead_id)
                        if lead.qualified_on == nil
                        else
                          keyword_qualified_leads += 1
                        end
                        if lead.site_visited_on == nil
                        else
                          keyword_sv_leads += 1
                        end
                        if lead.booked_on == nil
                        else
                          if lead.lost_reason_id == nil
                            keyword_booked_leads += 1
                          end
                        end
                      end
                      keyword_data[keyword] = [keyword_leads_generated, keyword_qualified_leads, keyword_sv_leads, keyword_booked_leads]
                    end
                    adgroup_wise_kw_data[adgroup_data] =keyword_data
                  else
                    adgroup_leads_generated = 0
                    adgroup_qualified_leads = 0
                    adgroup_sv_leads = 0
                    adgroup_booked_leads = 0
                    adgroup_detail.each do |google_lead_detail|
                      adgroup_leads_generated += 1
                      lead = Lead.find(google_lead_detail.lead_id)
                      if lead.qualified_on == nil
                      else
                        adgroup_qualified_leads += 1
                      end
                      if lead.site_visited_on == nil
                      else
                        adgroup_sv_leads += 1
                      end
                      if lead.booked_on == nil
                      else
                        if lead.lost_reason_id == nil
                          adgroup_booked_leads += 1
                        end
                      end
                    end
                    adgroup_data[GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name] = [adgroup_leads_generated, adgroup_qualified_leads, adgroup_sv_leads, adgroup_booked_leads]
                    adgroup_wise_kw_data[adgroup_data] = {}
                  end
                end
                campaign_wise_adgroup_wise_data[campaign_data] = adgroup_wise_kw_data
              else
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [leads_generated, qualified_leads, sv_leads, booked_leads]
                campaign_wise_adgroup_wise_data[campaign_data] = {}
              end
            end
          end
        end
        @google_data["adgroup_kw"] = campaign_wise_adgroup_wise_data
      end
    end

    # @projects = selections(BusinessUnit, :name)
    # if params[:business_unit_id] == nil
    #   @from = DateTime.now.beginning_of_day-7.days
    #   @to = DateTime.now
    #   @google_lead_details = {}
    #   @business_unit_id = -1
    # else
    #   @google_lead_details = {}
    #   urlstring =  "https://www.googleapis.com/oauth2/v3/token"
    #   result = HTTParty.post(urlstring,
    #   :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
    #   :headers => {'Content-Type' => 'application/json'} )
    #   access_token=result["access_token"]
    #   @business_unit_id = params[:business_unit_id].to_i
    #   @from = params[:from].to_datetime
    #   @to = params[:to].to_datetime
    #   google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
    #   all_keywords = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.keyword}.uniq
    #   all_adgroups = []
    #   all_campaigns = []
    #   all_keywords.each do |keyword|
    #     if keyword == "" || keyword == nil || keyword == "test"
    #     else
    #       all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, keyword: keyword).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
    #       all_adgroups.each do |adgroup_id|
    #         all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, keyword: keyword, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
    #         all_campaigns.each do |campaign_id|
    #           total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, keyword: keyword).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
    #           qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, keyword: keyword).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
    #           sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, keyword: keyword).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
    #           urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
    #           result = HTTParty.post(urlstring,
    #                :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
    #                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
    #           if result[0] == [] || result[0] == nil
    #           else
    #             if result[0]["results"] != nil
    #               result[0]["results"].each do |data|
    #                 if @google_lead_details[data["campaign"]["name"]] == nil
    #                   @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], keyword, total_leads, qualified_leads, sv_leads]]
    #                 else
    #                   @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], keyword, total_leads, qualified_leads, sv_leads]]
    #                 end
    #               end
    #             end
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
  end

  def device_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_devices = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.device}.uniq
      all_adgroups = []
      all_campaigns = []
      all_devices.each do |device|
        if device == "" || device == nil || device == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, device: device).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, device: device, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, device: device).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, device: device).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, device: device).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], device, total_leads, qualified_leads, sv_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], device, total_leads, qualified_leads, sv_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def placement_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_placements = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.placement}.uniq
      all_adgroups = []
      all_campaigns = []
      all_placements.each do |placement|
        if placement == "" || placement == nil || placement == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, placement: placement).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, placement: placement, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, placement: placement).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, placement: placement).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, placement: placement).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], placement, total_leads, qualified_leads, sv_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], placement, total_leads, qualified_leads, sv_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def network_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_networks = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.network}.uniq
      all_adgroups = []
      all_campaigns = []
      all_networks.each do |network|
        if network == "" || network == nil || network == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, network: network).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, network: network, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, network: network).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, network: network).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, network: network).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], network, total_leads, qualified_leads, sv_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], network, total_leads, qualified_leads, sv_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def target_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_targets = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.target}.uniq
      all_adgroups = []
      all_campaigns = []
      all_targets.each do |target|
        if target == "" || target == nil || target == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, target: target).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, target: target, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, target: target).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, target: target).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], target, total_leads, qualified_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], target, total_leads, qualified_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def extention_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_extention_ids = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.extention_id}.uniq
      all_adgroups = []
      all_campaigns = []
      all_extention_ids.each do |extention_id|
        if extention_id == "" || extention_id == nil || extention_id == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, extention_id: extention_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, extention_id: extention_id, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, extention_id: extention_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, extention_id: extention_id).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], extention_id, total_leads, qualified_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], extention_id, total_leads, qualified_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def fb_insta_lead_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @fb_insta_details = {}
      @business_unit_id = -1
    else
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @fb_insta_details = {}
      all_platforms = Lead.where(business_unit_id: @business_unit_id).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).pluck(:platform)
      all_platforms = all_platforms.uniq
      all_platforms.each do |platform|
        if platform == nil || platform == ""
        else
          if @fb_insta_details[platform] == nil
            total_leads = Lead.where(business_unit_id: @business_unit_id, platform: platform).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).count
            qualified_leads = Lead.where(business_unit_id: @business_unit_id, platform: platform).where.not(qualified_on: nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day).count
            percentage = ((qualified_leads.to_f/total_leads.to_f)*100).round(2)
            @fb_insta_details[platform] = [total_leads, qualified_leads, percentage]
          end
        end
      end
    end
  end

  def location_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @interest_ms_google_lead_details = {}
      @physical_ms_google_lead_details = {}
      @business_unit_id = -1
    else
      @interest_ms_google_lead_details = {}
      @physical_ms_google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_loc_interest_mss = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.loc_interest_ms}.uniq
      all_adgroups = []
      all_campaigns = []
      all_loc_interest_mss.each do |loc_interest_ms|
        if loc_interest_ms == "" || loc_interest_ms == nil || loc_interest_ms == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, loc_interest_ms: loc_interest_ms).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, loc_interest_ms: loc_interest_ms, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, loc_interest_ms: loc_interest_ms).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, loc_interest_ms: loc_interest_ms).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, loc_interest_ms: loc_interest_ms).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @interest_ms_google_lead_details[data["campaign"]["name"]] == nil
                      @interest_ms_google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], loc_interest_ms, total_leads, qualified_leads, sv_leads]]
                    else
                      @interest_ms_google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], loc_interest_ms, total_leads, qualified_leads, sv_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end

      all_loc_physical_mss = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.loc_physical_ms}.uniq
      all_adgroups = []
      all_campaigns = []
      all_loc_physical_mss.each do |loc_physical_ms|
        if loc_physical_ms == "" || loc_physical_ms == nil || loc_physical_ms == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, loc_physical_ms: loc_physical_ms).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, loc_physical_ms: loc_physical_ms, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, loc_physical_ms: loc_physical_ms).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, loc_physical_ms: loc_physical_ms).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @physical_ms_google_lead_details[data["campaign"]["name"]] == nil
                      @physical_ms_google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], loc_physical_ms, total_leads, qualified_leads]]
                    else
                      @physical_ms_google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], loc_physical_ms, total_leads, qualified_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def organic_lead_report
    if params[:from] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @organic_lead_details = {}
    else
      @organic_lead_details = {}
      @from = params[:from]
      @to = params[:to]
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      BusinessUnit.where(organisation_id: 1).each do |business_unit|
        total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: business_unit.id, lost_reason_id: lost_reasons}, campaignid: nil, adgroupid: nil, creative: nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.to_date+1.day).count
        total_leads += GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: business_unit.id, lost_reason_id: lost_reasons}).where('(google_lead_details.campaignid = ? AND google_lead_details.adgroupid = ? AND google_lead_details.creative = ?) AND (google_lead_details.created_at >= ? AND google_lead_details.created_at < ?)', "", "", "", @from, @to.to_date+1.day).count
        qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: business_unit.id, lost_reason_id: lost_reasons}, campaignid: nil, adgroupid: nil, creative: nil).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.to_date.beginning_of_day+1.day).count
        qualified_leads += GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: business_unit.id, lost_reason_id: lost_reasons}).where('leads.qualified_on is not ?', nil).where('(google_lead_details.campaignid = ? AND google_lead_details.adgroupid = ? AND google_lead_details.creative = ?) AND (google_lead_details.created_at >= ? AND google_lead_details.created_at < ?)', "", "", "", @from, @to.to_date.beginning_of_day+1.day).count
        @organic_lead_details[business_unit.name] = [[total_leads, qualified_leads]]
      end
    end
  end

  def facebook_graphical_report
    if current_personnel.email=='riddhi.gadhiya@beyondwalls.com'
    @projects=[['Dream Gurukul',70]]
    else
    @projects = selections_with_all(BusinessUnit, :name)
    end
    lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
    lost_reasons = lost_reasons-[57,49]
    lost_reasons = lost_reasons+[nil]
    @report_types = ["Daily", "Weekly", "Monthly"]
    @fb_sources = ['Online','Online . Google','Online . Super Receptionist']+(SourceCategory.where(id: (Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}).where('leads.created_at >= ? AND leads.created_at < ?', (DateTime.now.beginning_of_month-2.month).to_datetime, DateTime.now.beginning_of_day+1.day).pluck(:source_category_id).uniq)).where('heirarchy like ?', '%FACEBOOK%').uniq.pluck(:heirarchy))
    if params[:business_unit_id] == nil
    else
      @project_selected = params[:business_unit_id].to_i
      @source = params[:source]
      @report_type = params[:report_type]
      leads_generated_hash = {}
      qualified_leads_hash = {}
      site_visited_hash = {}
      leads_generated_hash[:name] = 'Enquiries'
      qualified_leads_hash[:name] = 'Qualified Leads'
      site_visited_hash[:name] = 'Site visited'
      total_leads_generated = []
      qualified_leads = []
      site_visit_done = []
      @days = []
      @weeks = []
      @months = []
      @series = []
      if @report_type == "Daily"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: (SourceCategory.where('heirarchy like ?', "%"+@source+"%").pluck(:id).uniq)).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_day-30.days, DateTime.now.beginning_of_day+1.day).sort_by{|lead| lead.created_at}.group_by{|x| x.generated_on.to_date}
        leads_generated_raw.each do |key, value|
          @days += [key.to_date.strftime("%d/%m/%Y")]
          total_leads_generated += [value.count]
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
          end
          qualified_leads += [qualify_count]
          site_visit_done += [sv_count]
        end
        leads_generated_hash[:data] = total_leads_generated
        qualified_leads_hash[:data] = qualified_leads
        site_visited_hash[:data] = site_visit_done
        @series = [leads_generated_hash, qualified_leads_hash, site_visited_hash].to_json.html_safe
        @days = @days.to_json.html_safe
      elsif @report_type == "Weekly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: (SourceCategory.where('heirarchy like ?', "%"+@source+"%").pluck(:id).uniq)).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_week-13.weeks, DateTime.now.end_of_week+1.day).sort_by{|lead| lead.created_at}.group_by{|x| x.generated_on.to_date.cweek}
        leads_generated_raw.each do |key, value|
          if key.to_s.length == 1
            key = ('0'+key.to_s)
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          else
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          end
          total_leads_generated += [value.count]
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
          end
          qualified_leads += [qualify_count]
          site_visit_done += [sv_count]
        end
        leads_generated_hash[:data] = total_leads_generated
        qualified_leads_hash[:data] = qualified_leads
        site_visited_hash[:data] = site_visit_done
        @series = [leads_generated_hash, qualified_leads_hash, site_visited_hash].to_json.html_safe
        p @series
        p "======================================"
        @weeks = @weeks.to_json.html_safe
      elsif @report_type == "Monthly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: (SourceCategory.where('heirarchy like ?', "%"+@source+"%").pluck(:id).uniq)).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
        leads_generated_raw.each do |key, value|
          @months += [Date::MONTHNAMES[key[1]]]
          total_leads_generated += [value.count]
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
          end
          qualified_leads += [qualify_count]
          site_visit_done += [sv_count]
        end
        leads_generated_hash[:data] = total_leads_generated
        qualified_leads_hash[:data] = qualified_leads
        site_visited_hash[:data] = site_visit_done
        @series = [leads_generated_hash, qualified_leads_hash, site_visited_hash].to_json.html_safe
        @months = @months.to_json.html_safe
      end
    end
  end

  def tat_report
    if params[:from] == nil
      @from = DateTime.now.beginning_of_day-1.day
      @to = DateTime.now
      # @telecaller_report = {}
      @bu_wise_fresh_leads = {}
    else
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @bu_wise_fresh_leads = {}
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      source_categories = SourceCategory.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      source_categories = source_categories-[868, 5373, 5379, 5374, 5375, 5376, 5377, 5383, 5378, 5382, 868]
      business_units = ["Dream One", "Dream Valley", "Dream Eco City", "Ecocity Bungalows", "Dream Exotica", "Dream Palazzo", "Dream Residency Manor"]
      business_units.each do |business_unit|
        fresh_leads = []
        delay_in_minutes = 0
        Lead.where(business_unit_id: BusinessUnit.find_by_name(business_unit).id, lost_reason_id: lost_reasons, source_category_id: source_categories).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day).each do |lead|
          if (lead.generated_on+5.hours+30.minutes).to_time.sunday?
            fresh_leads += [lead.id]
            first_telephony_call = nil
            TelephonyCall.where(lead_id: lead.id).sort_by{|x| x.created_at}.each do |telephony_call|
              if telephony_call.start_time < telephony_call.start_time.beginning_of_day+11.hours
              else
                first_telephony_call = telephony_call
                break
              end
            end
            if first_telephony_call == nil
            else
              if lead.generated_on.to_date == (lead.generated_on+5.hours+30.minutes).to_date
                if (lead.generated_on+5.hours+30.minutes) > ((lead.generated_on+5.hours+30.minutes).beginning_of_day+16.hours) && (lead.generated_on+5.hours+30.minutes) < ((lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours+1.day)
                  lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours+1.day
                else
                  if (lead.generated_on+5.hours+30.minutes) < (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                  else
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes)
                  end
                end
              else
                if (lead.generated_on+5.hours+30.minutes) > ((lead.generated_on).beginning_of_day+16.hours) && (lead.generated_on+5.hours+30.minutes) < ((lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours)
                  lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                else
                  if (lead.generated_on+5.hours+30.minutes) < (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                  else
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes)
                  end
                end
              end
              if lead_generation_time.to_date == first_telephony_call.start_time.to_date
                if lead_generation_time > first_telephony_call.start_time
                  generation_time = Time.parse((lead.generated_on+5.hours+30.minutes).to_s)
                  lead_generation_time = lead.generated_on+5.hours+30.minutes
                else
                  generation_time = Time.parse(lead_generation_time.to_s)
                end
                calling_time = Time.parse(first_telephony_call.start_time.to_s)
                difference_in_seconds = (calling_time - generation_time).to_i.abs
                first_delay = difference_in_seconds / 60
                second_delay = 0.0
                delay_in_minutes += (first_delay+second_delay)
              else
                if lead_generation_time > first_telephony_call.start_time
                  generation_time = Time.parse((lead.generated_on+5.hours+30.minutes).to_s)
                  lead_generation_time = lead.generated_on+5.hours+30.minutes
                else
                  generation_time = Time.parse(lead_generation_time.to_s)
                end
                day_end_time = Time.parse((lead_generation_time.beginning_of_day+16.hours).to_s)
                difference_in_seconds = (day_end_time - generation_time).to_i.abs
                first_delay = difference_in_seconds / 60
                calling_time = Time.parse(first_telephony_call.start_time.to_s)
                day_start_time = Time.parse((first_telephony_call.start_time.beginning_of_day+11.hours).to_s)
                difference_in_seconds = (calling_time - day_start_time).to_i.abs
                second_delay = difference_in_seconds / 60
                delay_in_minutes += (first_delay+second_delay)
              end
            end
          else
            fresh_leads += [lead.id]
            first_telephony_call = nil
            TelephonyCall.where(lead_id: lead.id).sort_by{|x| x.created_at}.each do |telephony_call|
              if telephony_call.start_time < telephony_call.start_time.beginning_of_day+11.hours
              else
                first_telephony_call = telephony_call
                break
              end
            end
            if first_telephony_call == nil
            else
              if lead.generated_on.to_date == (lead.generated_on+5.hours+30.minutes).to_date
                if (lead.generated_on+5.hours+30.minutes) > ((lead.generated_on+5.hours+30.minutes).beginning_of_day+19.hours) && (lead.generated_on+5.hours+30.minutes) < ((lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours+1.day)
                  lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours+1.day
                else
                  if (lead.generated_on+5.hours+30.minutes) < (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                  else
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes)
                  end
                end
              else
                if (lead.generated_on+5.hours+30.minutes) > ((lead.generated_on).beginning_of_day+19.hours) && (lead.generated_on+5.hours+30.minutes) < ((lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours)
                  lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                else
                  if (lead.generated_on+5.hours+30.minutes) < (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+11.hours
                  else
                    lead_generation_time = (lead.generated_on+5.hours+30.minutes)
                  end
                end
              end
              if lead_generation_time.to_date == first_telephony_call.start_time.to_date
                if lead_generation_time > first_telephony_call.start_time
                  generation_time = Time.parse((lead.generated_on+5.hours+30.minutes).to_s)
                  lead_generation_time = lead.generated_on+5.hours+30.minutes
                else
                  generation_time = Time.parse(lead_generation_time.to_s)
                end
                calling_time = Time.parse(first_telephony_call.start_time.to_s)
                difference_in_seconds = (calling_time - generation_time).to_i.abs
                first_delay = difference_in_seconds / 60
                second_delay = 0.0
                delay_in_minutes += (first_delay+second_delay)
              else
                if lead_generation_time > first_telephony_call.start_time
                  generation_time = Time.parse((lead.generated_on+5.hours+30.minutes).to_s)
                  lead_generation_time = lead.generated_on+5.hours+30.minutes
                else
                  generation_time = Time.parse(lead_generation_time.to_s)
                end
                day_end_time = Time.parse((lead_generation_time.beginning_of_day+19.hours).to_s)
                difference_in_seconds = (day_end_time - generation_time).to_i.abs
                first_delay = difference_in_seconds / 60
                calling_time = Time.parse(first_telephony_call.start_time.to_s)
                day_start_time = Time.parse((first_telephony_call.start_time.beginning_of_day+11.hours).to_s)
                difference_in_seconds = (calling_time - day_start_time).to_i.abs
                second_delay = difference_in_seconds / 60
                delay_in_minutes += (first_delay+second_delay)
              end
            end
          end
        end
        if fresh_leads.count == 0
          tat = 0
        else
          tat = (delay_in_minutes/fresh_leads.count).round
        end
        @bu_wise_fresh_leads[business_unit] = {"fresh_leads" => fresh_leads, "tat" => tat}
      end
    end
  end

  def detail_tat_report
    lead_ids = params[:lead_ids]
    @detail_report = []
    lead_ids.each do |lead_id|
      lead = Lead.find(lead_id.to_i)
      first_telephony_call = nil
      TelephonyCall.where(lead_id: lead_id.to_i).sort_by{|x| x.created_at}.each do |telephony_call|
        if telephony_call.start_time < telephony_call.start_time.beginning_of_day+10.hours
        else
          first_telephony_call = telephony_call
          break
        end
      end
      if first_telephony_call == nil
      else
        if lead.generated_on.to_date == (lead.generated_on+5.hours+30.minutes).to_date
          if (lead.generated_on+5.hours+30.minutes) > ((lead.generated_on+5.hours+30.minutes).beginning_of_day+19.hours) && (lead.generated_on+5.hours+30.minutes) < ((lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours+1.day)
            lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours+1.day
          else
            if (lead.generated_on+5.hours+30.minutes) < (lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours
              lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours
            else
              lead_generation_time = (lead.generated_on+5.hours+30.minutes)
            end
          end
        else
          if (lead.generated_on+5.hours+30.minutes) > ((lead.generated_on).beginning_of_day+19.hours) && (lead.generated_on+5.hours+30.minutes) < ((lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours)
            lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours
          else
            if (lead.generated_on+5.hours+30.minutes) < (lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours
              lead_generation_time = (lead.generated_on+5.hours+30.minutes).beginning_of_day+10.hours
            else
              lead_generation_time = (lead.generated_on+5.hours+30.minutes)
            end
          end
        end
        if lead_generation_time.to_date == first_telephony_call.start_time.to_date
          if lead_generation_time > first_telephony_call.start_time
            generation_time = Time.parse((lead.generated_on+5.hours+30.minutes).to_s)
            lead_generation_time = lead.generated_on+5.hours+30.minutes
          else
            generation_time = Time.parse(lead_generation_time.to_s)
          end
          calling_time = Time.parse(first_telephony_call.start_time.to_s)
          difference_in_seconds = (calling_time - generation_time).to_i.abs
          first_delay = difference_in_seconds / 60
          second_delay = 0.0
          delay_in_minutes = (first_delay+second_delay)
        else
          if lead_generation_time > first_telephony_call.start_time
            generation_time = Time.parse((lead.generated_on+5.hours+30.minutes).to_s)
            lead_generation_time = lead.generated_on+5.hours+30.minutes
          else
            generation_time = Time.parse(lead_generation_time.to_s)
          end
          day_end_time = Time.parse((lead_generation_time.beginning_of_day+19.hours).to_s)
          difference_in_seconds = (day_end_time - generation_time).to_i.abs
          first_delay = difference_in_seconds / 60
          calling_time = Time.parse(first_telephony_call.start_time.to_s)
          day_start_time = Time.parse((first_telephony_call.start_time.beginning_of_day+10.hours).to_s)
          difference_in_seconds = (calling_time - day_start_time).to_i.abs
          second_delay = difference_in_seconds / 60
          delay_in_minutes = (first_delay+second_delay)
        end
        executive = Personnel.find_by_mobile(first_telephony_call.agent_number)
        if executive == nil
          @detail_report += [[lead_id, lead_generation_time, first_telephony_call.start_time, delay_in_minutes, ""]]
        else
          @detail_report += [[lead_id, lead_generation_time, first_telephony_call.start_time, delay_in_minutes, executive.name]]
        end
      end
    end
  end

  def target_id_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_target_ids = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.target_id}.uniq
      all_adgroups = []
      all_campaigns = []
      all_target_ids.each do |target_id|
        if target_id == "" || target_id == nil || target_id == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, target_id: target_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, target_id: target_id, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, target_id: target_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, target_id: target_id).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, target_id: target_id).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], target_id, total_leads, qualified_leads, sv_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], target_id, total_leads, qualified_leads, sv_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def device_model_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_device_models = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.device_model}.uniq
      all_adgroups = []
      all_campaigns = []
      all_device_models.each do |device_model|
        if device_model == "" || device_model == nil || device_model == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, device_model: device_model).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, device_model: device_model, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, device_model: device_model).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, device_model: device_model).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, device_model: device_model).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], device_model, total_leads, qualified_leads, sv_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], device_model, total_leads, qualified_leads, sv_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def communicated_through_wise_google_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @from = DateTime.now.beginning_of_day-7.days
      @to = DateTime.now
      @google_lead_details = {}
      @business_unit_id = -1
    else
      @google_lead_details = {}
      if current_personnel.organisation_id==7
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      all_communicated_throughs = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.communicated_through}.uniq
        all_communicated_throughs.each do |communicated_through|
        total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, communicated_through: communicated_through).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
        qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, communicated_through: communicated_through).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
        sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, communicated_through: communicated_through).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
        @google_lead_details[communicated_through] = [[communicated_through, communicated_through, total_leads, qualified_leads, sv_leads]]
        end
      else
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,
      :body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,
      :headers => {'Content-Type' => 'application/json'} )
      access_token=result["access_token"]
      @business_unit_id = params[:business_unit_id].to_i
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      google_ad_accounts = {'Dream Valley' => '1931970041','Dream World City' => '9258159588','Dream One' => '8392984077','Dream One Hotel Apartment' => '8392984077','Dream Eco City' => '7338233394','Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
      all_communicated_throughs = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.communicated_through}.uniq
      all_adgroups = []
      all_campaigns = []
      all_communicated_throughs.each do |communicated_through|
        if communicated_through == "" || communicated_through == nil || communicated_through == "test"
        else
          all_adgroups = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, communicated_through: communicated_through).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.adgroupid}.uniq
          all_adgroups.each do |adgroup_id|
            all_campaigns = GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {id: @business_unit_id}, communicated_through: communicated_through, adgroupid: adgroup_id).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).map{|x| x.campaignid}.uniq
            all_campaigns.each do |campaign_id|
              total_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, communicated_through: communicated_through).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              qualified_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, communicated_through: communicated_through).where('leads.qualified_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              sv_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id}, campaignid: campaign_id.to_i, adgroupid: adgroup_id.to_i, communicated_through: communicated_through).where('leads.site_visited_on is not ?', nil).where('google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', @from, @to.beginning_of_day+1.day).count
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+google_ad_accounts[BusinessUnit.find(@business_unit_id).name].to_s+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                   :body => {"query": "SELECT campaign.name, ad_group.name FROM ad_group_ad WHERE campaign.id="+campaign_id.to_s+" AND ad_group.id="+adgroup_id.to_s}.to_json,
                   :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' } )
              if result[0] == [] || result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |data|
                    if @google_lead_details[data["campaign"]["name"]] == nil
                      @google_lead_details[data["campaign"]["name"]] = [[data["adGroup"]["name"], communicated_through, total_leads, qualified_leads, sv_leads]]
                    else
                      @google_lead_details[data["campaign"]["name"]] += [[data["adGroup"]["name"], communicated_through, total_leads, qualified_leads, sv_leads]]
                    end
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
    end
  end

  def fb_audience_explorer
    if params[:type] == nil
      @type = ''
      @fb_audiences = []
      urlstring = "https://graph.facebook.com/v14.0/search?type=adTargetingCategory&class=behaviors&limit=10000&locale=en_US&access_token=EAAGMztM7V2wBAEtxszz5mlrZCUljRemIHcqoCDZCl8VKSpqJDUqYgKAUkfB0qZBu31u6enNecnebna7iVKMCHYY9XRJuLOZBCGW8xgdnLRkN09hDyDSalNZCdZA4xiKX2HBI4gRmK8ZAJ5iYlcSgjZAdvaGn4eXzscsESwoUp5dqbZBStm9ZCEueiF"
      result = HTTParty.get(urlstring)
      @fb_audiences = []
      if result["data"] == []
      else
        result["data"].each do |data|
          @fb_audiences += [[data["name"], data["audience_size_lower_bound"], data["audience_size_upper_bound"], data["path"], data["description"]]]
        end
      end
      @report_type = "Behaviour"
    else
      @report_type = "Interest"
      @type = params[:type]
      urlstring = "https://graph.facebook.com/v14.0/search?type=adinterest&q="+@type.to_s+"&limit=10000&locale=en_US&access_token=EAAGMztM7V2wBAEtxszz5mlrZCUljRemIHcqoCDZCl8VKSpqJDUqYgKAUkfB0qZBu31u6enNecnebna7iVKMCHYY9XRJuLOZBCGW8xgdnLRkN09hDyDSalNZCdZA4xiKX2HBI4gRmK8ZAJ5iYlcSgjZAdvaGn4eXzscsESwoUp5dqbZBStm9ZCEueiF"
      result = HTTParty.get(urlstring)
      @fb_audiences = []
      if result["data"] == []
      else
        result["data"].each do |data|
          @fb_audiences += [[data["name"], data["audience_size_lower_bound"], data["audience_size_upper_bound"], data["path"], data["description"], data["topic"]]]
        end
      end
    end
  end

  def populate_interest_type
    @report_type = params[:interest_type]
    p @report_type
    @type = ''
    p "===========into the controller method=========="
    if @report_type == "Interest"
      respond_to do |format|
        format.js { render :action => "populate_interest_type"}
      end
    end
  end

  def google_expandable_report
    if current_personnel.email=='riddhi.gadhiya@beyondwalls.com'
    @projects=[['Dream Gurukul',70]]
    else
    @projects = selections_with_all(BusinessUnit, :name)
    end
    ad_accounts = {'Dream Valley' => '1931970041', 'Dream World City' => '9258159588', 'Dream One' => '8392984077', 'Dream Eco City' => '7338233394', 'Ecocity Bungalows' => '9659854345','Dream Gurukul' => '9885817994'}
    if params[:business_unit_id] == nil
      @from = DateTime.now-7.days
      @to = DateTime.now
      @google_data = {}
    else
      urlstring =  "https://www.googleapis.com/oauth2/v3/token"
      result = HTTParty.post(urlstring,:body => {"grant_type" => "refresh_token", "client_id"=>"493544217836-3br6uvm71vqkfs7i2j58ftj6kbatrpdo.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//0gaIl4uAZfhSACgYIARAAGBASNwF-L9Ir5JQYvWYanMV7752mcvIngnX0ijMrycmQA279nCU5zY12HYHd0jNz0SStS0r1C4oLs0A"}.to_json,:headers => {'Content-Type' => 'application/json'} )
      access_token = result["access_token"]
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @project_selected = params[:business_unit_id].to_i
      business_unit = BusinessUnit.find(@project_selected)
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      @google_data = {}
      total_leads_generated = GoogleLeadDetail.includes(:lead => [:source_category]).where(:leads => {business_unit_id: @project_selected, lost_reason_id: lost_reasons}).where.not(campaignid: 'test_data').where('source_categories.heirarchy like ?', "%Google%").where('leads.generated_on >= ? AND leads.generated_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
      campaign_hash = total_leads_generated.group_by{|x| x.campaignid}
      if params[:source] == nil
        campaign_wise_adgroup_data = {}
        campaign_hash.each do |key, value|
          campaign_data = {}
          if key == nil
          else
            if GoogleCampaign.where(campaign_id: key) == []
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              cpl = 0
              cpql = 0
              campaign_data["Blank"] = [0, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
              campaign_wise_adgroup_data[campaign_data] = {}
            else
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              amount = 0
              urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
              result = HTTParty.post(urlstring,
                :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
              if result[0] == nil
              else
                if result[0]["results"] != nil
                  result[0]["results"].each do |campaign|
                    amount += campaign["metrics"]["costMicros"].to_f/1000000
                    amount = amount.round
                  end
                end
              end
              cpl = 0
              cpql = 0
              if leads_generated == 0
                cpl = 0
              else
                cpl = (amount/leads_generated).round
              end
              if qualified_leads == 0
                cpql == 0
              else
                cpql = (amount/qualified_leads).round
              end
              campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [amount, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
              campaign_wise_adgroup_data[campaign_data] = {}
            end
          end
        end
        @google_data["campaigns"] = campaign_wise_adgroup_data
      elsif params[:source] == "campaign"
        clicked_campaign_name = params[:campaign_name]
        campaign_wise_adgroup_data = {}
        campaign_hash.each do |key, value|
          p key
          campaign_data = {}
          if key == nil
          else
            if key == ""
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              cpl = 0
              cpql = 0
              campaign_data["Blank"] = [0, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
              campaign_wise_adgroup_data[campaign_data] = {}
            else
              if GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name == clicked_campaign_name
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                amount = 0
                urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                result = HTTParty.post(urlstring,
                  :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                  :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                if result[0] == nil
                else
                  if result[0]["results"] != nil
                    result[0]["results"].each do |campaign|
                      amount += campaign["metrics"]["costMicros"].to_f/1000000
                      amount = amount.round
                    end
                  end
                end
                cpl = 0
                cpql = 0
                if leads_generated == 0
                  cpl = 0
                else
                  cpl = (amount/leads_generated).round
                end
                if qualified_leads == 0
                  cpql == 0
                else
                  cpql = (amount/qualified_leads).round
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [amount, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
                adgroup_hash = value.group_by{|x| x.adgroupid}
                adgroup_data = {}
                adgroup_hash.each do |adgroup_id, google_lead_details|
                  adgroup_leads_generated = 0
                  adgroup_qualified_leads = 0
                  adgroup_sv_leads = 0
                  adgroup_booked_leads = 0
                  google_lead_details.each do |google_lead_detail|
                    adgroup_leads_generated += 1
                    lead = Lead.find(google_lead_detail.lead_id)
                    if lead.qualified_on == nil
                    else
                      adgroup_qualified_leads += 1
                    end
                    if lead.site_visited_on == nil
                    else
                      adgroup_sv_leads += 1
                    end
                    if lead.booked_on == nil
                    else
                      if lead.lost_reason_id == nil
                        adgroup_booked_leads += 1
                      end
                    end
                  end
                  amount = 0
                  urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                  result = HTTParty.post(urlstring,
                    :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND ad_group.id = "+adgroup_id.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                  p result[0]
                  p "======================adgroup level data======================="
                  if result[0] == nil
                  else
                    if result[0]["results"] != nil
                      result[0]["results"].each do |campaign|
                        amount += campaign["metrics"]["costMicros"].to_f/1000000
                        amount = amount.round
                      end
                    end
                  end
                  cpl = 0
                  cpql = 0
                  if adgroup_leads_generated == 0
                    cpl = 0
                  else
                    cpl = (amount/adgroup_leads_generated).round
                  end
                  if adgroup_qualified_leads == 0
                    cpql == 0
                  else
                    cpql = (amount/adgroup_qualified_leads).round
                  end
                  adgroup_data[GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name] = [amount, adgroup_leads_generated, cpl, adgroup_qualified_leads, cpql, adgroup_sv_leads, adgroup_booked_leads]
                end
                campaign_wise_adgroup_data[campaign_data] = adgroup_data
              else
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                amount = 0
                urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                result = HTTParty.post(urlstring,
                  :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                  :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                if result[0] == nil
                else
                  if result[0]["results"] != nil
                    result[0]["results"].each do |campaign|
                      amount += campaign["metrics"]["costMicros"].to_f/1000000
                      amount = amount.round
                    end
                  end
                end
                cpl = 0
                cpql = 0
                if leads_generated == 0
                  cpl = 0
                else
                  cpl = (amount/leads_generated).round
                end
                if qualified_leads == 0
                  cpql == 0
                else
                  cpql = (amount/qualified_leads).round
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [amount, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
                campaign_wise_adgroup_data[campaign_data] = {}
              end
            end
          end
        end
        @google_data["adgroups"] = campaign_wise_adgroup_data
      elsif params[:source] == "adgroup_ad"
        clicked_adgroup_name = params[:adgroup_name]
        clicked_campaign_name = params[:campaign_name]
        campaign_wise_adgroup_wise_data = {}
        adgroup_wise_ad_data = {}
        campaign_hash.each do |key, value|
          campaign_data = {}
          if key == nil
          else
            if key == ""
              leads_generated = 0
              qualified_leads = 0
              sv_leads = 0
              booked_leads = 0
              value.each do |google_lead_detail|
                leads_generated += 1
                lead = Lead.find(google_lead_detail.lead_id)
                if lead.qualified_on == nil
                else
                  qualified_leads += 1
                end
                if lead.site_visited_on == nil
                else
                  sv_leads += 1
                end
                if lead.booked_on == nil
                else
                  if lead.lost_reason_id == nil
                    booked_leads += 1
                  end
                end
              end
              cpl = 0
              cpql = 0
              campaign_data["Blank"] = [0, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
              campaign_wise_adgroup_wise_data[campaign_data] = {}
            else
              if GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name == clicked_campaign_name
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                amount = 0
                urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                result = HTTParty.post(urlstring,
                  :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                  :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                if result[0] == nil
                else
                  if result[0]["results"] != nil
                    result[0]["results"].each do |campaign|
                      amount += campaign["metrics"]["costMicros"].to_f/1000000
                      amount = amount.round
                    end
                  end
                end
                cpl = 0
                cpql = 0
                if leads_generated == 0
                  cpl = 0
                else
                  cpl = (amount/leads_generated).round
                end
                if qualified_leads == 0
                  cpql == 0
                else
                  cpql = (amount/qualified_leads).round
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [amount, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
                adgroup_hash = value.group_by{|x| x.adgroupid}
                adgroup_hash.each do |adgroup_id, adgroup_detail|
                  adgroup_data = {}
                  if GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name == clicked_adgroup_name
                    adgroup_leads_generated = 0
                    adgroup_qualified_leads = 0
                    adgroup_sv_leads = 0
                    adgroup_booked_leads = 0
                    adgroup_detail.each do |google_lead_detail|
                      adgroup_leads_generated += 1
                      lead = Lead.find(google_lead_detail.lead_id)
                      if lead.qualified_on == nil
                      else
                        adgroup_qualified_leads += 1
                      end
                      if lead.site_visited_on == nil
                      else
                        adgroup_sv_leads += 1
                      end
                      if lead.booked_on == nil
                      else
                        if lead.lost_reason_id == nil
                          adgroup_booked_leads += 1
                        end
                      end
                    end
                    amount = 0
                    urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                    result = HTTParty.post(urlstring,
                      :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND ad_group.id = "+adgroup_id.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                      :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                    p result[0]
                    p "======================adgroup level data======================="
                    if result[0] == nil
                    else
                      if result[0]["results"] != nil
                        result[0]["results"].each do |campaign|
                          amount += campaign["metrics"]["costMicros"].to_f/1000000
                          amount = amount.round
                        end
                      end
                    end
                    cpl = 0
                    cpql = 0
                    if adgroup_leads_generated == 0
                      cpl = 0
                    else
                      cpl = (amount/adgroup_leads_generated).round
                    end
                    if adgroup_qualified_leads == 0
                      cpql == 0
                    else
                      cpql = (amount/adgroup_qualified_leads).round
                    end
                    adgroup_data[GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name] = [amount, adgroup_leads_generated, cpl, adgroup_qualified_leads, cpql, adgroup_sv_leads, adgroup_booked_leads]
                    creative_hash = adgroup_detail.group_by{|x| x.creative}
                    creative_data = {}
                    creative_hash.each do |creative_id, google_lead_details|
                      creative_leads_generated = 0
                      creative_qualified_leads = 0
                      creative_sv_leads = 0
                      creative_booked_leads = 0
                      google_lead_details.each do |google_lead_detail|
                        creative_leads_generated += 1
                        lead = Lead.find(google_lead_detail.lead_id)
                        if lead.qualified_on == nil
                        else
                          creative_qualified_leads += 1
                        end
                        if lead.site_visited_on == nil
                        else
                          creative_sv_leads += 1
                        end
                        if lead.booked_on == nil
                        else
                          if lead.lost_reason_id == nil
                            creative_booked_leads += 1
                          end
                        end
                      end
                      amount = 0
                      urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                      result = HTTParty.post(urlstring,
                        :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND ad_group.id = "+adgroup_id.to_s+" AND ad_group_ad.id = "+creative_id.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                      p result[0]
                      p "======================adlevel data======================="
                      if result[0] == nil
                      else
                        if result[0]["results"] != nil
                          result[0]["results"].each do |campaign|
                            amount += campaign["metrics"]["costMicros"].to_f/1000000
                            amount = amount.round
                          end
                        end
                      end
                      cpl = 0
                      cpql = 0
                      if creative_leads_generated == 0
                        cpl = 0
                      else
                        cpl = (amount/creative_leads_generated).round
                      end
                      if creative_qualified_leads == 0
                        cpql == 0
                      else
                        cpql = (amount/creative_qualified_leads).round
                      end
                      creative_data[creative_id] = [amount, creative_leads_generated, cpl, creative_qualified_leads, cpql, creative_sv_leads, creative_booked_leads]
                    end
                    adgroup_wise_ad_data[adgroup_data] = creative_data
                  else
                    adgroup_leads_generated = 0
                    adgroup_qualified_leads = 0
                    adgroup_sv_leads = 0
                    adgroup_booked_leads = 0
                    adgroup_detail.each do |google_lead_detail|
                      adgroup_leads_generated += 1
                      lead = Lead.find(google_lead_detail.lead_id)
                      if lead.qualified_on == nil
                      else
                        adgroup_qualified_leads += 1
                      end
                      if lead.site_visited_on == nil
                      else
                        adgroup_sv_leads += 1
                      end
                      if lead.booked_on == nil
                      else
                        if lead.lost_reason_id == nil
                          adgroup_booked_leads += 1
                        end
                      end
                    end
                    amount = 0
                    urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                    result = HTTParty.post(urlstring,
                      :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND ad_group.id = "+adgroup_id.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                      :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                    p result[0]
                    p "======================adgroup level data======================="
                    if result[0] == nil
                    else
                      if result[0]["results"] != nil
                        result[0]["results"].each do |campaign|
                          amount += campaign["metrics"]["costMicros"].to_f/1000000
                          amount = amount.round
                        end
                      end
                    end
                    cpl = 0
                    cpql = 0
                    if adgroup_leads_generated == 0
                      cpl = 0
                    else
                      cpl = (amount/adgroup_leads_generated).round
                    end
                    if adgroup_qualified_leads == 0
                      cpql == 0
                    else
                      cpql = (amount/adgroup_qualified_leads).round
                    end
                    adgroup_data[GoogleCampaign.where(adgroup_id: adgroup_id.to_s)[0].adgroup_name] = [amount, adgroup_leads_generated, cpl, adgroup_qualified_leads, cpql, adgroup_sv_leads, adgroup_booked_leads]
                    adgroup_wise_ad_data[adgroup_data] = {}
                  end
                end
                campaign_wise_adgroup_wise_data[campaign_data] = adgroup_wise_ad_data
              else
                leads_generated = 0
                qualified_leads = 0
                sv_leads = 0
                booked_leads = 0
                value.each do |google_lead_detail|
                  leads_generated += 1
                  lead = Lead.find(google_lead_detail.lead_id)
                  if lead.qualified_on == nil
                  else
                    qualified_leads += 1
                  end
                  if lead.site_visited_on == nil
                  else
                    sv_leads += 1
                  end
                  if lead.booked_on == nil
                  else
                    if lead.lost_reason_id == nil
                      booked_leads += 1
                    end
                  end
                end
                amount = 0
                urlstring =  "https://googleads.googleapis.com/v15/customers/"+ad_accounts[business_unit.name]+"/googleAds:searchStream"
                result = HTTParty.post(urlstring,
                  :body => {"query": "SELECT metrics.cost_micros FROM ad_group_ad WHERE campaign.id = "+key.to_s+" AND metrics.clicks > 0 AND segments.date BETWEEN '"+@from.strftime('%Y-%m-%d')+"' AND '"+@to.strftime('%Y-%m-%d')+"'"}.to_json,
                  :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer "+access_token, 'developer-token' => 'ESzFtkQZRGI8TAZPQ2JB1w', 'login-customer-id' => '2686097137' })
                if result[0] == nil
                else
                  if result[0]["results"] != nil
                    result[0]["results"].each do |campaign|
                      amount += campaign["metrics"]["costMicros"].to_f/1000000
                      amount = amount.round
                    end
                  end
                end
                cpl = 0
                cpql = 0
                if leads_generated == 0
                  cpl = 0
                else
                  cpl = (amount/leads_generated).round
                end
                if qualified_leads == 0
                  cpql == 0
                else
                  cpql = (amount/qualified_leads).round
                end
                campaign_data[GoogleCampaign.where(campaign_id: key.to_s)[0].campaign_name] = [amount, leads_generated, cpl, qualified_leads, cpql, sv_leads, booked_leads]
                campaign_wise_adgroup_wise_data[campaign_data] = {}
              end
            end
          end
        end
        @google_data["adgroup_ad"] = campaign_wise_adgroup_wise_data
      end
    end
  end

  def fb_costing_report
    @projects = selections_with_all(BusinessUnit, :name)
    lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
    lost_reasons = lost_reasons-[57,49]
    lost_reasons = lost_reasons+[nil]
    @all_fb_sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%FACEBOOK%').uniq.pluck(:heirarchy)
    if params[:business_unit_id] == nil
    else
      @total_leads_data = []
      @cpl_data = []
      @qualified_leads = []
      @cpql_data = []
      @qualified_percentage = []
      @sv_leads = []
      @cpsv_data = []
      @sv_percentage = []
      @booking_leads = []
      @cpbooking_data = []
      @booking_percentage = []
      total_expense = []
      @weeks = []
      @months = []
      @project_selected = params[:business_unit_id].to_i
      @report_type = params[:report_type]
      @fb_sources = SourceCategory.where(id: (Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}).where('leads.created_at >= ? AND leads.created_at < ?', (DateTime.now.beginning_of_month-2.month).to_datetime, DateTime.now.beginning_of_day+1.day).pluck(:source_category_id).uniq)).where('heirarchy like ?', '%FACEBOOK%').uniq.pluck(:heirarchy)
      @source = SourceCategory.where('heirarchy like ?', "%"+params[:source]+"%").pluck(:id).uniq
      @picked_source = SourceCategory.where(heirarchy: params[:source])[0].heirarchy
      if @report_type == "Weekly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: @source).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_week-13.weeks, DateTime.now.end_of_week+1.day).sort_by{|lead| lead.created_at}.group_by{|x| x.generated_on.to_date.cweek}
        facebook_ads = FacebookAd.where(source_category_id: @source, business_unit_id: @project_selected)
        ad_ids = facebook_ads.map{|x| x.ad_id}
        leads_generated_raw.each do |key, value|
          @total_leads_data += [value.count]
          if key.to_s.length == 1
            key = ('0'+key.to_s)
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          else
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          end
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
          end
          @qualified_leads += [qualify_count]
          @sv_leads += [sv_count]
          total_expense = WeeklyFacebookExpense.where(ad_id: ad_ids, week: key).sum(:amount)
          if qualify_count == 0
            cpql = 0
            @qualified_percentage += [0]
          else
            cpql = (total_expense/qualify_count)
            @qualified_percentage += [(((qualify_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if sv_count == 0
            cpsv = 0
            @sv_percentage += [0]
          else
            cpsv = (total_expense/sv_count)
            @sv_percentage += [(((sv_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if value.count == 0
            cpl = 0
          else
            cpl = (total_expense/value.count)
          end
          @cpql_data += [cpql.round]
          @cpsv_data += [cpsv.round]
          @cpl_data += [cpl.round]
        end
        @weeks = @weeks.to_json.html_safe
      elsif @report_type == "Monthly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: @source).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
        facebook_ads = FacebookAd.where(source_category_id: @source, business_unit_id: @project_selected)
        ad_ids = facebook_ads.map{|x| x.ad_id}
        leads_generated_raw.each do |key, value|
          @months += [Date::MONTHNAMES[key[1]]]
          @total_leads_data += [value.count]
          qualify_count = 0
          sv_count = 0
          booking_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
            if lead.lost_reason_id == nil && lead.booked_on != nil
              booking_count += 1
            end
          end
          @qualified_leads += [qualify_count]
          @sv_leads += [sv_count]
          @booking_leads += [booking_count]
          total_expense = MonthlyFacebookExpense.where(ad_id: ad_ids, month: key[1]).sum(:amount)
          if qualify_count == 0
            cpql = 0
            @qualified_percentage += [0]
          else
            cpql = (total_expense/qualify_count)
            @qualified_percentage += [(((qualify_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if sv_count == 0
            cpsv = 0
            @sv_percentage += [0]
          else
            cpsv = (total_expense/sv_count)
            @sv_percentage += [(((sv_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if booking_count == 0
            cpbooking = 0
            @booking_percentage += [0]
          else
            cpbooking = (total_expense/booking_count)
            @booking_percentage += [(((booking_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if value.count == 0
            cpl = 0
          else
            cpl = (total_expense/value.count)
          end
          @cpql_data += [cpql.round]
          @cpsv_data += [cpsv.round]
          @cpbooking_data += [cpbooking.round]
          @cpl_data += [cpl.round]
        end
        @months = @months.to_json.html_safe
      end
    end
  end

  def google_costing_report
    @projects = selections_with_all(BusinessUnit, :name)
    lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
    lost_reasons = lost_reasons-[57,49]
    lost_reasons = lost_reasons+[nil]
    @all_google_sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%Google%').uniq.pluck(:heirarchy)
    if params[:business_unit_id] == nil
    else
      @total_leads_data = []
      @cpl_data = []
      @qualified_leads = []
      @cpql_data = []
      @qualified_percentage = []
      @sv_leads = []
      @cpsv_data = []
      @sv_percentage = []
      @booking_leads = []
      @cpbooking_data = []
      @booking_percentage = []
      total_expense = []
      @weeks = []
      @months = []
      @project_selected = params[:business_unit_id].to_i
      @report_type = params[:report_type]
      @google_sources = SourceCategory.where(id: (Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}).where('leads.created_at >= ? AND leads.created_at < ?', (DateTime.now.beginning_of_month-2.month).to_datetime, DateTime.now.beginning_of_day+1.day).pluck(:source_category_id).uniq)).where('heirarchy like ?', '%Google%').uniq.pluck(:heirarchy)
      @source = SourceCategory.where('heirarchy like ?', "%"+params[:source]+"%").pluck(:id).uniq
      if @report_type == "Weekly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: @source).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_week-13.weeks, DateTime.now.end_of_week+1.day).sort_by{|lead| lead.created_at}.group_by{|x| x.generated_on.to_date.cweek}
        ad_ids = WeeklyGoogleExpense.where(business_unit_id: @project_selected).map{|x| x.ad_id}.uniq
        leads_generated_raw.each do |key, value|
          @total_leads_data += [value.count]
          if key.to_s.length == 1
            key = ('0'+key.to_s)
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          else
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          end
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
          end
          @qualified_leads += [qualify_count]
          @sv_leads += [sv_count]
          total_expense = WeeklyGoogleExpense.where(ad_id: ad_ids, week: key).sum(:amount)
          if qualify_count == 0
            cpql = 0
            @qualified_percentage += [0]
          else
            cpql = (total_expense/qualify_count)
            @qualified_percentage += [(((qualify_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if sv_count == 0
            cpsv = 0
            @sv_percentage += [0]
          else
            cpsv = (total_expense/sv_count)
            @sv_percentage += [(((sv_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if value.count == 0
            cpl = 0
          else
            cpl = (total_expense/value.count)
          end
          @cpql_data += [cpql.round]
          @cpsv_data += [cpsv.round]
          @cpl_data += [cpl.round]
        end
        @weeks = @weeks.to_json.html_safe
      elsif @report_type == "Monthly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: @source).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
        ad_ids = MonthlyGoogleExpense.where(business_unit_id: @project_selected).map{|x| x.ad_id}.uniq
        leads_generated_raw.each do |key, value|
          @months += [Date::MONTHNAMES[key[1]]]
          @total_leads_data += [value.count]
          qualify_count = 0
          sv_count = 0
          booking_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
            if lead.lost_reason_id == nil && lead.booked_on != nil
              booking_count += 1
            end
          end
          @qualified_leads += [qualify_count]
          @sv_leads += [sv_count]
          @booking_leads += [booking_count]
          total_expense = MonthlyGoogleExpense.where(ad_id: ad_ids, month: key[1]).sum(:amount)
          if qualify_count == 0
            cpql = 0
            @qualified_percentage += [0]
          else
            cpql = (total_expense/qualify_count)
            @qualified_percentage += [(((qualify_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if sv_count == 0
            cpsv = 0
            @sv_percentage += [0]
          else
            cpsv = (total_expense/sv_count)
            @sv_percentage += [(((sv_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if booking_count == 0
            cpbooking = 0
            @booking_percentage += [0]
          else
            cpbooking = (total_expense/booking_count)
            @booking_percentage += [(((booking_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if value.count == 0
            cpl = 0
          else
            cpl = (total_expense/value.count)
          end
          @cpql_data += [cpql.round]
          @cpsv_data += [cpsv.round]
          @cpbooking_data += [cpbooking.round]
          @cpl_data += [cpl.round]
        end
        @months = @months.to_json.html_safe
      end
    end
  end

  def fb_google_costing_report
    @report_type = ["Facebook", "Google"]
    @projects = selections_with_all(BusinessUnit, :name)
    lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
    lost_reasons = lost_reasons-[57,49]
    lost_reasons = lost_reasons+[nil]
    @calculation_type = ["Weekly", "Monthly"]
    if params[:report_type] == nil
      fb_sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%FACEBOOK%').uniq.pluck(:heirarchy)
      google_sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%Google%').uniq.pluck(:heirarchy)
      @all_sources = (fb_sources + google_sources).sort
      @source_selected = SourceCategory.where(heirarchy: "Online . FACEBOOK")[0]
    else
      @report_selected = params[:report_type]
      @project_selected = params[:business_unit_id].to_i
      @calculation_type_selected = params[:calculation_type]
      @source_selected = SourceCategory.where(heirarchy: params[:source_category])[0]
      @source = SourceCategory.where('heirarchy like ?', "%"+params[:source_category]+"%").pluck(:id).uniq
      if params[:report_type] == "Facebook"
        @all_sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%FACEBOOK%').uniq.pluck(:heirarchy)
      elsif params[:report_type] == "Google"
        @all_sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%Google%').uniq.pluck(:heirarchy)
      end
      @total_leads_data = []
      @cpl_data = []
      @qualified_leads = []
      @cpql_data = []
      @qualified_percentage = []
      @sv_leads = []
      @cpsv_data = []
      @sv_percentage = []
      @booking_leads = []
      @cpbooking_data = []
      @booking_percentage = []
      total_expense = []
      @weeks = []
      @months = []
      if @calculation_type_selected == "Weekly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: @source).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_week-13.weeks, DateTime.now.end_of_week+1.day).sort_by{|lead| lead.created_at}.group_by{|x| x.generated_on.to_date.cweek}
        p leads_generated_raw
        p "======================================"
        if @report_selected == "Facebook"
          facebook_ads = FacebookAd.where(source_category_id: @source, business_unit_id: @project_selected)
          ad_ids = facebook_ads.map{|x| x.ad_id}
        elsif@report_selected == "Google"
          ad_ids = WeeklyGoogleExpense.where(business_unit_id: @project_selected).map{|x| x.ad_id}.uniq
        end
        leads_generated_raw.each do |key, value|
          @total_leads_data += [value.count]
          if key.to_s.length == 1
            key = ('0'+key.to_s)
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          else
            @weeks += [Date.parse("'"+'W'+key.to_s+"'").end_of_week.strftime('%d/%m/%Y')]
          end
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
          end
          @qualified_leads += [qualify_count]
          @sv_leads += [sv_count]
          if @report_selected == "Facebook"
            total_expense = WeeklyFacebookExpense.where(ad_id: ad_ids, week: key).sum(:amount)
          elsif @report_selected == "Google"
            total_expense = WeeklyGoogleExpense.where(ad_id: ad_ids, week: key).sum(:amount)
          end
          if qualify_count == 0
            cpql = 0
            @qualified_percentage += [0]
          else
            cpql = (total_expense/qualify_count)
            @qualified_percentage += [(((qualify_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if sv_count == 0
            cpsv = 0
            @sv_percentage += [0]
          else
            cpsv = (total_expense/sv_count)
            @sv_percentage += [(((sv_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if value.count == 0
            cpl = 0
          else
            cpl = (total_expense/value.count)
          end
          @cpql_data += [cpql.round]
          @cpsv_data += [cpsv.round]
          @cpl_data += [cpl.round]
        end
        @weeks = @weeks.to_json.html_safe
      elsif @calculation_type_selected == "Monthly"
        leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: @source).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
        if @report_selected == "Facebook"
          facebook_ads = FacebookAd.where(source_category_id: @source, business_unit_id: @project_selected)
          ad_ids = facebook_ads.map{|x| x.ad_id}
        elsif@report_selected == "Google"
          ad_ids = MonthlyGoogleExpense.where(business_unit_id: @project_selected).map{|x| x.ad_id}.uniq
        end
        leads_generated_raw.each do |key, value|
          @months += [Date::MONTHNAMES[key[1]]]
          @total_leads_data += [value.count]
          qualify_count = 0
          sv_count = 0
          booking_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end
            if lead.lost_reason_id == nil && lead.booked_on != nil
              booking_count += 1
            end
          end
          @qualified_leads += [qualify_count]
          @sv_leads += [sv_count]
          @booking_leads += [booking_count]
          if @report_selected == "Facebook"
            total_expense = MonthlyFacebookExpense.where(ad_id: ad_ids, month: key[1]).sum(:amount)
          elsif @report_selected == "Google"
            total_expense = MonthlyGoogleExpense.where(ad_id: ad_ids, month: key[1]).sum(:amount)
          end
          if qualify_count == 0
            cpql = 0
            @qualified_percentage += [0]
          else
            cpql = (total_expense/qualify_count)
            @qualified_percentage += [(((qualify_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if sv_count == 0
            cpsv = 0
            @sv_percentage += [0]
          else
            cpsv = (total_expense/sv_count)
            @sv_percentage += [(((sv_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if booking_count == 0
            cpbooking = 0
            @booking_percentage += [0]
          else
            cpbooking = (total_expense/booking_count)
            @booking_percentage += [(((booking_count.to_f/value.count.to_f).to_f)*100).round]
          end
          if value.count == 0
            cpl = 0
          else
            cpl = (total_expense/value.count)
          end
          @cpql_data += [cpql.round]
          @cpsv_data += [cpsv.round]
          @cpbooking_data += [cpbooking.round]
          @cpl_data += [cpl.round]
        end
        @months = @months.to_json.html_safe
      end
    end
  end

  def populate_sources
    @report_type = params[:report_type]
    if @report_type == "Facebook"
      @sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%FACEBOOK%').uniq.pluck(:heirarchy)
    elsif @report_type == "Google"
      @sources = SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(inactive: true).where('heirarchy like ?', '%Google%').uniq.pluck(:heirarchy)
    end
    respond_to do |format|
      format.js { render :action => "populate_sources"}
    end
  end

  def sr_call_report
    if params[:from] == nil
      @from = DateTime.now-2.days
      @to = DateTime.now
      @telephony_calls = TelephonyCall.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
    else
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @telephony_calls = TelephonyCall.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
    end
  end

  def not_connected_calling_gap
    if params[:from] == nil
      @from = DateTime.now-1.days
      @to = DateTime.now
      telephony_calls = TelephonyCall.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
    else
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      telephony_calls = TelephonyCall.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('telephony_calls.created_at >= ? AND telephony_calls.created_at < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
    end

    personnels = []
    Personnel.where(organisation_id: 1, access_right: 2).each do |personnel|
      if personnel.name == "Tapan Samanta" || personnel.name == "Rahul Singh" || personnel.name == "Nitesh Maheshwari" || personnel.name == "Kazi Shahadat Hossain"
      else
        personnels += [personnel]
      end
    end
    @telecaller_wise_data = {}
    personnels.each do |personnel|
      total_gap = 0
      total_calls = 0
      telephony_calls.where('telephony_calls.agent_number = ?', personnel.mobile).each do |telephony_call|
        previous_telephony_calls = TelephonyCall.where(agent_number: personnel.mobile, customer_number: telephony_call.customer_number).where('start_time < ?', telephony_call.start_time)
        previous_telephony_call = previous_telephony_calls.sort_by{|x| x.start_time}.last
        if previous_telephony_call == nil
        else
          if previous_telephony_call.call_type == 'Missed'
            total_gap += telephony_call.start_time-previous_telephony_call.start_time
            total_calls += 1
          end
        end
      end
      average_gap = (((total_gap/total_calls))/60/60).to_i
      p personnel.name
      p average_gap  
      @telecaller_wise_data[personnel.name] = average_gap
    end
  end

  def telecaller_calling_report
    @telecaller_wise_data = {}
    personnels = []
    Personnel.where(organisation_id: 1, access_right: 2).each do |personnel|
      if personnel.name == "Tapan Samanta" || personnel.name == "Rahul Singh" || personnel.name == "Nitesh Maheshwari" || personnel.name == "Kazi Shahadat Hossain"
      else
        personnels += [personnel]
      end
    end
    if params[:from] == nil
      @from = DateTime.now.beginning_of_day-3.days
      @to = DateTime.now
    else
      @from = params[:from].to_datetime.beginning_of_day
      @to = params[:to].to_datetime.end_of_day
    end
    source_categories = SourceCategory.where(organisation_id: current_personnel.organisation_id, inactive: [nil, false]).where('heirarchy like ?', '%Online%').pluck(:id).uniq
    all_sources = source_categories
    all_sources += [nil]
    personnels.each do |personnel|
      qualified = 0
      site_visited = 0
      attempted_calls = TelephonyCall.where(agent_number: personnel.mobile).where.not(duration: 0.0, call_type: "None").where('start_time >= ? and start_time <= ?', @from, @to)
      if attempted_calls == []
        attempted_calls = 0
      else
        attempted_calls = attempted_calls.count
      end
      if personnel.name == "Olivia De"
        qualified = FollowUp.includes(:lead).where(:leads => {business_unit_id: personnel.business_unit_id, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.qualified_on >= ? AND leads.qualified_on < ?', @from, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
        site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: personnel.business_unit_id, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count

        qualified += FollowUp.includes(:lead).where(:leads => {business_unit_id: 68, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.qualified_on >= ? AND leads.qualified_on < ?', @from, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
        site_visited += FollowUp.includes(:lead).where(:leads => {business_unit_id: 68, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
      else
        qualified = FollowUp.includes(:lead).where(:leads => {business_unit_id: personnel.business_unit_id, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.qualified_on >= ? AND leads.qualified_on < ?', @from, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
        site_visited = FollowUp.includes(:lead).where(:leads => {business_unit_id: personnel.business_unit_id, source_category_id: all_sources}, personnel_id: personnel.id).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?', @from, @to.beginning_of_day+1.day).pluck(:lead_id).uniq.count
      end
      connected_calls = TelephonyCall.where(agent_number: personnel.mobile, call_type: 'Connected').where('start_time >= ? and start_time < ?', @from, @to.beginning_of_day+1.day)
      if connected_calls == []
        connected_calls = 0
      else
        connected_calls = connected_calls.count
      end
      connected_call_duration = TelephonyCall.where(agent_number: personnel.mobile, call_type: 'Connected').where('start_time >= ? and start_time < ?', @from, @to.beginning_of_day+1.day)
      if connected_call_duration == []
        connected_call_duration = 0
      else
        connected_call_duration = connected_call_duration.sum(:duration)
        connected_call_duration = (connected_call_duration/3600.0).round(2)
      end
      not_connected_calls = TelephonyCall.where(agent_number: personnel.mobile, call_type: 'Missed').where('start_time >= ? and start_time < ? and duration > ?', @from, @to.beginning_of_day+1.day, 0.0)
      if not_connected_calls == []
        not_connected_calls = 0
      else
        not_connected_calls = not_connected_calls.count
      end
      not_connected_call_duration = TelephonyCall.where(agent_number: personnel.mobile, call_type: 'Missed').where('start_time >= ? and start_time < ? and duration > ?', @from, @to.beginning_of_day+1.day, 0.0)
      if not_connected_call_duration == []
        not_connected_call_duration = 0
      else
        not_connected_call_duration = not_connected_call_duration.sum(:duration)
        not_connected_call_duration = (not_connected_call_duration/3600.0).round(2)
      end
      calls = TelephonyCall.where(agent_number: personnel.mobile).where.not(duration: 0.0, call_type: "None").where('start_time >= ? and start_time < ?', @from, @to.beginning_of_day+1.day)
      grouped_calls = calls.group_by { |call| call.start_time.to_date }
      p "======================personnel======================="
      p personnel.name
      sorted_gc = grouped_calls.sort_by{|x,y| x}

      sorted_gc.each do |call_day, calls|
        p call_day
        p "-------------"
        p calls.sort_by{|x| x.start_time}.first.start_time
        p "-------------"
        p calls.count
      end
      sorted_gc.each do |call_day, calls|
        p call_day
        p "-------------"
        p calls.sort_by{|x| x.created_at}.last.created_at
        p "-------------"
        p calls.count
      end
      total_working_days = 0
      grouped_calls.each do |key, value|
        if value.count < 25
        else
          total_working_days += 1
        end
      end
      p total_working_days
      p "============total working days============="
      if grouped_calls == {}
        average_start_time = "-"
        average_end_time = "-"
      else
        average_first_call_time = grouped_calls.map { |_, calls| calls.min_by(&:start_time).start_time.seconds_since_midnight }.sum / grouped_calls.size
        average_last_call_time = grouped_calls.map { |_, calls| calls.max_by(&:created_at).created_at.seconds_since_midnight }.sum / grouped_calls.size

        average_first_call_time=average_first_call_time
        average_last_call_time=average_last_call_time+5.hours+30.minutes

        average_start_time = Time.zone.at(average_first_call_time % 1.day.seconds).utc.strftime("%H:%M:%S")
        average_end_time = Time.zone.at(average_last_call_time % 1.day.seconds).utc.strftime("%H:%M:%S")
      end
      @telecaller_wise_data[personnel.name] = [total_working_days, attempted_calls, connected_calls, connected_call_duration, not_connected_call_duration, qualified, site_visited, average_start_time, average_end_time]
    end
  end

  def organic_and_paid_lead_report
    @projects = selections(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @selected_project = 70
      @from = DateTime.now-7.days
      @to = DateTime.now
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      @leads = Lead.where(source_category_id: 1058, business_unit_id: @selected_project, lost_reason_id: lost_reasons).where('generated_on >= ? AND generated_on < ?', @from, @to.beginning_of_day+1.day)
    else
      @selected_project = params[:business_unit_id]
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      @leads = Lead.where(source_category_id: 1058, business_unit_id: @selected_project, lost_reason_id: lost_reasons).where('generated_on >= ? AND generated_on < ?', @from, @to.beginning_of_day+1.day)
    end
  end

  def organic_and_paid_lead_report_web_conversion
    if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
      @projects = [["Dream Gurukul", 70]]
    else
      @projects = selections(BusinessUnit, :name)
    end
    if params[:business_unit_id] == nil
      @selected_project = 70
      @from = DateTime.now-7.days
      @to = DateTime.now
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      @leads = Lead.where(source_category_id: 5232, business_unit_id: @selected_project, lost_reason_id: lost_reasons).where('generated_on >= ? AND generated_on < ?', @from, @to.beginning_of_day+1.day)
    else
      @selected_project = params[:business_unit_id]
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      lost_reasons = lost_reasons-[57,49]
      lost_reasons = lost_reasons+[nil]
      @leads = Lead.where(source_category_id: 5232, business_unit_id: @selected_project, lost_reason_id: lost_reasons).where('generated_on >= ? AND generated_on < ?', @from, @to.beginning_of_day+1.day)
    end
  end

  def site_visit_form_register
    if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
      @projects = [["Dream Gurukul", 70]]
    else
      @projects = selections_with_all(BusinessUnit, :name)
    end
    if params[:business_unit_id] == nil
      @project_selected = BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      @from = DateTime.now-10.days
      @to = DateTime.now
      @leads = []
    else
      @project_selected = params[:business_unit_id]
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @leads = Lead.where(business_unit_id: @project_selected.to_i).where('site_visited_on >= ? AND site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
    end
  end

  def call_recording_index
    executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right = ?', 2)
    @executives = []
    executives.each do |executive|
      @executives += [[executive.name, executive.id]]
    end
    @executives.sort!
    if params[:current_executive_id] == nil
      @executive = current_personnel
      @leads = []
    else
      @executive = Personnel.find(params[:current_executive_id]) 
      @leads = Lead.where(personnel_id: @executive, business_unit_id: @executive.business_unit_id, lost_reason_id: nil) 
    end
  end

  def lead_wise_recording
    @lead = Lead.find(params[:format])
    @telephony_calls = TelephonyCall.where(id: (FollowUp.where(lead_id: @lead.id).where.not(telephony_call_id: nil)).pluck(:telephony_call_id))
  end
end