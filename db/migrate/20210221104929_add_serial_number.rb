class AddSerialNumber < ActiveRecord::Migration[6.1]
  def change
    add_column :students, :serial_no, :string, null: false
  end
end
