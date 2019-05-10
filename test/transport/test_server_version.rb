require 'net/sftp'
require 'nokogiri'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../../config/environment", __FILE__)

Net::SFTP.start('sftp.spscommerce.com', ENV["SPS_SFTP_USER"], port: 10022, password: ENV["SPS_SFTP_PASS"] ) do |sftp|
  # capture all stderr and stdout output from a remote process
  sftp.connect do
    puts "open!"
    xml_file = sftp.file.open("testout/PO13006207965.xml")
    doc = Nokogiri::XML.parse(xml_file)
    
    if doc.xpath('/Order/Meta/IsDropShip[last()]').text == "true"
      puts "dropship is true"
      sales_order = {}
      sales_order[:PONumber] = doc.xpath('/Order/Header/OrderHeader/PurchaseOrderNumber').text
      sales_order[:Date] = doc.xpath('/Order/Header/OrderHeader/PurchaseOrderDate').text
      sales_order[:CustomerOrderNumber] = doc.xpath('/Order/Header/OrderHeader/CustomerOrderNumber').text

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
      sales_order[:customer_id] = Customer.find_by(name: "Amazon Direct Fulfillment").id
      

      #carrier info
      sales_order[:c_via] = doc.xpath('/Order/Header/CarrierInformation/CarrierRouting').text
      sales_order[:address_type_code] = doc.xpath('/Order/Header/CarrierInformation/Address/AddressTypeCode').text
      # Is it a residential address?
      if doc.xpath('/Order/Header/CarrierInformation/Address/AddressLocationNumber').text == "RES"
        sales_order[:address_residential] = true
      end

      # Need to save order info, so we can reference for line item info
      puts "This is the info you need to save"
      puts sales_order

      # Line Item Loop
      if doc.xpath('/Order/Summary/TotalLineItemNumber').text.to_i > 1
        puts "line item is greater than 1"
        doc.xpath('//LineItem').each do |li|
          li_data = {}
          li[:product_upc] = li.xpath('OrderLine/BuyerPartNumber').text.to_i
          li[:quantity] = li.xpath('OrderLine/OrderQty').text.to_i
          li[:description] = li.xpath('ProductOrItemDescription/ProductDescription').text
        end
      end

      #Line Item if just a single item
      if doc.xpath('/Order/Summary/TotalLineItemNumber').text.to_i == 1
        puts "line item is equal to 1"
        sales_order[:product_upc] = doc.xpath('/Order/LineItem/OrderLine/BuyerPartNumber').text.to_i
        sales_order[:quantity] = doc.xpath('/Order/LineItem/OrderLine/OrderQty').text.to_i
        sales_order[:description] = doc.xpath('/Order/LineItem/ProductOrItemDescription/ProductDescription').text
      end

    end #end of the dropship is true statement
  end
end


# sftp.file.open("testout/PO13006208096.xml") do |file|
  #   while line = file.gets
  #     puts line
  #   end
  # end