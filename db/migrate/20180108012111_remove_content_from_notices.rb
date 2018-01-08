class RemoveContentFromNotices < ActiveRecord::Migration
  def change
    remove_column :notices, :content, :string
  end
end
