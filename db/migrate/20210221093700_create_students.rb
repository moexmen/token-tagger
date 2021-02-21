class CreateStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.string :school_code, null: false
      t.string :school_name
      t.string :school_cluster

      t.string :name, null: false
      t.string :class_name
      t.string :level
      t.string :nric, null: false
      t.string :contact, null: false

      t.string :token_id
      t.string :status, default: Student.statuses[:pending]

      t.string :batch

      t.timestamps

      t.index ["token_id"], unique: true
      t.index ["nric"], unique: true
    end
  end
end
