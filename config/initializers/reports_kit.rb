# config/initializers/reports_kit.rb

ReportsKit.configure do |config|
  config.autocomplete_results_method = lambda do |params:, context_record:, relation:|
    query = params[:q]
    table_relation = relation.to_s
    if table_relation == "Item"
      results = relation.where('name LIKE ? AND name ILIKE ?', "%FG:12/12ct Master%", "%#{query}%").order('name').limit(30)
    else
      results = relation.where('name ILIKE ?', "%#{query}%").order('name').limit(30)
    end
    results.map do |result|
      {
        id: result.id,
        text: "#{result.name}",
      }
    end
  end
end