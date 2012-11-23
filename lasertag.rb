require_relative 'objarea/objectarea.rb'

cputs "Testing colors: @Rred @Bblue @Ggreen@D", "d"

require_relative 'objarea/mazegen.rb'

Help.load_help("lasertag_help")

def hunt_traverse(wanted, start_room, init = true)
  if init
    $visited = []
    $path = []
    $results = []
  end
  
    return $results if $visited.index(start_room)
    $visited << start_room
    $results << $path.clone if (start_room==wanted or wanted=="0" or wanted=~/^SPWALL-/) and $path != []
    exits=EXIT_NAME_LIST.reject {|x| start_room.send(x)=="0" or start_room.send(x)=~/^SPWALL-/}
    exits.each {|ex|
        $path << ex
        hunt_traverse(wanted, start_room.send(ex), false)
        $path.delete_at(-1)
    }
    return $results
end

def hunt_traverse_new(room, start)
  target_room = room
  values = {room=>0}
  path = []
  
  loop do
    path << room
    break if path == [nil]
    exits = EXIT_NAME_LIST.clone.keep_if do |x|
      leads_to = room.send(x)
      (values[leads_to] or values[room]+2) > values[room]+1 and leads_to!="0" and not leads_to=~/^SPWALL-/
    end
    break if exits == [] and path == [nil]
    if exits == []
      path.delete_at(-1)
      room = path.pop
    else
      values[room.send(exits[0])] = values[room]+1
      room = room.send(exits[0])
    end
  end
  if !values[start]
    return :nopath
  else
    directions = []
    room = start
    until room == target_room
      exits = EXIT_NAME_LIST.clone.keep_if { |x|  room.send(x)!="0" and not room.send(x)=~/^SPWALL-/ and values[room.send(x)] == values[room]-1}
      directions << exits[0]
      room = room.send(exits[0])
    end
    return directions
  end
end

class Character
  def hunt(input = "", infohash = {})
    who = infohash[:direct_object]
    if infohash[:in] or infohash[:into] or infohash[:at] or infohash[:indirect_object] or infohash[:to] or !who
      return "I don't understand your sentence."
    end
    
    if (targ = target(who, :mode=>"g", :who=>"c")) == 76676
      return "I don't see that character in this area."
    end
    if targ.length > 1
      return "I can only hunt one character at a time."
    end
    targ = targ[0]
    
    result = hunt_traverse(targ.current_room, current_room)
    if result == []
      return "#{targ.name} is here!"
    end
    if result == :nopath
      return "I couldn't find a path to it."
    end
    broadcast_pr("hunt", "")
    puts "If you go #{result[0][0].to_s}, you might be closer to #{targ.name}" if @id == $player.id
    incur_lag(2)
    return RV[SUCCESS, result[0][0]]
  end
  
  attr_accessor :shots, :score
  
  def shoot(input="", infohash={})
    dirs = ["north", "east", "south", "west", "up", "down"]
    direction = input.downcase
    t_dirs = dirs.map {|x| x[0..input.length-1]}
    
    if !t_dirs.index(input)
      return "Invalid direction!"
    end
    dir = dirs[t_dirs.index(input)]
    if @shots < 1
      return "You don't have any more shots! Go to base and type 'recharge' to fill up."
    end
    
    shot = Lasertag::Shot.new self, dir
    shot.fire!
    return SUCCESS
  end
  
  def im_hit hitter
    broadcast_pr("imhit", "#{hitter.id}")
    @current_room = $arena_rooms.shuffle[0]
  end
end

class LaserBot < Character
  @@infohash = {
    :id=>"laserbot",
    :name=>"Laserbot",
    :shortdesc=>"This is what they call a 'laserbot'.",
    :longdesc=>"You see nothing special about Laserbot.",
    :m_ints=>{},
    :keywords=>["laserbot", "bot"],
    :inventory=>[],
    :current_room=>nil,
  }
  
  def bot_ai
    if shots <= 3
      path = hunt_traverse_new($base, current_room)
      path.each {|e| send e}
      i_do("recharge")
      sleep(0.5)
    else
      if rand < 0.3 and !$helpmode
        dirs = EXIT_NAME_LIST.clone.delete_if {|x| current_room.send(x) == "0"}
        send dirs.shuffle[0]
      else
        tar = target("all", :mode=>"g", :who=>"c")
        tar.delete(self)
        tar.delete_if {|x| x.kind_of? Lasertag::Shot }
        tar = tar[0]
        
        hunt_result = i_do("hunt #{tar.keywords[0]}")
        if !hunt_result =~ /is here!\z/
          send(hunt_result.values[1])
        end
      end
    end
    scan_result = i_do("scan").values[1]
    sleep(0.1)
    EXIT_NAME_LIST.each do |dir|
      if scan_result[dir][:here]
        i_do("shoot #{dir}")
      end
    end
  end
end

