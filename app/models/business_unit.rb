class BusinessUnit < ApplicationRecord
belongs_to :company
belongs_to :organisation
has_many :maintianance_charges
has_many :electrical_charges
has_many :maintianance_bills
has_many :maintianance_ledger_entries
has_many :line_items
validates_presence_of :name
validates_uniqueness_of :name
validates_presence_of :address_1
validates_presence_of :address_2
validates_presence_of :address_3
has_many :personnels
has_many :marketing_numbers
has_many :blocks
has_many :leads
has_many :follow_ups  
has_many :payment_plans
has_many :extra_development_charges
has_many :car_parks
has_many :servant_quarters
has_many :taxes
has_many :posession_charges
has_many :email_templates
has_many :whatsapp_templates
has_many :monthly_targets
end
