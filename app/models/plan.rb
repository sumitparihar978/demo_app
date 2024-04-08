class Plan < ApplicationRecord
	#
	# scope
	#

	scope :get_standard_plan, -> { find_by("lower(name) = ?", 'standard') }
end
