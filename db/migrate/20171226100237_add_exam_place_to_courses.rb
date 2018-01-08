class AddExamPlaceToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :exam_place, :string
  end
end
