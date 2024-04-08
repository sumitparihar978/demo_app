class CreateUserPlans < ActiveRecord::Migration[6.0]
	def change
		create_table :user_plans, id: :uuid do |t|
			t.references :user, foreign_key: true, type: :uuid, index: true
			t.references :plan, foreign_key: true, type: :uuid, index: true
			t.timestamps
		end
	end
end
