class Company < ApplicationRecord
has_many :business_units
belongs_to :organisation
has_many :maintainance_charges
has_many :electrical_charges
validates_length_of :GSTIN, :maximum => 15, :minimum => 15
end
