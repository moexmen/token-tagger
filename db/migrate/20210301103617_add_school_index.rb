class AddSchoolIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :students, :school_code
  end
end
