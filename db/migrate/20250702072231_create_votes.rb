class CreateVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :performer, null: false, foreign_key: true

      t.timestamps
    end

    # Enforce one vote per user at the database level
    add_index :votes, :user_id, unique: true, name: 'index_votes_on_user_id_unique'
  end
end
