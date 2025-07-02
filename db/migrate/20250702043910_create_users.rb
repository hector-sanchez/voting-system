class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :zipcode, null: false
      t.string :password_digest, null: false
      t.integer :token_version, default: 0, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, [:email, :zipcode], unique: true, name: 'index_users_on_email_and_zipcode'
  end
end
