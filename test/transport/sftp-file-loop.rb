require 'net/sftp'
require 'nokogiri'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../../config/environment", __FILE__)
@completed_dir = 'testout/archive/'
@start_dir = 'testout/'

Net::SFTP.start('sftp.spscommerce.com', ENV["SPS_SFTP_USER"], port: 10022, password: ENV["SPS_SFTP_PASS"] ) do |sftp|
  # capture all stderr and stdout output from a remote process
  sftp.connect do
    # Begin looping through files in directory
    sftp.dir.glob("#{@start_dir}", "*.xml") do |entry|
      sftp.rename("#{@start_dir}""#{entry.name}", "#{@completed_dir}""#{entry.name}", flags="0x0004")
    end    
  end
end


# sftp.file.open("testout/PO13006208096.xml") do |file|
  #   while line = file.gets
  #     puts line
  #   end
  # end