class AddChecknumToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :checknum, :integer
  end
end
