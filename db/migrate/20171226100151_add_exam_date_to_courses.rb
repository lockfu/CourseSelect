class AddExamDateToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :exam_date, :string
  end
end
