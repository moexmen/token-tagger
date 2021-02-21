class CreateSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :schools do |t|
      t.string :code, null: false
      t.string :name
      t.string :cluster

      t.timestamps
    end

    remove_column :students, :school_name, :string
    remove_column :students, :school_cluster, :string
  end
end
