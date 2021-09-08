class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      # t.string :email, null: false, default: ""
      t.integer :chart_status, default: 1
      t.boolean :admin, default: false,  null: false

      t.timestamps
    end
  end
end
