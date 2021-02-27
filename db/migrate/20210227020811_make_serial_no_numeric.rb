class MakeSerialNoNumeric < ActiveRecord::Migration[6.1]
  def up
    change_column :students, :serial_no, 'integer USING CAST(serial_no AS integer)'
  end

  def down
    change_column :students, :serial_no, :string
  end
end
