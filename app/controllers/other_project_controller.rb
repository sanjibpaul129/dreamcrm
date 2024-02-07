class OtherProjectController < ApplicationController
	
	def other_project_index
		@other_projects=OtherProject.where(organisation_id: current_personnel.organisation_id)
	end

	def other_project_new
		@other_project=OtherProject.new
		@other_project_action='other_project_create'
	end

	def other_project_create
	    @other_project=OtherProject.new(other_project_params)  
	    @other_project.organisation_id = current_personnel.organisation_id
	    @other_project.save
	    
	    flash[:success]='Other Project Generated successfully.'
	    redirect_to other_project_other_project_index_url    
	end

	def other_project_edit
		@other_project=OtherProject.find(params[:format])
    	@other_project_action='other_project_update'
	end

	def other_project_update
		@other_project= OtherProject.find(params[:other_project_id])
		@other_project.update(organisation_id: current_personnel.organisation_id)
  		@other_project.update(other_project_params)
    	
    	flash[:success]='Other Project Updated successfully.'
	    redirect_to other_project_other_project_index_url    
	end

	def other_project_destroy
		@other_project=OtherProject.find(params[:format])
	  	@other_project.destroy

	    flash[:success]='Other Project destroyed successfully.'
	  	redirect_to other_project_other_project_index_url
	end

	# ----------------------------------------------------------------------------------------------------------------------

  private
    
    def other_project_params
    	params.require(:other_project).permit(:name)
    end


end
