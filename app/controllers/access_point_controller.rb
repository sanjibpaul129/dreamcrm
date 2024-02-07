class AccessPointController < ApplicationController
	def access_point_index
		@menues = AccessPoint.all.pluck(:menu).uniq
		@submenues = AccessPoint.all.pluck(:submenu).uniq
		if params[:menu] == nil
			@access_points=AccessPoint.all
		else
			@menu = params[:menu]
			@submenu = params[:submenu]
			@access_points = AccessPoint.where(menu: @menu, submenu: @submenu)
		end
	end

	def access_point_new
    	@access_point = AccessPoint.new
    	@menues=['Setup' , 'Transaction', 'Report']
    	@submenues=['Presales' , 'Postsales' , 'Customer Profile' , 'Maintenance' ,'Marketing' , 'Others', 'Electrical' , 'Demand','Admin', "Brokers"]
    	@access_point_action = 'access_point_create'
  	end

  	def access_point_create
		access_point = AccessPoint.new(access_point_params)
		access_point.save

		redirect_to access_point_access_point_index_url
   
  	end
   	def access_point_edit
   		@access_point=AccessPoint.find(params[:format])
   		@menues=['Setup' , 'Transaction', 'Report']
    	@submenues=['Presales' , 'Postsales' , 'Customer Profile' , 'Maintenance' ,'Marketing' , 'Others', 'Electrical' , 'Demand','Admin']
  		@access_point_action='access_point_update'

   	end

  	def access_point_update
  		@access_point=AccessPoint.find(params[:access_point_id])
    	@access_point.update(access_point_params)

    	redirect_to access_point_access_point_index_url
  	end

  	def access_point_destroy
  		@access_point=AccessPoint.find(params[:format])
    	@access_point.destroy

     	redirect_to access_point_access_point_index_url
  	end

  	def access_point_submit
	  if params[:commit]=='view details'
	  	redirect_to controller: 'access_point', action: 'access_point_with_personnel', params: request.request_parameters 
	  elsif params[:commit]=='Tag Personnel'
	  	redirect_to controller: 'access_point', action: 'personnel_tagging_with_access_point', params: request.request_parameters
	  end
	end

  	def access_point_with_personnel
  		@personnels=selections(Personnel, :name)
  		@setup_access_points=AccessPoint.where(menu: 'Setup')
  		@transaction_access_points=AccessPoint.where(menu: 'Transaction')
  		@report_access_points=AccessPoint.where(menu: 'Report')
  		@selected_personnel_id = 0
  		if params[:personnel_id] == nil
  		else
  			@selected_personnel_id = params[:personnel_id]
  		end

  	end
  	def personnel_tagging_with_access_point
  		if params[:all_access_points] == ""
	  		if params[:setup_access_point_ids]==[]
	  		else
	  			if params[:setup_access_point_ids] != nil
			  		params[:setup_access_point_ids].each do|access_point_id|
			  			access_point_personnel = AccessPointPersonnel.new
			  			access_point_personnel.access_point_id=access_point_id.to_i
			  			access_point_personnel.personnel_id=params[:personnel_id].to_i
			  			access_point_personnel.save
			  		end
			  	end
		  	end
		  	if params[:transaction_access_point_ids]==[]
	  		else
	  			if params[:transaction_access_point_ids] != nil
		  			params[:transaction_access_point_ids].each do|access_point_id|
			  			access_point_personnel = AccessPointPersonnel.new
			  			access_point_personnel.access_point_id=access_point_id.to_i
			  			access_point_personnel.personnel_id=params[:personnel_id].to_i
			  			access_point_personnel.save
			  		end
			  	end
	  		end
	  		if params[:report_access_point_ids]==[]
	  		else
	  			if params[:report_access_point_ids] != nil
		  			params[:report_access_point_ids].each do|access_point_id|
			  			access_point_personnel = AccessPointPersonnel.new
			  			access_point_personnel.access_point_id=access_point_id.to_i
			  			access_point_personnel.personnel_id=params[:personnel_id].to_i
			  			access_point_personnel.save
			  		end
			  	end
	  		end
	  	else
	  		all_access_points = params[:all_access_points]
	  		selected_personnel_id = params[:selected_personnel_id]
	  		all_access_points = all_access_points.split
	  		all_access_points.each do |access_point_id|
	  			access_point_personnels=AccessPointPersonnel.where(access_point_id: access_point_id.to_i, personnel_id: selected_personnel_id.to_i)
	  			access_point_personnels.destroy_all
	  		end
	  		if params[:setup_access_point_ids]==[]
	  		else
	  			if params[:setup_access_point_ids] != nil
			  		params[:setup_access_point_ids].each do|access_point_id|
			  			access_point_personnel = AccessPointPersonnel.new
			  			access_point_personnel.access_point_id=access_point_id.to_i
			  			access_point_personnel.personnel_id=params[:personnel_id].to_i
			  			access_point_personnel.save
			  		end
			  	end
		  	end
		  	if params[:transaction_access_point_ids]==[]
	  		else
	  			if params[:transaction_access_point_ids] != nil
		  			params[:transaction_access_point_ids].each do|access_point_id|
			  			access_point_personnel = AccessPointPersonnel.new
			  			access_point_personnel.access_point_id=access_point_id.to_i
			  			access_point_personnel.personnel_id=params[:personnel_id].to_i
			  			access_point_personnel.save
			  		end
			  	end
	  		end
	  		if params[:report_access_point_ids]==[]
	  		else
	  			if params[:report_access_point_ids] != nil
		  			params[:report_access_point_ids].each do|access_point_id|
			  			access_point_personnel = AccessPointPersonnel.new
			  			access_point_personnel.access_point_id=access_point_id.to_i
			  			access_point_personnel.personnel_id=params[:personnel_id].to_i
			  			access_point_personnel.save
			  		end
			  	end
	  		end
	  	end

  		redirect_to access_point_access_point_with_personnel_url
  	end

  	private

    	def access_point_params
      		params.require(:access_point).permit(:action , :controller , :menu , :submenu , :order , :name , :method)
    	end

end
