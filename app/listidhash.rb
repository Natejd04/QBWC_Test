class ListIdHash 
    
   def self.hash
       string.each_char.inject("") do |memo, char|
           memo += char.ord.rjust(3, "0")
       end
   end
   
    
   def self.unhash
       result = ""
       string.split("").each_slice(3) do |slice|
           result << slice.join("").to_i.char
       end
       result
   end
    
end