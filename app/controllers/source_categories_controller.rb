class SourceCategoriesController < ApplicationController
  before_action :set_source_category, only: [:show, :edit, :update, :destroy]

  # GET /source_categories
  # GET /source_categories.json
  def index
    @source_categories = SourceCategory.where(predecessor: nil, organisation_id: current_personnel.organisation_id).where('inactive is ? or inactive = ?', nil, false)
  end

  # GET /source_categories/1
  # GET /source_categories/1.json
  def show
  end

  # GET /source_categories/new
  def new
    
      @header='Source New'
          if params[:source_category_id] != nil
      @source_category_id=params[:source_category_id]
      @source_category_description=(SourceCategory.find(@source_category_id)).description
    else
      @source_category_id=nil
      @source_category_description="No Predecessor"
      
    end

    
    @source_category = SourceCategory.new
  end

  # GET /source_categories/1/edit
  def edit
    if params[:source_category_id] != nil
      @source_category_id=params[:source_category_id]
      @source_category_description=(SourceCategory.find(@source_category_id)).description
    else
      @source_category_id=nil
      @source_category_description="No Predecessor"
    end
  end

  def drilldown
    @header='Source'
    if params.select{|key, value| value == ">>" }=={}
      redirect_to url_for(:controller => :source_categories, :action => :new, source_category_id: params[:source_category_id] )
    else
      @chosen=params.select{|key, value| value == ">>" }.keys[0]
      @source_categories = SourceCategory.where(predecessor: @chosen).where('inactive is ? or inactive = ?', nil, false)
      @leafgroup=SourceCategory.find(@chosen).heirarchy
    end
  end


  # POST /source_categories
  # POST /source_categories.json
  def create

    if params[:source_category][:description].include? "."
      redirect_to :back, notice: 'Description cannot contain <.>'
    else
      @source_category = SourceCategory.new(source_category_params)
      @source_category.update(organisation_id: current_personnel.organisation_id)

      if @source_category.predecessor!=nil
      @source_category.update(heirarchy: source_category_concatenate(@source_category.description, @source_category.predecessor.to_i))
      else
      @source_category.update(heirarchy: @source_category.description)
      end      

    respond_to do |format|
      if @source_category.save
        format.html { redirect_to :back, notice: 'Source was successfully created.' }
        format.json { render action: 'show', status: :created, location: @source_category }
      else
        format.html { render action: 'new' }
        format.json { render json: @source_category.errors, status: :unprocessable_entity }
      end
    end
  end
  end


  # PATCH/PUT /source_categories/1
  # PATCH/PUT /source_categories/1.json
  def update
    if params[:source_category][:description].include? "."
      redirect_to :back, notice: 'Description cannot contain <.>'
      else
        respond_to do |format|
          if @source_category.update(source_category_params)
            
            if params[:source_category][:inactive]=="false"
              if @source_category.predecessor==nil
              @source_category.update(inactive: false)
              else  
                if SourceCategory.find(@source_category.predecessor).inactive==true
                @notice="Parent is inactive, source cannot be marked active" 
                else
                @source_category.update(inactive: false)
                end
              end
            else
              if @source_category.all_successors_inactive==true
                @source_category.update(inactive: true)
              else
                @notice="All successors should be inactive"
              end
            end 
            if @source_category.predecessor!=nil
              @source_category.update(heirarchy: source_category_concatenate(@source_category.description, @source_category.predecessor.to_i))
            else
              @source_category.update(heirarchy: @source_category.description)
            end
          format.html { redirect_to source_categories_url, notice: 'Source was successfully updated.' }
          format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @source_category.errors, status: :unprocessable_entity }
      end
    end
  end
  puts @notice
  end

  # DELETE /source_categories/1
  # DELETE /source_categories/1.json
  def destroy
    if Lead.where(source_category_id: @source_category.id)==[] && SourceCategory.where(predecessor: @source_category.id)==[] 
    @source_category.destroy
    end
    respond_to do |format|
      format.html { redirect_to source_categories_url }
      format.json { head :no_content }
    end
  end

  def source_tag_with_facebook_index
    @facebook_ads=FacebookAd.all
  end

  def source_tag_with_facebook_new
    @facebook_ad=FacebookAd.new
    
    @business_units=selections(BusinessUnit, :name)
    
    facebook_sources=SourceCategory.where('heirarchy like ? AND organisation_id=?',"%FACEBOOK%", current_personnel.organisation_id)
    @all_leaf_nodes=[]
    facebook_sources.each do |facebook_source|
      if SourceCategory.find_by_predecessor(facebook_source.id)==nil && FacebookAd.find_by_source_category_id(facebook_source.id)==nil
        @all_leaf_nodes+=[[facebook_source.heirarchy,facebook_source.id]]
      end
    end
    
    @facebook_ad_action='source_tag_with_facebook_create'
  end

  def source_tag_with_facebook_create
    facebook_ad=FacebookAd.new(facebook_ad_params)
    facebook_ad.save

    flash[:success]='Source Tagging with facebook done successfully.'
    redirect_to source_categories_source_tag_with_facebook_index_url
  end

  def source_tag_with_facebook_edit
    @facebook_ad=FacebookAd.find(params[:format])
    @business_units=selections(BusinessUnit, :name)
    facebook_sources=SourceCategory.where('heirarchy like ? AND organisation_id=?',"%FACEBOOK%", current_personnel.organisation_id)
    @all_leaf_nodes=[[FacebookAd.find(@facebook_ad).source_category.heirarchy, FacebookAd.find(@facebook_ad).source_category_id]]
    facebook_sources.each do |facebook_source|
      if SourceCategory.find_by_predecessor(facebook_source.id)==nil && FacebookAd.find_by_source_category_id(facebook_source.id)==nil
        @all_leaf_nodes+=[[facebook_source.heirarchy,facebook_source.id]]
      end
    end
    @facebook_ad_action='source_tag_with_facebook_update'
  end

  def source_tag_with_facebook_update
    @facebook_ad=FacebookAd.find(params[:facebook_ad_id])
    @facebook_ad.update(facebook_ad_params)

    flash[:success]='Source Tagging with facebook updated successfully.'
    redirect_to source_categories_source_tag_with_facebook_index_url
  end

  def source_tag_with_facebook_destroy
    @facebook_ad=FacebookAd.find(params[:format])
    @facebook_ad.destroy

    flash[:success]='Source Tagging with facebook deleted successfully.'
    redirect_to source_categories_source_tag_with_facebook_index_url
  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source_category
      @source_category = SourceCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_category_params
      params.require(:source_category).permit(:description, :organisation_id, :predecessor)
    end

    def facebook_ad_params
      params.require(:facebook_ad).permit(:campaign_id, :adset_id, :ad_id, :form_id, :business_unit_id, :source_category_id)
    end
end
