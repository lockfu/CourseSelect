class College < ActiveRecord::Base
	has_many :course, dependent: :destroy
end
