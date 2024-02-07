class SourceCategory < ApplicationRecord
has_many :leads
has_many :expenditures
belongs_to :organisation

  def broker_contact_tagged
    tagging_count = 0
    tagged_data = BrokerSourceCategoryTag.where(source_category_id: self.id)
    if tagged_data == []
      tagging_count = 0
    else
      tagging_count = tagged_data.count
    end
    return tagging_count
  end

  def all_successors_inactive
  	check=true
    if SourceCategory.where(predecessor: self.id)==[]
    else
      successors=SourceCategory.where(predecessor: self.id)
      successors.each do |successor|
        if successor.inactive!=true
          check=false
        else
        end
      end
    end
    return check
  end

  def not_used_since
    if Lead.where(source_category_id: self.id)==[]
      return 999
    else
    return ((Time.now-(Lead.where(source_category_id: self.id).sort_by{|x| x.created_at}.last.created_at))/86400).round(0)
    end
  end

  def leaf?
    if SourceCategory.where(predecessor: self.id).where.not(inactive: true)==[]
       return true
    else
       return false
    end
  end

  def self.leaves(current_personnel)
    facebook_source = SourceCategory.find_by(organisation_id: current_personnel.organisation_id, description: 'FACEBOOK')
    facebook_source_two = SourceCategory.find_by(organisation_id: current_personnel.organisation_id, description: 'Facebook')
    facebook_marketplace = SourceCategory.find_by(organisation_id: current_personnel.organisation_id, description: 'marketplace')
    if facebook_source != nil
    source_categories = [[facebook_source.heirarchy, facebook_source.id]]
    elsif facebook_source_two != nil
    source_categories = [[facebook_source_two.heirarchy, facebook_source_two.id]]
    else
    source_categories = []
    end
    if facebook_marketplace==nil
    else
      source_categories+=[[facebook_marketplace.heirarchy, facebook_marketplace.id]]
    end
    SourceCategory.where(organisation_id: current_personnel.organisation_id).each do |source_category|
      if source_category.leaf?
        if (source_category.inactive==true) || (source_category.heirarchy.downcase.include?('facebook'))
        else
        source_categories+=[[source_category.heirarchy, source_category.id]]
        end
      end
    end
    return source_categories.sort {|a,b| a[0] <=> b[0]}
  end

  def self.leaves_including_deactivated(current_personnel)
    source_categories=[]
    SourceCategory.where(organisation_id: current_personnel.organisation_id).each do |source_category|
      if source_category.leaf?
        source_categories+=[[source_category.heirarchy, source_category.id]]
      end
    end
    return source_categories.sort {|a,b| a[0] <=> b[0]}
  end


end
