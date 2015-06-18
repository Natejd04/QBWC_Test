#This should be it's own gem. 
#Tim Heuett helped create a way to hash strings into integers for id's and back
module ListIdHash
   def self.hash_id(string)
       string.each_char.inject("") do |memo, char|
           memo += char.ord.to_s.rjust(3, "0")
       end
   end
       
   def self.unhash_id(string)
       result = ""
       string.split("").each_slice(3) do |slice|
           result << slice.join("").to_i.chr
       end
       result
   end 
end