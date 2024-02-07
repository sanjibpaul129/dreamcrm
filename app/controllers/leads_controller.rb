class LeadsController < ApplicationController
  before_action :set_lead, only: [:show, :edit, :update, :destroy]

  # GET /leads
  # GET /leads.json
  def index
    @leads = Lead.all
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
  end

  def home

    if (FollowUp.where('created_at >= ? and first = ? and personnel_id = ?', Time.now.beginning_of_month, true, current_personnel.id).count)==0
    @fresh_lead_mis_score=0
    else 
    @fresh_lead_mis_score=((FollowUp.where('created_at >= ? and first = ? and personnel_id = ?', Time.now.beginning_of_month, true, current_personnel.id).sum(:score))/(FollowUp.where('created_at >= ? and first = ? and personnel_id = ?', Time.now.beginning_of_month, true, current_personnel.id).count)).round
    end
    if (FollowUp.where('created_at >= ? and first is ? and personnel_id = ?', Time.now.beginning_of_month, nil, current_personnel.id).count)==0
    @follow_up_mis_score=0
    else
    @follow_up_mis_score=((FollowUp.where('created_at >= ? and first is ? and personnel_id = ?', Time.now.beginning_of_month, nil, current_personnel.id).sum(:score))/(FollowUp.where('created_at >= ? and first is ? and personnel_id = ?', Time.now.beginning_of_month, nil, current_personnel.id).count)).round
    end
    #---------counters & responsiveness--------------------#
    if params[:project]==nil
    elsif params[:holiday]==nil
      current_personnel.organisation.update(holiday: nil)
    elsif params[:holiday]=='holiday'
      current_personnel.organisation.update(holiday: true)
    end
      
    if params[:project]==nil
    elsif params[:auto_allocate]==nil
      current_personnel.organisation.update(auto_allocate: nil)
    elsif params[:auto_allocate]=='auto_allocate'
      current_personnel.organisation.update(auto_allocate: true)
    end

    if params[:project]==nil
    elsif params[:absent]==nil
      current_personnel.update(absent: nil)
    elsif params[:absent]=='absent'
      current_personnel.update(absent: true)
    end

    if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
    @fresh_calls_this_month=Lead.joins(:follow_ups, :business_unit).where( :follow_ups => { :first => true }, :business_units => { :organisation_id => current_personnel.organisation_id}).where('leads.generated_on >= ?', Time.now.beginning_of_month)
    @follow_ups_this_month=FollowUp.joins(:lead => [:business_unit]).where(first: nil, :business_units => { :organisation_id => current_personnel.organisation_id }).where('follow_ups.created_at >= ?', Time.now.beginning_of_month)
    @fresh_lead_count=Lead.includes(:follow_ups, :business_unit, :personnel).where( :leads => { :status => nil }, :follow_ups => { :lead_id => nil }, :business_units => { :organisation_id => current_personnel.organisation_id } ).where.not(:personnels => {access_right: -1}).count  
    @followup_due_count=Lead.joins(:follow_ups, :business_unit, :personnel).where( :follow_ups => { :last => true }, :business_units => { :organisation_id => current_personnel.organisation_id } ).where.not(:personnels => {access_right: -1}).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).count
    elsif current_personnel.status=='Team Lead'
    @fresh_calls_this_month=Lead.joins(:follow_ups).where( :follow_ups => { :first => true }, :leads => { :personnel_id => current_personnel.member_array } ).where('leads.generated_on >= ?', Time.now.beginning_of_month)  
    @follow_ups_this_month=FollowUp.where(first: nil, personnel_id: current_personnel.member_array).where('created_at >= ?', Time.now.beginning_of_month)
    @fresh_lead_count=Lead.includes(:follow_ups, :personnel).where(:leads => { :status => nil }, :follow_ups => { :lead_id => nil } ).where(:leads => { :personnel_id => current_personnel.member_array } ).where.not(:personnels => {access_right: -1}).count  
    @followup_due_count=Lead.joins(:follow_ups, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => current_personnel.member_array } ).where.not(:personnels => {access_right: -1}).count
    elsif current_personnel.status=='Sales Executive'  
    @fresh_calls_this_month=Lead.joins(:follow_ups).where( :follow_ups => { :first => true }).where('leads.personnel_id = ? AND leads.generated_on >= ?', current_personnel.id, Time.now.beginning_of_month)
    @follow_ups_this_month=FollowUp.where(first: nil, personnel_id: current_personnel.id).where('created_at >= ?', Time.now.beginning_of_month)
    @fresh_lead_count=Lead.includes(:follow_ups).where(:follow_ups => { :lead_id => nil }, :leads => { :personnel_id => current_personnel.id, :status => nil } ).count
    @followup_due_count=Lead.joins(:follow_ups).where(:follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => current_personnel.id }).count
    end

    #-----------responsiveness-------------------------------#

    
      # @follow_ups_response_hours=@follow_ups_this_month.select("avg(communication_time-scheduled_time) as response_time")
      # if @follow_ups_response_hours[0].response_time.to_s==''
      # @follow_ups_responsiveness=0
      # else
      # @follow_ups_responsiveness=convert_interval_to_hours(@follow_ups_response_hours[0].response_time.to_s).to_f
      # end

      # @fresh_leads_response_hours=@fresh_calls_this_month.select("avg(follow_ups.created_at-leads.created_at) as response_time")
      # if @fresh_leads_response_hours[0].response_time.to_s==''
      # @fresh_calls_responsiveness=0
      # else
      # @fresh_calls_responsiveness=convert_interval_to_hours(@fresh_leads_response_hours[0].response_time.to_s).to_f
      # end

      # @lead_distribution_response_hours=Lead.where('created_at >= ?', Time.now.beginning_of_month).select("avg(created_at-generated_on) as response_time")
      # if @lead_distribution_response_hours[0].response_time.to_s==''
      # @lead_distribution_responsiveness=0
      # else
      # @lead_distribution_responsiveness=convert_interval_to_hours(@lead_distribution_response_hours[0].response_time.to_s).to_f
      # end    

    #--------- 6 months stats-------------------#

    @projects=selections_with_all(BusinessUnit, :name)
    if current_personnel.status=='Team Lead'
    @executives=[['All', -1]]
      current_personnel.member_array.each do |team_member|
      @executives+=[[Personnel.find(team_member).name, team_member]] 
      end  
    else
    @executives=selections_with_all(Personnel, :name)
    end

    if params[:project]!= nil
      @project_selected=params[:project][:selected].to_i
    else
      @project_selected=-1
    end

    if @project_selected==-1
    @project_selected=[]
      BusinessUnit.where(organisation_id: current_personnel.organisation_id).each do |business_unit|
        @project_selected+=[business_unit.id]  
      end  
    end

    array_of_executives=[]
    if params[:executive]!= nil
      @executive_selected=params[:executive][:selected].to_i
        if @executive_selected==-1
          if current_personnel.status=='Team Lead'
          array_of_executives=current_personnel.member_array
          else
            Personnel.where(organisation_id: current_personnel.organisation_id).each do |executive|
            array_of_executives=array_of_executives+[executive.id]
            end
          end
        else
        array_of_executives=[@executive_selected]
        end
    else
        @executive_selected=-1
        if current_personnel.status=='Team Lead'
        array_of_executives=current_personnel.member_array
        else
          Personnel.where(organisation_id: current_personnel.organisation_id).each do |executive|
          array_of_executives=array_of_executives+[executive.id]
          end
        end
    end

    
    leads_generated_hash={}
    fresh_calls_hash={}
    follow_ups_hash={}
    lost_hash={}
    site_visited_hash={}
    booked_hash={}

    leads_generated_hash[:name]='Leads generated'
    fresh_calls_hash[:name]='Fresh Calls'
    fresh_calls_hash[:visible]=false
    follow_ups_hash[:name]='Follow Ups'
    follow_ups_hash[:visible]=false
    lost_hash[:name]='Lost'
    lost_hash[:visible]=false
    site_visited_hash[:name]='Site visited'
    booked_hash[:name]='Booked'

    leads_generated_data=[]
    fresh_calls_data=[]
    follow_ups_data=[]
    lost_data=[]
    site_visited_data=[]
    booked_data=[]

    month_count=5 
    @months=[]

    count=6
    6.times do

    @months=@months+[Date::MONTHNAMES[((Time.now)-(month_count.months)).month]]


    year=((Time.now)-(month_count.months)).year
    month=((Time.now)-(month_count.months)).month
      if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
        leads_generated_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, business_unit_id: @project_selected, personnel_id: array_of_executives).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count]
        site_visited_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, business_unit_id: @project_selected, personnel_id: array_of_executives).where.not(site_visited_on: nil).where("extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?", year, month).count]
        fresh_calls_data+=[FollowUp.includes(:personnel, :lead).where(:personnels => {id: array_of_executives}, first: true, :leads => {business_unit_id: @project_selected}).where("extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?", year, month).count]
        follow_ups_data+=[FollowUp.includes(:personnel, :lead).where(:personnels => {id: array_of_executives}, first: nil, :leads => {business_unit_id: @project_selected}).where("extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?", year, month).count]
        lost_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, status: true, business_unit_id: @project_selected, personnel_id: array_of_executives).where.not(lost_reason_id: nil).where("extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?", year, month).count]
        booked_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: nil, status: true, business_unit_id: @project_selected, personnel_id: array_of_executives).where("extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?", year, month).count]
      elsif current_personnel.status=='Team Lead'
        leads_generated_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: array_of_executives, business_unit_id: @project_selected).where("extract(year from leads.created_at) = ? AND extract(month from leads.generated_on) = ?", year, month).count]
        site_visited_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: array_of_executives, business_unit_id: @project_selected).where.not(site_visited_on: nil).where("extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?", year, month).count]
        fresh_calls_data+=[FollowUp.includes(:personnel, :lead).where(:personnels => {id: array_of_executives}, first: true, :leads => {business_unit_id: @project_selected}).where("extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?", year, month).count]
        follow_ups_data+=[FollowUp.includes(:personnel, :lead).where(:personnels => {id: array_of_executives}, first: nil, :leads => {business_unit_id: @project_selected}).where("extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?", year, month).count]
        lost_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, status: true, personnel_id: array_of_executives, business_unit_id: @project_selected).where.not(lost_reason_id: nil).where("extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?", year, month).count]
        booked_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: nil, status: true, personnel_id: array_of_executives, business_unit_id: @project_selected).where("extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?", year, month).count]
      elsif current_personnel.status=='Sales Executive'
        leads_generated_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: current_personnel.id).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count]
        site_visited_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: current_personnel.id).where.not(site_visited_on: nil).where("extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?", year, month).count]
        fresh_calls_data+=[FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: true, :leads => {business_unit_id: @project_selected}).where("extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?", year, month).count]
        follow_ups_data+=[FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: nil, :leads => {business_unit_id: @project_selected}).where("extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?", year, month).count]
        lost_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, status: true, personnel_id: current_personnel.id).where.not(lost_reason_id: nil).where("extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?", year, month).count]
        booked_data+=[Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: nil, status: true, personnel_id: current_personnel.id).where("extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?", year, month).count]
      end
    month_count=month_count-1
    end

    leads_generated_hash[:data]=leads_generated_data
    fresh_calls_hash[:data]=fresh_calls_data
    follow_ups_hash[:data]=follow_ups_data
    lost_hash[:data]=lost_data
    site_visited_hash[:data]=site_visited_data
    booked_hash[:data]=booked_data
    @series=[leads_generated_hash, fresh_calls_hash, follow_ups_hash, lost_hash, site_visited_hash, booked_hash].to_json.html_safe
    @months=@months.to_json.html_safe

    if @project_selected.kind_of?(Array)
      @project_selected=-1
    end

    #-------------------source wise variable pie chart---------------------#    

    if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Team Lead' || current_personnel.status=='Marketing'
    
    if @project_selected==-1
      leads_source=Lead.includes(:source_category, :personnel).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where('leads.generated_on >= ?',Time.now.beginning_of_month)
      site_visit_source=Lead.includes(:source_category).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where('leads.site_visited_on >= ?',Time.now.beginning_of_month)
      booking_source=Lead.includes(:source_category).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where(lost_reason_id: nil, status: true).where('leads.booked_on >= ?',Time.now.beginning_of_month)
    else
      leads_source=Lead.includes(:source_category, :personnel).where(business_unit_id: @project_selected).where('generated_on >= ?',Time.now.beginning_of_month)
      site_visit_source=Lead.where(business_unit_id: @project_selected).where('site_visited_on >= ?',Time.now.beginning_of_month)
      booking_source=Lead.where(business_unit_id: @project_selected).where(lost_reason_id: nil, status: true).where('booked_on >= ?',Time.now.beginning_of_month)
    end
    @site_visited_data=[]
    @booked_data=[]

    SourceCategory.where(organisation_id: current_personnel.organisation_id).each do |source|

      if leads_source.where(source_category_id: source.id)==[] && site_visit_source.where(source_category_id: source.id)==[]  
      else
      site_visit_hash={}
      site_visit_hash[:name]=source.description
        if leads_source.where(source_category_id: source.id)==[]
        site_visit_hash[:y]=0
        else
        site_visit_hash[:y]=leads_source.where(source_category_id: source.id).count  
        end
        if site_visit_source.where(source_category_id: source.id)==[]
        site_visit_hash[:z]=0
        else
        site_visit_hash[:z]=site_visit_source.where(source_category_id: source.id).count  
        end
      @site_visited_data+=[site_visit_hash]  
      end

      if leads_source.where(source_category_id: source.id)==[] && booking_source.where(source_category_id: source.id)==[]  
      else
      booked_hash={}
      booked_hash[:name]=source.description
        if leads_source.where(source_category_id: source.id)==[]
        booked_hash[:y]=0
        else
        booked_hash[:y]=leads_source.where(source_category_id: source.id).count  
        end
        if booking_source.where(source_category_id: source.id)==[]
        booked_hash[:z]=0
        else
        booked_hash[:z]=booking_source.where(source_category_id: source.id).count  
        end
      @booked_data+=[booked_hash]  
      end
    end
    @booked_data=@booked_data.to_json.html_safe
    @site_visited_data=@site_visited_data.to_json.html_safe

