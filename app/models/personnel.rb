class Personnel < ApplicationRecord

  attr_accessor :password
  before_save :encrypt_password, :except =>  :send_password_reset
  validates :password, :format => {:with => /(?=.*[a-zA-Z])(?=.*[0-9]).{6,}/, message: "must be at least 6 characters and include one number and one letter"}, :on => :create
  validates_confirmation_of :password, :on => :create
  validates_presence_of :password, :on => :create 
  validates_presence_of :email
  validates_presence_of :organisation_id

  validates_uniqueness_of :email
  validates_uniqueness_of :name, :scope => :organisation_id
  before_create { generate_token(:auth_token) } 
  belongs_to :organisation
  belongs_to :business_unit
  has_many :calls
  has_many :leads
  has_many :follow_ups
  
def status
   if self.access_right == 0
    status='Admin'
   elsif self.access_right== -1
    status='Inactive'
   elsif self.access_right== 1
    status='Team Lead'
   elsif self.access_right== 2
    status='Back Office'
   elsif self.access_right== 3
    status='Marketing'
   elsif self.access_right== 4
    status='Audit'
   else
    status='Sales Executive' 
   end
   return status
end

def member_array
  member_array=[]
  Personnel.where(predecessor: self.id, access_right: nil).each do |member|
    member_array+=[member.id]
  end
  Personnel.where(access_right: 2, organisation_id: self.organisation_id).each do |member|
    member_array+=[member.id]
  end
  member_array+=[self.id]
  return member_array
end

def send_password_reset
  generate_token(:password_reset_token)
   self.password_reset_sent_at = Time.zone.now
  save!(:validate => false)
  UserMailer.password_reset(self).deliver
end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Personnel.exists?(column => self[column])
  end
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user
    else
      user = find_by_name(email)
    end
    if user && user.passwordhash == BCrypt::Engine.hash_secret(password, user.passwordsalt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.passwordsalt = BCrypt::Engine.generate_salt
      self.passwordhash = BCrypt::Engine.hash_secret(password, passwordsalt)
    end
  end

  def fresh_lead_count
    count = Lead.includes(:follow_ups, :personnel).where( :follow_ups => { :lead_id => nil } ).where('leads.personnel_id = ?', self.id).count
    return count
  end
  
  def all_live_leads
      leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => nil }).where('leads.personnel_id = ?',self.id)
      leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => self.id })
      leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => self.id })
      return leads
  end 

  def live_leads_with_since(since)
    from = since
    leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where(:follow_ups => { :lead_id => nil }, :leads => { :status => nil }).where('leads.personnel_id = ? AND leads.generated_on >= ?',self.id, from.to_datetime.beginning_of_day)
    leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.generated_on >= ?', nil, false, from.to_datetime.beginning_of_day).where(:leads => { :personnel_id => self.id })
    leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.generated_on >= ?', nil, false, from.to_datetime.beginning_of_day).where(:leads => { :personnel_id => self.id })
    return leads
  end

  def all_qualified_leads
    leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => false, osv: true }).where('leads.personnel_id = ?',self.id)
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.qualified_on is not ?", nil).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.qualified_on is not ?", nil).where('follow_ups.follow_up_time > ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    return leads
  end 

  def all_interested_leads
    leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => false, osv: true }).where('leads.personnel_id = ?',self.id)
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.interested_in_site_visit_on is not ?", nil).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.interested_in_site_visit_on is not ?", nil).where('follow_ups.follow_up_time > ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    return leads
  end 

  def specific_qualified_leads(since)
    from = since
    leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => false, osv: true }).where('leads.personnel_id = ?',self.id)
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.qualified_on >= ?", from.to_datetime.beginning_of_day).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.qualified_on >= ?", from.to_datetime.beginning_of_day).where('follow_ups.follow_up_time > ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    return leads
  end 

  def specific_interested_leads(since)
    from = since
    leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => false, osv: true }).where('leads.personnel_id = ?',self.id)
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.interested_in_site_visit_on >= ?", from.to_datetime.beginning_of_day).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where("leads.interested_in_site_visit_on >= ?", from.to_datetime.beginning_of_day).where('follow_ups.follow_up_time > ?', Date.today+1.day).where(:leads => { :personnel_id => self.id })
    return leads
  end 


end
