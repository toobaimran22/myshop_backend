class ChangeDefaultStatusInOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_default :orders, :status, 'pending'
  end
end
