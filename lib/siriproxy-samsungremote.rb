require 'socket'
require 'base64'
 
class SiriProxy::Plugin::SamsungRemote < SiriProxy::Plugin
  attr_accessor :tvip, :myip, :mymac, :port

  @@appstring = "iphone..iapp.samsung" #W hat the iPhone app reports
  @@tvappstring = "iphone.LE40C650.iapp.samsung" # Might need changing to match your TV type
  @@remotename = "Ruby Samsung Remote" # What gets reported when it asks for permission/also shows in General->Wireless Remote Control menu
  
  @@know_btns = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'UP',
    'DOWN',
    'LEFT',
    'RIGHT',
    'MENU',
    'PRECH',
    'GUIDE',
    'INFO',
    'RETURN',
    'CH_LIST',
    'EXIT',
    'ENTER',
    'SOURCE',
    'AD',
    'PLAY',
    'PAUSE',
    'MUTE',
    'PICTURE_SIZE',
    'VOLUP',
    'VOLDOWN',
    'TOOLS',
    'POWEROFF',
    'CHUP',
    'CHDOWN',
    'CONTENTS',
    'W_LINK',
    'RSS',
    'MTS',
    'CAPTION',
    'REWIND',
    'FF',
    'REC',
    'STOP',
    'TV',
    ]

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
    send_hanshake
    send_command "MUTE"
    close_socket
    say "Command sent"
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
    
  end
  
  listen_for(/can you turn the sound (up|down)/i) do |dir|
    send_hanshake
    if dir == 'up'
      command = 'VOLUP'
    elsif dir == 'down'
      command = 'VOLDOWN'
    end
    send_command command
    begin
    keepgoing = ask "Is that ok?"
        keepgoing.strip!
    if keepgoing == "No" or keepgoing == "Nope" or keepgoing == "Not yet" or keepgoing == "Keep going" or keepgoing == "That isn't good" or keepgoing == "That's not good" then
        keepgoing = "1"
        send_command command
    elsif keepgoing == /too quiet/i or keepgoing == /too loud/i
        keepgoing = "1"
        command = command == "VOLUP" ? "VOLDOWN" : "VOLUP"
        send_command command
    else
        keepgoing = "0"
        say "Ok. I'll leave it there."
    end
    end while keepgoing == "1"
    
    close_socket
    request_completed
  end
  
  
  listen_for(/launch the iplayer/i) do
    send_hanshake
    
    send_command "RSS"
    sleep 2
    send_command "RIGHT"
    sleep 1
    send_command "ENTER"
    
    close_socket
    request_completed
  end
  
  listen_for(/exit the iplayer/i) do
    send_hanshake
    
    send_command "EXIT"
    
    close_socket
    request_completed
  end
  
  listen_for(/go (left|right|up|down)/i) do |dir|
    posdir = ["left", "right", "up", "down"]
    if posdir.include?(dir)
      send_hanshake
      send_command dir.upcase
      close_socket
    else
      say "I can't go that way"
    end
    request_completed
    
  end
  
  listen_for(/can you turn the telly off please/i) do
    
    sure = ask "Are you sure?"
    sure.strip!
    if sure == "Yes" or sure == "Yes please"
      send_hanshake
    
      send_command "POWEROFF"
    
      close_socket
      say "Ok, I've turned it off. You'll need to turn it on yourself if you want me to do anything else with the telly."
    else
      say "Ok, I'll leave it on for now then"
    end
    
    request_completed
    
    
  end  
  
  listen_for(/press the (.*) button/i) { |btn| press_the(btn) }
  
  
  def press_the(btn)
    if @@know_btns.include?(btn.upcase)
      send_hanshake
      send_command btn.upcase
      close_socket
      say "#{btn} pressed"
      request_completed #always complete your request! Otherwise the phone will "spin" at the user!
    else
      say "I can't find the #{btn} button right now"
      ask "Try again"
      request_completed #always complete your request! Otherwise the phone will "spin" at the user!
    end
    
  end
  
  def send_hanshake
    @s = TCPSocket.open(self.tvip, self.port)

    ipencoded = Base64.encode64(self.myip)
  	macencoded = Base64.encode64(self.mymac)

    messagepart1 = 0x64.chr + 0x00.chr + ipencoded.length.chr + 0x00.chr + ipencoded + macencoded.length.chr + 0x00.chr + macencoded + Base64.encode64(@@remotename).length.chr + 0x00.chr + Base64.encode64(@@remotename)
    part1 = 0x00.chr + @@appstring.length.chr + 0x00.chr + @@appstring + messagepart1.length.chr + 0x00.chr + messagepart1

    @s.send(part1, 0)
    
    messagepart2 = 0xc8.chr + 0x00.chr
    part2 = 0x00.chr + @@appstring.length.chr + 0x00.chr + @@appstring + messagepart2.length.chr + 0x00.chr + messagepart2
    
    @s.send(part2, 0)
    
  end
  
  def send_command(command)
    
    #Send remote key
    key = "KEY_" + command
    # say "Sending #{command}"
    messagepart3 = 0x00.chr + 0x00.chr + 0x00.chr + Base64.encode64(key).length.chr + 0x00.chr + Base64.encode64(key)
    part3 = 0x00.chr + @@tvappstring.length.chr + 0x00.chr + @@tvappstring + messagepart3.length.chr + 0x00.chr + messagepart3

    @s.send(part3, 0)

   
  end
  
  def close_socket
     @s.close               # Close the socket when done
  end
  
  

end