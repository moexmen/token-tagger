class AddTaggedAt < ActiveRecord::Migration[6.1]
  def change
    add_column :students, :tagged_at, :timestamp
  end
end
