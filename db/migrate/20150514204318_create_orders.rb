class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :c_name
      t.decimal :c_total
      t.integer :m_ab
      t.integer :m_cc
      t.integer :m_ccc
      t.integer :m_co
      t.integer :m_cpb
      t.integer :m_dch
      t.integer :m_dcm
      t.integer :m_dnb
      t.integer :m_moc
      t.integer :m_lcc
      t.integer :m_occ
      t.integer :m_pbcc
      t.integer :c_ab
      t.integer :c_cc
      t.integer :c_ccc
      t.integer :c_co
      t.integer :c_cpb
      t.integer :c_dch
      t.integer :c_dcm
      t.integer :c_dnb
      t.integer :c_moc
      t.integer :c_lcc
      t.integer :c_occ
      t.integer :c_pbcc
      t.string :c_po
      t.string :c_edit
      t.string :c_qbid
      t.date :c_date
      t.string :c_ack
      t.string :c_conf
      t.string :c_pro
      t.string :c_scac
      t.string :c_bol
      t.date :c_ship
      t.date :c_deliver
      t.string :c_via
      t.string :c_memo

      t.timestamps null: false
    end
  end
end
