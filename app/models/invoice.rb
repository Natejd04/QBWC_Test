class Invoice < ActiveRecord::Base
	has_many :line_items, :dependent => :destroy, foreign_key: "invoice_id"
    has_many :items, through: :line_items, foreign_key: "invoice_id"
    has_many :sites, through: :line_items, foreign_key: "site_id"
    has_many :comments, :dependent => :destroy, foreign_key: "invoice_id"
    belongs_to :customer

    default_scope {where(:deleted => nil)}




include ReportsKit::Model
  reports_kit do
    aggregation :sum_of_invoices, [:sum, 'invoices.c_subtotal']
    # contextual_filter :for_customer, ->(relation, context_params) { relation.where(customer_id: context_params[:customer_id]) }
    # dimension :customer_group, group: '(customers.name)'
    # filter :is_published, :boolean, conditions: ->(relation) { relation.where(status: 'published') }
    dimension :approximate_invoice_total, group: 'invoices.c_subtotal'
  end

  # STATUSES = %w(draft private published).freeze

  def to_s
     c_name
  end

end
