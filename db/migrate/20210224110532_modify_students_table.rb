class ModifyStudentsTable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :students, :contact, true
    add_column :students, :contact_rejected, :boolean, default: false
    add_column :students, :error_response, :jsonb
  end
end
