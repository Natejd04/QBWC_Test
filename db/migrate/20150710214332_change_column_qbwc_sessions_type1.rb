class ChangeColumnQbwcSessionsType1 < ActiveRecord::Migration
  def change
      change_column :qbwc_sessions, :progress, :integer
  end
end
