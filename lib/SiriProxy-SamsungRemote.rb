require 'socket'
require 'base64'

class SiriProxy::Plugin::SamsungRemote < SiriProxy::Plugin
  attr_accessor :host

  @tvip = "192.168.1.109"; # IP Address of TV
  @myip = "192.168.1.123"; # Doesn't seem to be really used
  @mymac = "00-0c-29-3e-b1-4f"; # Used for the access control/validation, but not after that AFAIK
  @appstring = "iphone..iapp.samsung"; #W hat the iPhone app reports
  @tvappstring = "iphone.LE40C650.iapp.samsung"; # Might need changing to match your TV type
  @remotename = "Ruby Samsung Remote"; # What gets reported when it asks for permission/also shows in General->Wireless Remote Control menu


  def initialize(config = {})
    self.host = config["host"]
  end


  listen_for(/test remote control/i) do
    say "Remote control responding"
  end

end