require 'net/sftp'
require 'nokogiri'
# require 'pry-rails'
ENV["RAILS_ENV"] ||= 'production'
require File.expand_path("../../../config/environment", __FILE__)

# Instance Variables to Control directory
#testing 
#@completed_dir = 'testin/'
#@start_dir = 'testin/'
@completed_dir = 'out/archived/'
@start_dir = 'out/'

Net::SFTP.start('sftp.spscommerce.com', ENV["SPS_SFTP_USER"], port: 10022, password: ENV["SPS_SFTP_PASS"] ) do |sftp|
  # capture all stderr and stdout output from a remote process
  sftp.connect do
    puts "open!"
    # Begin looping through files in directory
    sftp.dir.glob("#{@start_dir}", "*.xml") do |entry|

      xml_file = sftp.file.open("#{@start_dir}""#{entry.name}")
      doc = Nokogiri::XML.parse(xml_file)
      
      if doc.xpath('/Order/Meta/IsDropShip[last()]').text == "true"
        puts "dropship is true"
        sales_order = {}
        sales_order[:c_name] = "Amazon Direct Fulfillment"
        sales_order[:c_po] = doc.xpath('/Order/Header/OrderHeader/PurchaseOrderNumber').text
        sales_order[:c_date] = doc.xpath('/Order/Header/OrderHeader/PurchaseOrderDate').text
        sales_order[:amazon_df_cust_order] = doc.xpath('/Order/Header/OrderHeader/CustomerOrderNumber').text

        #lets pull the shipping date
        doc.xpath('/Order/Header/Dates').each do |sd|
          if sd.xpath('DateTimeQualifier').text == "010"
            sales_order[:c_ship] = sd.xpath('Date').text
          end
        end

        # Ship To Info (we hope)
        doc.xpath('/Order/Header/Address').each do |ad|
          if ad.xpath('AddressTypeCode').text == "ST"
            sales_order[:c_ship1] = ad.xpath('AddressName').text
            
            if ad.xpath('AddressAlternateName').text != ""
              sales_order[:c_ship2] = ad.xpath('AddressAlternateName').text
            end
            
            sales_order[:c_ship3] = ad.xpath('Address1').text
            
            if ad.xpath('Address2').text != ""
              sales_order[:c_ship4] = ad.xpath('Address2').text
            end

            sales_order[:c_shipcity] = ad.xpath('City').text
            sales_order[:c_shipstate] = ad.xpath('State').text
            sales_order[:c_shippostal] = ad.xpath('PostalCode').text
            sales_order[:c_shipcountry] = ad.xpath('Country').text
          end
        end

        #buyer info - Do we need this?
        sales_order[:customer_id] = Customer.find_by(list_id: "80001601-1557337814").id
        

        #carrier info
        sales_order[:c_via] = doc.xpath('/Order/Header/CarrierInformation/CarrierRouting').text
        sales_order[:address_type_code] = doc.xpath('/Order/Header/CarrierInformation/Address/AddressTypeCode').text
        # Is it a residential address?
        if doc.xpath('/Order/Header/CarrierInformation/Address/AddressLocationNumber').text == "RES"
          sales_order[:address_residential] = true
        end

        # Lets make sure this is prepared to send
        sales_order[:send_to_qb] = true
        sales_order[:qb_process] = true

        # Adding a default class
        sales_order[:c_class] = "Amazon VC"
        
        # Need to save order info, so we can reference for line item info
        puts "This is the info you need to save"
        puts sales_order

        if Order.exists?(c_po: sales_order[:c_po])
          puts "order exists"
          sftp.rename("#{@start_dir}""#{entry.name}", "#{@completed_dir}""#{entry.name}", flags="0x0004")
          Log.create(worker_name: "NET SFTP", status: "Duplicate", log_msg: "Duplicate #{entry.name} was moved into #{@completed_dir}")
        else
          if Order.create(sales_order)
            
            puts "order create was successful"
            
          # Variable to save total amount of order
            order_id = Order.find_by(c_po: sales_order[:c_po]).id
            amount = 0.00
            # Line Item Loop
            if doc.xpath('/Order/Summary/TotalLineItemNumber').text.to_i > 1
              puts "line item is greater than 1"
              doc.xpath('//LineItem').each_with_index do |li, index|
                li_data = {}
                li_data[:txn_id] = sales_order[:c_po] + "-" + index.to_s
                #TESTING NON-UNIQUE ID
                # li_data[:txn_id] = sales_order[:c_po]?\
                upc_raw = li.xpath('OrderLine/BuyerPartNumber').text
                # upc_edit = upc_raw[0] + "-" + upc_raw[1..5] + "-" + upc_raw[6..10] + "-" + upc_raw[11]

                if li_data[:item_id] = Item.find_by(code: upc_raw, unit: "By the Caddy").id
                  li_data[:qty] = li.xpath('OrderLine/OrderQty').text.to_i
                  li_data[:amount] = li_data[:qty] * li.xpath('OrderLine/PurchasePrice').text.to_f
                  amount = amount + li_data[:amount]
                  li_data[:description] = li.xpath('ProductOrItemDescription/ProductDescription').text
                  li_data[:site_id] = Site.find_by(list_id: "80000023-1502919044").id
                  li_data[:order_id] = order_id
                  
                  # SAVE ME
                  if LineItem.exists?(txn_id: li_data[:txn_id])
                    puts "line item txn id exists"
                  else
                    if LineItem.create(li_data)
                      puts "line item create was successful"
                    else
                      Log.create(worker_name: "Amazon API", status: "Error", log_msg: "Line Item couldn't be created on PO " + sales_order[:c_po] + "item upc = " + upc_raw)
                    end
                  end
                else
                  # Did the Item Id Lookup fail?
                  Log.create(worker_name: "Amazon API", status: "Error", log_msg: "Item ID couldn't be found from UPC on PO " + sales_order[:c_po] + " item upc = " + upc_raw)
                end
              end
            else
              puts "line item is equal to 1"
              li_data = {}
              li_data[:txn_id] = sales_order[:c_po] + "-" + 0.to_s
                #TESTING NON-UNIQUE ID
                # li_data[:txn_id] = sales_order[:c_po]
              upc_raw = doc.xpath('/Order/LineItem/OrderLine/BuyerPartNumber').text              
              # upc_edit = upc_raw[0] + "-" + upc_raw[1..5] + "-" + upc_raw[6..10] + "-" + upc_raw[11]
               # Item.find_by(code: "MOCA", unit: "By the Caddy")
              if li_data[:item_id] = Item.find_by(code: upc_raw, unit: "By the Caddy").id
                li_data[:qty] = doc.xpath('/Order/LineItem/OrderLine/OrderQty').text.to_i
                li_data[:amount] = li_data[:qty] * doc.xpath('/Order/LineItem/OrderLine/PurchasePrice').text.to_f
                amount = amount + li_data[:amount]
                li_data[:description] = doc.xpath('/Order/LineItem/ProductOrItemDescription/ProductDescription').text
                li_data[:site_id] = Site.find_by(list_id: "80000023-1502919044").id
                li_data[:order_id] = order_id
                
              # SAVE ME
                if LineItem.exists?(txn_id: li_data[:txn_id])
                  puts "line item txn id exists"
                else
                  if LineItem.create(li_data)
                    puts "line item create was successful"
                  else
                    Log.create(worker_name: "Amazon API", status: "Error", log_msg: "Line Item couldn't be created on PO " + sales_order[:c_po] + "item upc = " + upc_raw)
                  end
                end
              else
                # Did the Item Id Lookup fail?
                Log.create(worker_name: "Amazon API", status: "Error", log_msg: "Item ID couldn't be found from UPC on PO " + sales_order[:c_po] + "item upc = " + upc_raw)
              end
            end
            # Lets save the new total amount for all the line items in the order
            previous_order = Order.find(order_id)
            previous_order.c_total = amount
            previous_order.save
          else
            puts "order create has failed"
            Log.create(worker_name: "Amazon API", status: "Error", log_msg: "Order create failed on PO " + sales_order[:c_po])
          end
        end
      end #end of the dropship is true statement
      sftp.rename("#{@start_dir}""#{entry.name}", "#{@completed_dir}""#{entry.name}", flags="0x0004")
      Log.create(worker_name: "NET SFTP", status: "Completed", log_msg: "Moved #{entry.name} into #{@completed_dir}")
    end #the end of the directory open and move statement
  end
end


# sftp.file.open("testout/PO13006208096.xml") do |file|
  #   while line = file.gets
  #     puts line
  #   end
  # end