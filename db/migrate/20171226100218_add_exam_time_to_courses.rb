class AddExamTimeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :exam_time, :string
  end
end
