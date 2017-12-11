class CreateColleges < ActiveRecord::Migration
  def change
    create_table :colleges do |t|
      t.string :name
      t.string :desc

      t.timestamps null: false
    end
  end
end
