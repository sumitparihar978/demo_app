class CreateRewards < ActiveRecord::Migration[6.0]
	def change
		create_table :rewards, id: :uuid do |t|
			t.string :points, default: 0
			t.string :special_reward #it can be free coffee, movie ticket etc
			t.references :user, foreign_key: true, type: :uuid, index: true
			t.boolean :rewarded, default: false

			t.timestamps
		end
	end
end
