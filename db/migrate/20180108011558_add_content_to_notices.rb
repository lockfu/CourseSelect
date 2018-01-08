class AddContentToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :content, :string
  end
end
