class UserPlan < ApplicationRecord
	#
	# associations
	#

	belongs_to :user
	belongs_to :plan
end
