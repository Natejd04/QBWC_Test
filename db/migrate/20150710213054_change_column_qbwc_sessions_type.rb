class ChangeColumnQbwcSessionsType < ActiveRecord::Migration
  def change
      change_column :qbwc_sessions, :progress, :bigint
  end
end
