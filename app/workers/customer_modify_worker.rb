#require 'qbwc'
#
#class CustomerModifyWorker < QBWC::Worker
#
#    def requests(job)
#        {
#            :customer_mod_rq => {
#                
#                '<QBXML>
#                   <QBXMLMsgsRq onError="continueOnError">
#            <CustomerModRq>
#            <CustomerMod>
#            <ListID ></ListID>
#            <EditSequence ></EditSequence>
#            <BillAddress>
#            <Addr1 ></Addr1>
#            <Addr2 ></Addr2> 
#            <City ></City>
#            <State ></State>
#            <PostalCode ></PostalCode>
#            </BillAddress>
#            </CustomerModRq>
#            </CustomerMod>
#                   </QBXMLMsgsRq>
#
#                    </QBXML>'
#                
#                    },
#            
#        }
#    end
#
#    def handle_response(r, session, job, request, data)
#        # handle_response will get customers in groups of 100. When this is 0, we're done.
#        
#      
#    end
#
#    
#end
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