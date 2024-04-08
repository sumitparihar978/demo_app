class CreateUsers < ActiveRecord::Migration[6.0]
	def change
		create_table :users, id: :uuid do |t|
			t.string :name
			t.string :email
			t.string :country_name
			t.integer :total_points, default: 0
			t.datetime :points_last_reset_at
			t.datetime :birth_date

			t.timestamps
		end
	end
end
