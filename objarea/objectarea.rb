require_relative "rbcolor.rb"

include Color

$lag = 0
$debug_messages = []
$debug=false
$devmode=false
$items=[]
$show_exit_path=false
$exit_path_style="id"
$commands = {
  "east"=>:east,
  "west"=>:west,
  "north"=>:north,
  "south"=>:south,
  "get"=>:get,
  "drop"=>:drop,
  "put"=>:put,
  "inventory"=>:display_inventory,
  "look"=>:look,
  "say"=>:say,
  "scan"=>:scan,
  "give"=>:give,
  "help"=>:help,
}
EXIT_LIST=[:NExit,:EExit,:SExit,:WExit,:UExit,:DExit]
EXIT_NAME_LIST = [:north, :east, :south, :west, :up, :down]
NAME_TO_EXIT_NAME = {"n" => "NExit","e" => "EExit", "s" => "SExit", "w" => "WExit", "u" => "UExit", "d" => "DExit"}
INVERTED_NAME = {"s" => "n", "e" => "w", "w" => "e", "u" => "d", "d" => "u", "n"=>"s"}
INVERTED_EXIT_NAME = {"NExit" => "SExit", "SExit" => "NExit", "EExit" => "WExit", "WExit" => "EExit", "UExit" => "DExit", "DExit" => "UExit"}
NAME_TO_REAL_NAME = {"n" => "north","e" => "east", "s" => "south", "w" => "west", "u" => "up", "d" => "down"}
REAL_NAME_TO_NAME = {"north" => "n", "east" => "e", "south" => "s", "west" => "w", "up" => "u", "down" => "d"}

SUCCESS = 67767
FALIURE = 76676
class GameObject
  attr_accessor :name, :shortdesc, :longdesc, :m_ints, :props
  attr_reader :id

  def initialize infohash
    @id = infohash[:id]
    @name = infohash[:name]
    @shortdesc = infohash[:shortdesc]
    @longdesc = infohash[:longdesc]
    @m_ints = (infohash[:m_ints] or {})
    @props = {}
  end

  def broadcast_gl command, body #hash
    message = {:sender=>self.id, :command=>command, :body=>body}
    Message.broadcast message, true
  end
  
  def echo_gl message
    Message.broadcast({:sender=>self.id, :command=>"glecho", :body=>message}, true)
  end
  
  def to_s; $devmode ? "#{@name}<#{id}>" : @name; end
  
  def <=> otr_object
    self.id <=> otr_object.id
  end
  
  def method_missing *argv
    instance_variable_name = "@#{argv.shift}"
    instance_variable_value = argv.shift
    
    instance_variable_set(instance_variable_name, instance_variable_value)
  end
end

module Thing
  attr_accessor :name, :shortdesc, :longdesc, :m_ints, :keywords, :hidden

  def broadcast_pr command, body #hash
    message = {:sender=>self.id, :command=>command, :body=>body}
    Message.broadcast message, false
  end
end

module InanimateObject; end

require_relative "help.rb"
require_relative "container.rb"
require_relative "terrains.rb"
require_relative "character.rb"
require_relative "item.rb"
require_relative "location.rb"
require_relative "message.rb"
require_relative "target.rb"
require_relative "lparse.rb"
require_relative "mainloop_display.rb"
require_relative "map.rb"
require_relative "server.rb"
require_relative "pager.rb"

class Game
   #define main characteristics for the player
  $temp_hash={
    :name=>"You",
    :shortdesc=>"This is you.",
    :longdesc=>"This is you.",
    :m_ints=>{},
    :keywords=>["player", "me", "self"],
    :inventory=>[],
    :id=>"PLAYER",
    :current_room=>nil,
  }
  class Player < Character; @@infohash = $temp_hash;end
  
  def create
    
   
    #create player
    #$player is OK to change, PLAYER is constant
    $player = (@player = Player.new)
    $temp_hash = nil
    
    $server = (@server = VServer.new)
    
    # INTEGRITY CHECK
    ObjectSpace.each_object(GameObject).each do |obj|
      if not obj.id =~ /\A\z/
        
      end
    end
    
  end
  
  def start
    Mainloop.main
  end
  
end