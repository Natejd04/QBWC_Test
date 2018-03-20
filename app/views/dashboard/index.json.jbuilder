json.array!(@search) do |book|
	json.name				book.name
	json.city				book.city
	json.state     		    book.state
	json.id					book.id
	json.orders				book.orders	
	json.invoices			book.invoices
	#THIS IS NOT A GREAT SOLUTION
	#	json.orders book.orders do |o|
	#		json.invoice_number o.invoice_number
	#		json.id				o.id
	#	end	
end