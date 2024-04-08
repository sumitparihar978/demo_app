class CreateWallets < ActiveRecord::Migration[6.0]
	def change
		create_table :wallets, id: :uuid do |t|
			t.float :amount
			t.references :user, foreign_key: true, type: :uuid, index: true
			t.text :note

			t.timestamps
		end
	end
end