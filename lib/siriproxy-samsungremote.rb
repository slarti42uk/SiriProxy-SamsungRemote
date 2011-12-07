require 'socket'
require 'base64'
 
class SiriProxy::Plugin::SamsungRemote < SiriProxy::Plugin
  attr_accessor :tvip, :myip, :mymac, :port

  @@appstring = "iphone..iapp.samsung" #W hat the iPhone app reports
  @@tvappstring = "iphone.LE40C650.iapp.samsung" # Might need changing to match your TV type
  @@remotename = "Ruby Samsung Remote" # What gets reported when it asks for permission/also shows in General->Wireless Remote Control menu


  def initialize(config = {})
    
    self.tvip = config["tvip"]
    self.myip = config["myip"]
    self.mymac = config["mymac"]
    self.port = '55000'
  end


  listen_for(/test remote control/i) do
    say "Remote control responding"
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  listen_for(/test settings/i) do
    say "Television IP address is #{self.tvip}"
    say "My IP address is #{self.myip}"
    say "My MAC address is #{self.mymac}"
    say "The port is #{self.port}"
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!

  end
  
  listen_for(/test command/i) do 
    say "About to test"
    send_command "MUTE"
    say "Command sent"
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
    
  end
  
  def send_command(command)
    s = TCPSocket.open(self.tvip, self.port)

    ipencoded = Base64.encode64(self.myip)
  	macencoded = Base64.encode64(self.mymac)
  	puts ipencoded
  	puts macencoded

    messagepart1 = 0x64.chr + 0x00.chr + ipencoded.length.chr + 0x00.chr + ipencoded + macencoded.length.chr + 0x00.chr + macencoded + Base64.encode64(@@remotename).length.chr + 0x00.chr + Base64.encode64(@@remotename)
    puts messagepart1
    part1 = 0x00.chr + @@appstring.length.chr + 0x00.chr + @@appstring + messagepart1.length.chr + 0x00.chr + messagepart1
    puts part1
    s.send(part1, part1.length)
    
    messagepart2 = 0xc8.chr + 0x00.chr
    puts messagepart2
    part2 = 0x00.chr + @@appstring.length.chr + 0x00.chr + @@appstring + messagepart2.length.chr + 0x00.chr + messagepart2
    puts part2
    
    s.send(part2, part2.length)
    
    #Send remote key
    # key = "KEY_" + command;
    # puts key
    # say "Sending #{command}"
    # messagepart3 = 00.chr + 00.chr + 00.chr + Base64.encode64(key).length.chr + 00.chr + Base64.encode64(key)
    # part3 = 00.chr + @@tvappstring.length.chr + 00.chr + @@tvappstring + messagepart3.length.chr + 00.chr + messagepart3
    # s.puts(part3, part3.length)
    # puts part3


    # s.close               # Close the socket when done
  end
  
  

end