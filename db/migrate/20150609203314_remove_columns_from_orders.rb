class RemoveColumnsFromOrders < ActiveRecord::Migration
  def change
      remove_column :orders, :m_ab
      remove_column :orders, :m_cc
      remove_column :orders, :m_ccc
      remove_column :orders, :m_co
      remove_column :orders, :m_cpb
      remove_column :orders, :m_dch
      remove_column :orders, :m_dcm
      remove_column :orders, :m_dnb
      remove_column :orders, :m_moc
      remove_column :orders, :m_lcc
      remove_column :orders, :m_occ
      remove_column :orders, :m_pbcc
      remove_column :orders, :c_ab
      remove_column :orders, :c_cc
      remove_column :orders, :c_ccc
      remove_column :orders, :c_co
      remove_column :orders, :c_cpb
      remove_column :orders, :c_dch
      remove_column :orders, :c_dcm
      remove_column :orders, :c_dnb
      remove_column :orders, :c_moc
      remove_column :orders, :c_lcc
      remove_column :orders, :c_occ
      remove_column :orders, :c_pbcc
  end
end
