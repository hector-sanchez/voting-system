class CreatePerformers < ActiveRecord::Migration[7.0]
  def change
    create_table :performers do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :performers, :name
  end
end
