json.array!(@search) do |book|
  json.name        book.name
  json.city       book.city
  json.state       book.state
  json.id			book.id
end