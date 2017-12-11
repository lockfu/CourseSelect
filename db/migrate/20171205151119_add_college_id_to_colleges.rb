class AddCollegeIdToColleges < ActiveRecord::Migration
  def change
    add_column :colleges, :college_id, :integer
  end
end
