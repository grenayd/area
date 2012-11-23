class Area < GameObject
  attr_accessor :id, :rooms, :default_color, :default_terrain

  def initialize infohash
    @default_color = (infohash[:default_color] or "Y")
    @default_terrain = (infohash[:default_terrain] or "Inside")
    @rooms = []
    if infohash[:rooms]
      infohash[:rooms].each do |r|
        @rooms << r
        r.color = (r.color or @default_color)
        r.terrain = (r.terrain or @default_terrain)
      end
    end
    @id = infohash[:id]
  end
end

class Exit
  attr_accessor :hidden, :door, :closed, :room
  def initialize infohash={:room => "0", :hidden=>false, :door=>false}
    @hidden = infohash[:hidden]
    @door = infohash[:door]
    @room = infohash[:room]
  end
  
  def to_room
    return "0" if @room == "0"
    return eval @room rescue @room
  end

  def self.[] *argv
    new(*argv)
  end
end

class Room < GameObject
  include InanimateObject
  include ObjectContainer
  attr_accessor :NExit, :EExit, :SExit, :WExit, :UExit, :DExit, :color, :terrain

  def initialize infohash
    super(infohash)
    @inventory = (infohash[:inventory] or [])
    @NExit = (infohash[:NExit] or Exit[])
    @EExit = (infohash[:EExit] or Exit[])
    @SExit = (infohash[:SExit] or Exit[])
    @WExit = (infohash[:WExit] or Exit[])
    @UExit = (infohash[:UExit] or Exit[])
    @DExit = (infohash[:DExit] or Exit[])
    @color = infohash[:color]
    @terrain = (infohash[:terrain] or "inside")
  end
  
  def east;  @EExit.to_room  end
  def west;  @WExit.to_room  end
  def south; @SExit.to_room  end
  def north; @NExit.to_room  end
  def up;    @UExit.to_room  end
  def down;  @DExit.to_room  end

  def keywords; ["floor", "room", "ground"]; end

  def current_room(*argv); self; end
  
  def container; true; end
end