class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
   helper_method :current_personnel
   protect_from_forgery with: :exception
   

private

def current_personnel
  @current_personnel ||= Personnel.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]
end


  
def convert_interval_to_hours(datetime)
 hours=0 
 if datetime.index('year')!=nil
 hours+=(datetime.at(0..(datetime.index('year')-1)).to_i*360*24) 
 end

 if datetime.index('mon')!=nil
  if hours==0
  hours+=(datetime.at(0..(datetime.index('mon')-1)).to_i*30*24)
  else 
  hours+=(datetime.at((datetime.index('mon')-3)..(datetime.index('mon')-1)).to_i*30*24) 
  end
 end

 if datetime.index('day')!=nil
  if hours==0
  hours+=(datetime.at(0..(datetime.index('day')-1)).to_i*24)
  else
   hours+=(datetime.at((datetime.index('day')-3)..(datetime.index('day')-1)).to_i*24) 
  end
 end

 hours+=(datetime.at((datetime.index(':')-2)..(datetime.index(':')-1)).to_i) 

 return hours

end

 def selectoptions(table, field)
 	
  @tables=[]
  @tableshash=table.all
  @tableshash.each do |pluck|
  @tables=@tables+[[pluck.send(field), pluck.id]]
  @tables=@tables.sort
 end
  return @tables
 end

  def selections(table, field)
  
  @tables=[]
  @tableshash=table.where(organisation_id: current_personnel.organisation_id)
  @tableshash.each do |pluck|
  @tables=@tables+[[pluck.send(field), pluck.id]]
  @tables=@tables.sort
 end
  return @tables
 end

 def selections_with_all(table, field)
  
  table_name = table.to_s
  if table_name == "BusinessUnit"
    @tables=[[' All Project', -1]]
  elsif table_name == "Personnel"
    @tables=[[' All Executives', -1]]
  elsif table_name == "Flat"
    @tables=[[' All flat', -1]]
  elsif table_name == "LostReason"
    @tables=[[' All Lost Reasons', -1]]
  elsif table_name == "SourceCategory"
    @tables=[[' All Categories', -1]]
  else
    @tables=[[' All', -1]]
  end
    @tableshash=table.where(organisation_id: current_personnel.organisation_id)
    @tableshash.each do |pluck|
    @tables=@tables+[[pluck.send(field), pluck.id]]
    @tables=@tables.sort
    end
  return @tables
 end

 def selections_with_other(table, field)
    
  @tables=[[' Others', -1]]
  @tableshash=table.where(organisation_id: current_personnel.organisation_id)
  @tableshash.each do |pluck|
    @tables=@tables+[[pluck.send(field), pluck.id]]
    @tables=@tables.sort
  end
  return @tables
 end

 def selectoptions_with_other(table, field)
  @tables=[['Others', -1]]
  @tableshash=table.all
  @tableshash.each do |pluck|
  @tables=@tables+[[pluck.send(field), pluck.id]]
  @tables=@tables.sort
 end
  return @tables
 end



 def selections_with_all_active(table, field)
  table_name = table.to_s
  if table_name == "BusinessUnit"
    @tables=[[' All Project', -1]]
  elsif table_name == "Personnel"
    @tables=[[' All Executives', -1]]
  elsif table_name == "Flat"
    @tables=[[' All flat', -1]]
  elsif table_name == "LostReason"
    @tables=[[' All Lost Leads', -1]]
  elsif table_name == "SourceCategory"
    @tables=[[' All Categories', -1]]
  else
    @tables=[[' All', -1]]
  end
    @tableshash=table.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ?', nil, 2)
    @tableshash.each do |pluck|
    @tables=@tables+[[pluck.send(field), pluck.id]]
    @tables=@tables.sort
    end
  return @tables
 end

 def business_unit_selections(table, field)
  
  @tables=[]
  @tableshash=table.where(business_unit_id: current_personnel.warehouse_id)
  @tableshash.each do |pluck|
  @tables=@tables+[[pluck.send(field), pluck.id]]
  @tables=@tables.sort
 end
  return @tables
 end

 def company_business_unit_selections(table, field)
  
  @tables=[]
  @wares=BusinessUnit.where(company_id: current_personnel.company_id)
  @wares.each do |warehouse|
  @tables=@tables+[[warehouse.description, warehouse.id]]
  end
 @tables=@tables.sort
  return @tables
 end

def company_selections(table, field)
  
  @tables=[]
  @warehouses=BusinessUnit.where(company_id: current_personnel.company_id)
  @warehouses.each do |warehouse|
  @tableshash=table.where(business_unit_id: warehouse.id)
  @tableshash.each do |pluck|
  @tables=@tables+[[pluck.send(field), pluck.id]]
  end
 end
 @tables=@tables.sort
  return @tables
 end

def only_business_unit_selections(table, field)
  
  @tables=[]
  @tableshash=table.where(id: current_personnel.business_unit_id)
  @tableshash.each do |pluck|
  @tables=@tables+[[pluck.send(field), pluck.id]]
  @tables=@tables.sort
 end
  return @tables
 end

 def source_category_concatenate(description, predecessor)

  pre=-1
         leaf_source=(" . "+description)
         @source=SourceCategory.find(predecessor)
         until  pre==0 do
           leaf_source=" . " + @source.description+leaf_source 
           if pre!=nil
             @source=SourceCategory.find_by_id(@source.predecessor)
             if@source==nil
               pre=0
             else
               pre=@source.predecessor
             end
           else
             pre=0
           end
         end
         leaf_source[0]=""
         leaf_source[0]=""
         leaf_source[0]=""

 return leaf_source
 
 end

 

end