module Lasertag
  
  class Shot < Character
    @@infohash = {
      :id=>"shot",
      :name=>"a laser shot",
      :shortdesc=>"Watch out! A laser shot!",
      :longdesc=>"How are you even looking at this?",
      :m_ints=>{},
      :keywords=>["shot"],
      :inventory=>[],
      :current_room=>$lasershot_spawn,
    }
    attr_accessor :sender, :direction, :status
    alias_method :old_initialize, :initialize
    def initialize(*argv)
      @status = "0"
      @sender = argv.shift
      @direction = argv.shift
      old_initialize
      @current_room = @sender.current_room
    end
    
    def fire!
      Thread.new do
        @sender.shots -= 1
        begin
          @status = 4
          loop do
            if @current_room.send(@direction) == "0"
              broadcast_pr("shoot", "shotdead")
              @current_room = $lasershot_spawn
              break
            elsif @status < 1
              broadcast_pr("shoot", "shotdisipate")
              @current_room = $lasershot_spawn
            else
              send(@direction)
              @status -= 1
              in_room = target("all", :mode=>"r", :who=>"c")
              broadcast_pr("shoot", "shotinroom")
              if (in_room != [self]) and 
                 (rand < (0.95)*(@status/4.0)) and 
                 (@current_room != $lasershot_spawn) and 
                 !in_room[1].kind_of? Lasertag::Shot
                
                hit = in_room[1]
                hit.im_hit sender
                cputs "You scored a hit on #{hit.name}!" if sender.id == $player.id
                sender.score ||= 0
                hit.score ||= 0
                sender.score += 10
                hit.score -= 5
                @current_room = $lasershot_spawn
                break
              end
            end
          end
        rescue Exception => e
          puts e
          puts e.backtrace
        end
      end
    end
  end
  
  def self.start
    $area = Area.new(
      :id=>"lasertag",
      :rooms=>[],
    )
    size=7
    maze=MazeGrid.new(size,size)
    area=maze.randomize
    
    $lasershot_spawn = Room.new(
      :id=>"laserspawn",
      :name=>"Here is where your shots spawn.",
      :color=>"P",
      :terrain=>"poop",
    )
    
    $arena_rooms = $area.rooms
    1.upto(size*size) do |num|
      $arena_rooms.push Room.new(
        :id=>"lasertag-#{num}",
        :name=>"In the Lasertag Arena",
        :color=>"M",
        :terrain=>"city",
      )
    end
    
    $area.rooms << ($base = Room.new(
      :id=>"base",
      :name=>"This is your base.",
      :color=>"G",
      :terrain=>"inside",
      :EExit=>Exit[:room=>$arena_rooms[0]],
    ))
    $base.m_ints[[/input/, /^recharge$/, /(.*?)/]]=:recharge
    def $base.recharge message = nil
      sender = Message.get_object_by_id(message[:sender])
      sender.broadcast_pr("recharge", "")
      sender.shots = 6
    end
    lbot = LaserBot.new
    lbot.current_room = $arena_rooms[3]#$arena_rooms[(rand*size*size).to_i]
    
    area.each_with_index do |el, index|
      key, value = el[0], el[1]
      ["NExit", "EExit", "SExit", "WExit", "UExit", "DExit"].each do |exit|
        $arena_rooms[size*key[0]+key[1]].send("#{exit}=", Exit[:room=>(value[exit] ? $arena_rooms[size*value[exit][0]+value[exit][1]] : "0")])
      end
    end
    
    $arena_rooms[0].WExit = Exit[:room=>$base]
    
    
    ObjectSpace.each_object(Character) do |char|
      char.instance_variable_set("@shots",6)
      char.instance_variable_set("@score",0)
    end
    
    $commands["hunt"]=:hunt
    $commands["shoot"]=:shoot
    
    $player.current_room = $base
    
    $player.display_info
    $prompt = "\"@G[@cShots left:@w \#{$player.shots}@w| @cScore:@w \#{$player.score}@G]>@d \""
    
    $bot_threads = []
    #Start the bot
    $bot_threads << Thread.new do
      begin
        loop do
          lbot.run_prog :bot_ai
          sleep 0.1
        end        
      rescue Exception => e
        puts e
        puts e.backtrace
      end
    end
    
  end
end

if __FILE__ == $0
  $helpmode = !!(ARGV.index("--h") or ARGV.index("--help"))
  ARGV.shift
  
  if $helpmode
    puts "Helpmode activated! The laserbot will not move"
    str = %q{
      
          @CWelcome to Lasertag.
          
  @DIn this text game, you must @GMOVE@D around and attempt to @GSHOOT@D
an automaton called a @GLASERBOT@D.

  You may @GMOVE@D by typing @GNORTH@D, @GEAST@D, @GSOUTH@D, or @GWEST@D,
but you may omit any amount of trailing letters as long as your command
does not clash with another.

  To @GSHOOT@D, you will type @GSHOOT <DIRECTION>@D. A direction may be any
compass direction or its first letter. Note that as you can abbreviate
@C"shoot"@D, you may not abbreviate it to @C"s"@D as it will instead move
you south. The recommended abbreviation is @C"sh"@D.

  @GSHOOT@Ding will send a pulse of energy in the direction specified. If the
pulse enters a room another character is in, the other character will be
@GHIT@D. This results in the character being placed in a random room in the
@GMAZE@D.

  Finally, you may @GSCAN@D your surroundings by typing just that.

  @WGood luck; the bot moves fast.@D
  
  (For map help, see @GHELP MAP@D)
}
    Pager.show_text(str.split(?\n).map {|x| Utility.pad(x,79)})
  end
  game = Game.new
  game.create
  
  $player.current_room = $base
  Lasertag.start
  game.start
  
end