class RemoveCollegeIdFromColleges < ActiveRecord::Migration
  def change
    remove_column :colleges, :college_id, :integer
  end
end
