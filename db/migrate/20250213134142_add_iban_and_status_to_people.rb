class AddIbanAndStatusToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :iban, :string
    add_column :people, :status, :integer
  end
end
