class PersonnelsController < ApplicationController
  before_action :set_personnel, only: [:show, :edit, :update, :destroy]

  # GET /personnels
  # GET /personnels.json
  def index
    @projects = selections_with_all(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @project = -1
      if current_personnel.email == "ayushruia1@gmail.com"
        @personnels = Personnel.all
      elsif current_personnel.status=='Admin' || current_personnel.status=='Back Office'
        @personnels = Personnel.where(organisation_id: current_personnel.organisation_id).where.not(access_right: -1)
        @personnels+= Personnel.where(organisation_id: current_personnel.organisation_id, access_right: nil)    
      end
    else
      @project = params[:business_unit_id]
      @personnels = Personnel.where(business_unit_id: @project.to_i).where.not(access_right: -1)
      @personnels +=  Personnel.where(business_unit_id: @project.to_i, access_right: nil)
    end
    # if current_personnel.email == 'ayushruia1@gmail.com'
    #   @personnels = Personnel.all
    # elsif current_personnel.status=='Admin' || current_personnel.status=='Back Office'
    #   @personnels = Personnel.where(organisation_id: current_personnel.organisation_id).where.not(access_right: -1)
    #   @personnels+= Personnel.where(organisation_id: current_personnel.organisation_id, access_right: nil)
    # end  
  end

  # GET /personnels/1
  # GET /personnels/1.json
  def show
  end

  # GET /personnels/new
  def new
    @personnel = Personnel.new
    @organisations=selectoptions(Organisation, :name)
    @business_units=selectoptions(BusinessUnit, :name)
    @roles=[['Admin', 0],['Team Lead', 1],['Marketing', 3],['Sales Executive', nil],['Back Office', 2]]
  end

  # GET /personnels/1/edit
  def edit
    @business_units=selections(BusinessUnit, :name)
    @personnels = []
    if current_personnel.email == "ayush@thejaingroup.com"
      ((Personnel.where(organisation_id: 1, access_right: nil))+(Personnel.where(organisation_id: 1, access_right: 2))).each do |personnel|
        @personnels += [[personnel.name, personnel.id]]
      end
    else
      Personnel.where(business_unit_id: current_personnel.business_unit_id, access_right: nil).each do |personnel|
        @personnels += [[personnel.name, personnel.id]]
      end
    end
    @predecessors=[]
    Personnel.where(organisation_id: current_personnel.organisation_id, access_right: 1).each do |team_lead|
      @predecessors+=[[team_lead.name, team_lead.id]]
    end
    @predecessors+=[['no team lead', nil]]
  end

  def request_for_demo
    UserMailer.api_testing(params).deliver
    redirect_to :back
  end

  # POST /personnels
  # POST /personnels.json
  def create
    @personnel = Personnel.new(personnel_params)

    respond_to do |format|
      if @personnel.save
        format.html { redirect_to log_in_url, :notice => "Signed up!" }
        format.json { render action: 'show', status: :created, location: @personnel }
      else
        format.html { render action: 'new' }
        format.json { render json: @personnel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personnels/1
  # PATCH/PUT /personnels/1.json
  def update
    @personnel.update(business_unit_id: params[:personnel][:business_unit_id])
    @personnel.update(predecessor: params[:personnel][:predecessor])
    if params[:personnel][:absent]==nil
      @personnel.update(absent: nil)  
    else
      all_back_office_executives = Personnel.where(business_unit_id: @personnel.business_unit_id, access_right: 2).where.not(id: @personnel.id)
      anyone_else_present = false
      all_back_office_executives.each do |personnel|
        if personnel.absent == false || personnel.absent == nil
          anyone_else_present=true
        end
      end
      all_site_executives = Personnel.where(business_unit_id: @personnel.business_unit_id, access_right: nil).where.not(id: @personnel.id)
      all_site_executives.each do |personnel|
        if personnel.absent == false || personnel.absent == nil
          anyone_else_present=true
        end
      end

      if anyone_else_present == true
        @personnel.update(absent: true)
      else
        flash[:danger] = 'Atleast one telecaller should be available to take fresh lead.'
      end
    end
    if params[:personnel][:access_right]==nil || params[:personnel][:access_right]==false
      if @personnel.access_right==-1
      @personnel.update(access_right: nil)
      end
    else
    @personnel.update(access_right: -1)
    end
    if params[:personnel][:expanded] == "true"
      @personnel.update(expanded: true)
    else
      @personnel.update(expanded: nil)
    end
    @personnel.update(allocation_weight: params[:personnel][:allocation_weight])  
    @personnel.update(mapped: params[:personnel][:mapped], mapped_two: params[:personnel][:mapped_two], mapped_three: params[:personnel][:mapped_three])
    redirect_to :back
  end

  # DELETE /personnels/1
  # DELETE /personnels/1.json
  def destroy
    @personnel.destroy
    respond_to do |format|
      format.html { redirect_to personnels_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personnel
      @personnel = Personnel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def personnel_params
      params.require(:personnel).permit(:business_unit_id, :escalation_level, :organisation_id,:email, :name, :passwordhash, :passwordsalt, :auth_token, :password_reset_token, :password_reset_sent_at, :mobile, :password_confirmation, :password, :access_right, :expanded)
    end
end