#------------6 months variable pie---------------#

    six_leads_source=Lead.where('created_at >= ?',Time.now.beginning_of_month-6.months)
    six_site_visit_source=Lead.where('site_visited_on >= ?',Time.now.beginning_of_month-6.months)
    six_booking_source=Lead.where(lost_reason_id: nil, status: true).where('booked_on >= ?',Time.now.beginning_of_month-6.months)
    
    @six_site_visited_data=[]
    @six_booked_data=[]

    SourceCategory.where(organisation_id: current_personnel.organisation_id).each do |source|

      if six_leads_source.where(source_category_id: source.id)==[] && six_site_visit_source.where(source_category_id: source.id)==[]  
      else
      site_visit_hash={}
      site_visit_hash[:name]=source.description
        if six_leads_source.where(source_category_id: source.id)==[]
        site_visit_hash[:y]=0
        else
        site_visit_hash[:y]=six_leads_source.where(source_category_id: source.id).count  
        end
        if six_site_visit_source.where(source_category_id: source.id)==[]
        site_visit_hash[:z]=0
        else
        site_visit_hash[:z]=six_site_visit_source.where(source_category_id: source.id).count  
        end
      @six_site_visited_data+=[site_visit_hash]  
      end

      if six_leads_source.where(source_category_id: source.id)==[] && six_booking_source.where(source_category_id: source.id)==[]  
      else
      booked_hash={}
      booked_hash[:name]=source.description
        if six_leads_source.where(source_category_id: source.id)==[]
        booked_hash[:y]=0
        else
        booked_hash[:y]=six_leads_source.where(source_category_id: source.id).count  
        end
        if six_booking_source.where(source_category_id: source.id)==[]
        booked_hash[:z]=0
        else
        booked_hash[:z]=six_booking_source.where(source_category_id: source.id).count  
        end
      @six_booked_data+=[booked_hash]  
      end
    end
    @six_booked_data=@six_booked_data.to_json.html_safe
    @six_site_visited_data=@six_site_visited_data.to_json.html_safe

    end
   # -------------source wise sunburst--------------------#

    if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Team Lead' || current_personnel.status=='Marketing'
   
    source_personnel_data=leads_source.group(:source_category_id, :personnel_id).count
    initial_hash={}
    initial_hash[:id]='0'
    initial_hash[:parent]=''
    initial_hash[:name]=current_personnel.organisation.name
    @source_sunburst=[]
    @source_sunburst+=[initial_hash]
    source_personnel_data.each do |key, value|
      if @source_sunburst.find{|c| c[:id]=='s'+key[0].to_s} == nil
      source_hash={}
      source_hash[:id]='s'+ key[0].to_s
      source_hash[:parent]='0'
      source_hash[:name]=SourceCategory.find(key[0]).description
      @source_sunburst+=[source_hash]
      end
      personnel_hash={}
      personnel_hash[:id]=key[1].to_s
      personnel_hash[:parent]='s'+key[0].to_s
      personnel_hash[:name]=Personnel.find(key[1]).name
      personnel_hash[:value]=value
      @source_sunburst+=[personnel_hash]
    end
    @source_sunburst=@source_sunburst.to_json.html_safe

    initial_hash={}
    initial_hash[:id]='0'
    initial_hash[:parent]=''
    initial_hash[:name]=current_personnel.organisation.name
    @executive_sunburst=[]
    @executive_sunburst+=[initial_hash]
    source_personnel_data.each do |key, value|
      if @executive_sunburst.find{|c| c[:id]=='p'+key[1].to_s} == nil
      personnel_hash={}
      personnel_hash[:id]='p'+ key[1].to_s
      personnel_hash[:parent]='0'
      personnel_hash[:name]=Personnel.find(key[1]).name
      @executive_sunburst+=[personnel_hash]
      end
      source_hash={}
      source_hash[:id]=key[0].to_s
      source_hash[:parent]='p'+key[1].to_s
      source_hash[:name]=SourceCategory.find(key[0]).description
      source_hash[:value]=value
      @executive_sunburst+=[source_hash]
    end
    @executive_sunburst=@executive_sunburst.to_json.html_safe

    
  end

    #-------------------ratio---------------------#
      @this_months_booking=booked_data.last
      if leads_generated_data.last==0
      @this_months_site_visit_ratio='0 %'
      else  
      @this_months_site_visit_ratio=(((site_visited_data.last/leads_generated_data.last.to_f)*100).round(2)).to_s+' %'
      end
      if site_visited_data.last==0
      @this_months_booking_ratio='0 %'
      else
      @this_months_booking_ratio=(((booked_data.last/site_visited_data.last.to_f)*100).round(2)).to_s+' %'
      end
      if (leads_generated_data[2]+leads_generated_data[3]+leads_generated_data[4])==0
      @three_months_site_visit_ratio='0 %'
      else  
      @three_months_site_visit_ratio=((((site_visited_data[2]+site_visited_data[3]+site_visited_data[4])/(leads_generated_data[2]+leads_generated_data[3]+leads_generated_data[4]).to_f)*100).round(2)).to_s+' %'
      end
      if (site_visited_data[2]+site_visited_data[3]+site_visited_data[4])==0
      @three_months_booking_ratio='0 %'
      else
      @three_months_booking_ratio=((((booked_data[2]+booked_data[3]+booked_data[4])/(site_visited_data[2]+site_visited_data[3]+site_visited_data[4]).to_f)*100).round(2)).to_s+' %'
      end    

    if current_personnel.status=='Team Lead'
    total_leads_generated=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: array_of_executives).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", Time.now.year, Time.now.month).count
    total_field_visits=FieldVisit.joins(:follow_up => [:lead]).where(:follow_ups => {personnel_id: array_of_executives}).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", Time.now.year, Time.now.month).count
    elsif current_personnel.status=='Sales Executive'
    total_leads_generated=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: current_personnel.id).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", Time.now.year, Time.now.month).count
    total_field_visits=FieldVisit.joins(:follow_up => [:lead]).where(:follow_ups => {personnel_id: current_personnel.id}).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", Time.now.year, Time.now.month).count
    else
    total_leads_generated=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", Time.now.year, Time.now.month).count
    total_field_visits=FieldVisit.joins(:follow_up => [:lead => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", Time.now.year, Time.now.month).count
    end
    if total_leads_generated==0
    @field_visit_percentage=0
    else  
    @field_visit_percentage=((total_field_visits.to_f/total_leads_generated.to_f)*100).round
    end
  end

  # GET /leads/new
  def new
        
    @lead = Lead.new
    @business_units=selections(BusinessUnit, :name)
    @areas = selections_with_other(Area, :name)
    @cities = selectoptions_with_other(City, :name)
    @states = ['Arunachal Pradesh','Assam','Bihar','Chhattisgarh','Goa','Gujarat','Haryana','Himachal Pradesh','Jharkhand','Karnataka','Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Odisha','Punjab','Rajasthan','Sikkim','Tamil Nadu','Telangana','Tripura','Uttar Pradesh','Uttarakhand','West Bengal']
    # @marketing_instances=selectoptions(MarketingInstance, :description)
    @lost_reasons=selections(LostReason, :description)
    @source_categories=SourceCategory.leaves(current_personnel)   

  end

  # GET /leads/1/edit
  def edit
    @age_brackets = ['Young', 'Middle Age', 'Old Age']
    @areas = selections_with_other(Area, :name)
    @cities = selectoptions_with_other(City, :name)
    @states = ['Arunachal Pradesh','Assam','Bihar','Chhattisgarh','Goa','Gujarat','Haryana','Himachal Pradesh','Jharkhand','Karnataka','Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Odisha','Punjab','Rajasthan','Sikkim','Tamil Nadu','Telangana','Tripura','Uttar Pradesh','Uttarakhand','West Bengal']
    @multiple_children = MultipleChild.where(lead_id: @lead.id)
    @business_units=selections(BusinessUnit, :name)
    @picked_unit=[@lead.business_unit.name, @lead.business_unit_id]
    @personnels=selections(Personnel, :name)
    @marketing_instances=selectoptions(MarketingInstance, :description)
    @source_categories=SourceCategory.leaves(current_personnel)
    @source_categories+=[[@lead.source_category.heirarchy, @lead.source_category_id]]   
    @source_pick=[@lead.source_category.heirarchy, @lead.source_category_id]
    @occupations=selections_with_other(Occupation, :description)
    @designations=selections_with_other(Designation, :description)
    @newspapers=selections_with_other(Newspaper, :description)
    @channels=selections_with_other(Channel, :description)
    @stations=selections_with_other(Station, :description)
    @magazines=selections_with_other(Magazine, :description)
    @communities=selections_with_other(Community, :description)
    @nationalities=selections_with_other(Nationality, :description)
    @preferred_locations=selections_with_other(PreferredLocation, :description)
    @other_projects=selectoptions(OtherProject, :name)
    @preferred_location_tags=PreferredLocationTag.where(lead_id: @lead.id)
    @preferred_location_selected_ids=[]
    @other_project_selected_ids=[]
    @genders=['Male', 'Female', 'Other']
    @how_soon=['Please Select','Immediately','Within 3 months','Within 6 months','Not decided']
    if @preferred_location_tags == nil || @preferred_location_tags == ''
      @preferred_location_selected_ids=[]
    else
      @preferred_location_tags.each do |preferred_location_tag|
        @preferred_location_selected_ids+=[preferred_location_tag.preferred_location_id] 
      end
    end
    @other_project_tags=OtherProjectTag.where(lead_id: @lead.id)
    if @other_project_tags == nil || @other_project_tags == ''
      @other_project_selected_ids=[]
    else
      @other_project_tags.each do |other_project_tag|
        @other_project_selected_ids+=[other_project_tag.other_project_id] 
      end
    end
    position_1 = @lead.name[0..5].index(" ")
    if position_1 == nil
      @actual_name = @lead.name
    else
      small_name = @lead.name[0..position_1-1]
      if small_name == 'Mr.' || small_name == 'Mrs.' || small_name == 'Dr.' || small_name ==  'Ms.'
        @title = @lead.name[0..position_1-1]
        @actual_name = @lead.name[position_1+1..@lead.name.length]
      else
        @title = ""
        @actual_name = @lead.name
      end
    end
  end

  # POST /leads
  # POST /leads.json
  def create
    if params[:lead][:mobile].length >= 10
      if Lead.where('mobile = ? AND business_unit_id = ? AND (status= ? OR status is ?)', params[:lead][:mobile], params[:lead][:business_unit_id].to_i, false, nil)==[] || params[:lead][:mobile]==''
        if params[:area_other] == nil
        else
          area = Area.new
          area.name = params[:area_other]
          area.organisation_id = current_personnel.organisation_id
          area.save
        end
        if params[:city_other] == nil
        else
          city = City.new
          city.name = params[:city_other]
          city.save
        end
        @lead = Lead.new(lead_params)
        @lead.personnel_id=current_personnel.id
        @lead.flat_type=params[:flat_type]
        @lead.anticipation=params[:anticipation]
        respond_to do |format|
          if @lead.save
            format.html { flash[:success] = 'Lead was successfully created.'
                          redirect_to :back }
            format.json { render action: 'show', status: :created, location: @lead }
          else
            format.html { render action: 'new' }
            format.json { render json: @lead.errors, status: :unprocessable_entity }
          end
        end
        @lead.update(name: params[:lead_name_title].to_s+' '+@lead.name.to_s)
        if params[:area_other] == nil
        else
          @lead.update(area_id: area.id)
        end
        if params[:city_other] == nil
        else
          @lead.update(city_id: city.id)
        end
        @followup=FollowUp.new
        @followup.lead_id=@lead.id
        @followup.personnel_id=current_personnel.id
        @followup.communication_time=params[:leading][:flexible_date]
        @followup.follow_up_time=params[:leading][:followup_date]
        followup_hours=params[:leading]['followup_time(4i)'].to_i*60*60
        followup_minutes=params[:leading]['followup_time(5i)'].to_i*60
        @followup.follow_up_time=@followup.follow_up_time+followup_hours+followup_minutes
        @followup.remarks=params[:remarks]
        if params[:leading][:status]=='0'
          if @lead.status==false
          else
            @lead.update(osv: nil)
            @followup.osv=nil 
          end
        elsif params[:leading][:status]=='1'
          @followup.osv=true
          @lead.update(osv: true, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
        elsif params[:leading][:status]=='2'
          @lead.update(qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date], site_visited_on: params[:leading][:flexible_date]) 
          @followup.status=false
          @lead.update(status: false)
        elsif params[:leading][:status]=='3'
          @followup.osv=false
          @lead.update(osv: false)
        elsif params[:leading][:status]=='5' 
          @followup.status=true
          @lead.update(status: true, osv: nil)
          @lead.update(booked_on: params[:leading][:flexible_date])
          @lead.update(lost_reason_id: params[:leading][:lost_reason])
        elsif params[:leading][:status]=='4' 
          @followup.status=true
          @lead.update(status: true, osv: nil)
          @lead.update(booked_on: params[:leading][:flexible_date])
        elsif params[:leading][:status]=='9' 
          @followup.status=false
          @followup.osv=true
          @lead.update(status: false, osv: true, qualified_on: params[:leading][:flexible_date])
        elsif params[:leading][:status]=='10' 
          @followup.status=false
          @followup.osv=true
          if @lead.qualified_on == nil
            @lead.update(status: false, osv: true, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
          else
            @lead.update(status: false, osv: true, interested_in_site_visit_on: params[:leading][:flexible_date])
          end
        end
        @lead.update(escalated: nil)
        @followup.first=true
        @followup.last=true
        @followup.save
      else
        respond_to do |format|
          format.html { 
              flash[:danger] = 'Lead cannot be created, mobile no. present in the same project'
              redirect_to :back }
        end
      end
    else
      flash[:danger] = 'Lead is not created, Please enter 10 digit mobile number.'
      redirect_to :back
    end
  end

  # PATCH/PUT /leads/1
  # PATCH/PUT /leads/1.json
  def update
    @lead.update(flat_type: params[:flat_type])  
    if params[:area_other] == nil
    else
      area = Area.new
      area.name = params[:area_other]
      area.organisation_id = current_personnel.organisation_id
      area.save
    end
    if params[:work_area_other] == nil
    else
      area = Area.new
      area.name = params[:work_area_other]
      area.organisation_id = current_personnel.organisation_id
      area.save
    end
    if params[:city_other] == nil
    else
      city = City.new
      city.name = params[:city_other]
      city.save
    end

    respond_to do |format|
      if @lead.update(lead_params)
        if params[:lead][:how_soon] == 'Please Select'
          @lead.update(how_soon: nil)
        end
        if PreferredLocationTag.where(lead_id: @lead.id) == []
        else
          PreferredLocationTag.where(lead_id: @lead.id).each do |old_preferred_location_tag|
            old_preferred_location_tag.destroy
          end
        end
        if OtherProjectTag.where(lead_id: @lead.id) == []
        else
          OtherProjectTag.where(lead_id: @lead.id).each do |old_other_project_tag|
            old_other_project_tag.destroy
          end    
        end
        if params[:area_other] == nil
        else
          area_id = Area.find_by_name(params[:area_other]).id
          @lead.update(area_id: area_id)
        end
        if params[:work_area_other] == nil
        else
          work_area_id = Area.find_by_name(params[:work_area_other]).id
          @lead.update(work_area_id: work_area_id)
        end
        if params[:city_other] == nil
        else
          @lead.update(city_id: city.id)
        end
        if @lead.name[0..5].include?("Mr.") || @lead.name[0..5].include?("Mrs.") || @lead.name[0..5].include?("Dr.") || @lead.name[0..5].include?("Ms.")
        else
          @lead.update(name: params[:lead_title].to_s+' '+@lead.name)
        end
        
        if params[:children_name] == [""]
        else
          if MultipleChild.where(lead_id: @lead.id) == []
            params[:children_name].each_with_index do |child_name, index|
              multiple_children = MultipleChild.new
              multiple_children.name = child_name
              multiple_children.dob = params[:children_dob][index]
              multiple_children.lead_id = @lead.id
              multiple_children.save
            end
          else
            multiple_children = MultipleChild.where(lead_id: @lead.id)
            multiple_children.destroy_all

            params[:children_name].each_with_index do |child_name, index|
              multiple_children = MultipleChild.new
              multiple_children.name = child_name
              multiple_children.dob = params[:children_dob][index]
              multiple_children.lead_id = @lead.id
              multiple_children.save
            end
          end
        end
        params[:preferred_location][:preferred_location_id].each do |preferred_location_id|
          if preferred_location_id == ""
          else
            preferred_location_tag=PreferredLocationTag.new
            preferred_location_tag.preferred_location_id = preferred_location_id
            preferred_location_tag.lead_id = @lead.id
            preferred_location_tag.save
          end
        end
      
        params[:other_project][:other_project_id].each do |other_project_id|
          if other_project_id == ""
          else
            other_project_tag=OtherProjectTag.new
            other_project_tag.other_project_id = other_project_id
            other_project_tag.lead_id = @lead.id
            other_project_tag.save
          end
        end
        if params[:occupation] == nil
        else
          if Occupation.find_by_description(params[:occupation][:other]) == nil
            occupation = Occupation.new
            occupation.description = params[:occupation][:other]
            occupation.organisation_id = current_personnel.organisation_id
            occupation.save

            @lead.update(occupation_id: occupation.id)
          end
        end
        if params[:designation] == nil
        else
          if Designation.find_by_description(params[:designation][:other]) == nil
            designation = Designation.new
            designation.description = params[:designation][:other]
            designation.organisation_id = current_personnel.organisation_id
            designation.save

            @lead.update(designation_id: designation.id)
          end
        end
        if params[:newspaper] == nil
        else
          if Newspaper.find_by_description(params[:newspaper][:other]) == nil
            newspaper = Newspaper.new
            newspaper.description = params[:newspaper][:other]
            newspaper.organisation_id = current_personnel.organisation_id
            newspaper.save

            @lead.update(newspaper_id: newspaper.id)
          end
        end
        if params[:channel] == nil
        else
          if Channel.find_by_description(params[:channel][:other]) == nil
            channel = Channel.new
            channel.description = params[:channel][:other]
            channel.organisation_id = current_personnel.organisation_id
            channel.save

            @lead.update(channel_id: channel.id)
          end
        end
        if params[:station] == nil
        else
          if Station.find_by_description(params[:station][:other]) == nil
            station = Station.new
            station.description = params[:station][:other]
            station.organisation_id = current_personnel.organisation_id
            station.save

            @lead.update(station_id: station.id)
          end
        end
        if params[:magazine] == nil
        else
          if Magazine.find_by_description(params[:magazine][:other]) == nil
            magazine = Magazine.new
            magazine.description = params[:magazine][:other]
            magazine.organisation_id = current_personnel.organisation_id
            magazine.save

            @lead.update(magazine_id: magazine.id)
          end
        end
        if params[:community] == nil
        else
          if Community.find_by_description(params[:community][:other]) == nil
            community = Community.new
            community.description = params[:community][:other]
            community.organisation_id = current_personnel.organisation_id
            community.save

            @lead.update(community_id: community.id)
          end
        end
        if params[:nationality] == nil
        else
          if Nationality.find_by_description(params[:nationality][:other]) == nil
            nationality = Nationality.new
            nationality.description = params[:nationality][:other]
            nationality.organisation_id = current_personnel.organisation_id
            nationality.save

            @lead.update(nationality_id: nationality.id)
          end
        end

        format.html { redirect_to :back, notice: 'Lead was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    @lead.destroy
    respond_to do |format|
      format.html { redirect_to leads_url }
      format.json { head :no_content }
    end
  end

  def populate_area_other
    @area_type=params[:type]
    if @area_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_area_other"}
      end
    end
  end

  def populate_work_area_other
    @area_type=params[:type]
    if @area_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_work_area_other"}
      end
    end
  end

  def populate_city_other
    @city_type=params[:type]
    if @city_type == "Others"
      respond_to do |format|
          format.js { render :action => "populate_city_other"}
      end
    end
  end

  def populate_occupation_other
    @occupation_type=params[:type]
    p @occupation_type
    p "============================="
    if @occupation_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_occupation_other"}
      end
    end
  end

  def populate_designation_other
    @designation_type=params[:type]
    p @designation_type
    p "============================="
    if @designation_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_designation_other"}
      end
    end
  end

  def populate_newspaper_other
    @newspaper_type=params[:type]
    if @newspaper_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_newspaper_other"}
      end
    end
  end

  def populate_channel_other
    @channel_type=params[:type]
    if @channel_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_channel_other"}
      end
    end
  end

  def populate_station_other
    @station_type=params[:type]
    if @station_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_station_other"}
      end
    end
  end

  def populate_magazine_other
    @magazine_type=params[:type]
    if @magazine_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_magazine_other"}
      end
    end
  end

  def populate_community_other
    @community_type=params[:type]
    if @community_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_community_other"}
      end
    end
  end

  def populate_nationality_other
    @nationality_type=params[:type]
    if @nationality_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_nationality_other"}
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lead
      @lead = Lead.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lead_params
      params.require(:lead).permit(:business_unit_id, :personnel_id, :budget_from, :budget_to, :status, :personnel_remarks, :name, :email, :lost_reason_id, :address, :occupation_id, :requirement, :area, :mobile, :marketing_instance_id, :source_category_id, :customer_remarks, :newspaper_id, :channel_id, :station_id, :magazine_id, :community_id, :nationality_id, :pan, :dob, :company, :designation, :first_applicant, :second_applicant, :generated_on, :other_number, :occupation_id, :newspaper_id, :channel_id, :station_id, :magazine_id, :community_id, :nationality_id, :doa, :investment, :work_address, :child_school, :current_address, :gender, :pincode, :designation_id, :how_soon, :area_id, :city_id, :state, :dob_of_spouse, :work_area_id, :age_bracket, :race, :why_this_project)
    end
end
