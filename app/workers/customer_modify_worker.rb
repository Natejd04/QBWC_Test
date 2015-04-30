require 'qbwc'

class CustomerModifyWorker < QBWC::Worker

    def requests(job)
        {
            :customer_mod_rq => {
                }
            }
            
#            :customer_mod_rq => {
#            :customer_mod => {
#            :list_id => "80000079",
#            :edit_sequence => "1576443701",
#            :bill_address => { :addr1 => "1234 Seasme St", :Addr2 => "apt 103", :City => "Seattle", :State => "WA", :PostalCode => "98125"}
#                }
#            }
#                
#                '<QBXML>
#                   <QBXMLMsgsRq onError="continueOnError">
#            <CustomerModRq>
#            <CustomerMod>
#            <ListID >80000079</ListID>
#            <EditSequence >1576443701</EditSequence>
#            <BillAddress>
#            <Addr1 >1234 Seasme St</Addr1>
#            <Addr2 >Apt 103</Addr2> 
#            <City >Seattle</City>
#            <State >WA</State>
#            <PostalCode >98125</PostalCode>
#            </BillAddress>
#            </CustomerModRq>
#            </CustomerMod>
#                   </QBXMLMsgsRq>
#
#                    </QBXML>'
#                
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        Rails.logger.info("This is the start of the customer mod")
        
        QBWC_CUSTOMER_MOD_RQ = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
#            <?qbxml version=\"7.0\"?>\r
#            <QBXML>\r
#            <QBXMLMsgsRq onError=\"continueOnError\">\r
#            <CustomerModRq>\r
#            <CustomerMod>\r
#            <ListID>80000079</ListID>\r
#            <EditSequence>1576443701</EditSequence>\r
#            <BillAddress>\r
#            <Addr1>1234 Seasme St</Addr1>\r
#            <Addr2>Apt 103</Addr2>\r
#            <City>Seattle</City>\r
#            <State>WA</State>\r
#            <PostalCode >98125</PostalCode>\r
#            </BillAddress>\r
#            </CustomerModRq>\r
#            </CustomerMod>\r
#            </QBXMLMsgsRq>\r
#                    </QBXML>\r"
        
      
    end

    
end
#
## '<QBXML>
##
##                   <QBXMLMsgsRq onError="continueOnError">
##            <CustomerModRq>
##            <CustomerMod>
##            <ListID >'+ customer_edit[:listid] +'</ListID>
##            <EditSequence >'+ customer_edit[:edit_sq] +'</EditSequence>
##            <BillAddress>
##            <Addr1 >'+ customer_edit[:address] +'</Addr1>
##            <Addr2 >'+ customer_edit[:address2] +'</Addr2> 
##            <City >'+ customer_edit[:city] +'</City>
##            <State >'+ customer_edit[:state] +'</State>
##            <PostalCode >'+ customer_edit[:zip] +'</PostalCode>
##            </BillAddress>
##            </CustomerModRq>
##            </CustomerMod>
##                   </QBXMLMsgsRq>
##
##                    </QBXML>'
##                