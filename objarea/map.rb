$mapdepth = 3
require_relative "terrains.rb"

def map_traverse_NW(start_room=$player.current_room, d_limit=$mapdepth, path=[], rooms={})
	spath=path.map {|x| x[0]}.join
	where = [-spath.scan(/w/).length,-spath.scan(/n/).length]
	return if -where[0] > d_limit or -where[1] > d_limit
	rooms[where]=start_room
  exits=["north", "west"].reject do |x|
    r_exit_sym = "#{x[0].capitalize}Exit".to_sym
    exit_sym = x.to_sym
    (start_room.send(exit_sym)=="0" or 
    start_room.send(exit_sym).to_s[0..6]=="SPWALL-" or 
    start_room.send(r_exit_sym).door =="closed")
  end
	exits.each {|ex|
		path << ex
		map_traverse_NW(start_room.send(ex.to_sym), d_limit, path, rooms)
		path.delete_at(-1)
	}
	return rooms
end

def map_traverse_NE(start_room=$player.current_room, d_limit=$mapdepth, path=[], rooms={})
	spath=path.map {|x| x[0]}.join
	where = [spath.scan(/e/).length,-spath.scan(/n/).length]
	return if where[0] > d_limit or -where[1] > d_limit
	rooms[where]=start_room
	exits=["north", "east"].reject do |x|
    r_exit_sym = "#{x[0].capitalize}Exit".to_sym
    exit_sym = x.to_sym
    (start_room.send(exit_sym)=="0" or 
    start_room.send(exit_sym).to_s[0..6]=="SPWALL-" or 
    start_room.send(r_exit_sym).door =="closed")
  end
	exits.each {|ex|
		path << ex
		map_traverse_NE(start_room.send(ex.to_sym), d_limit, path, rooms)
		path.delete_at(-1)
	}
	return rooms
end

def map_traverse_SW(start_room=$player.current_room, d_limit=$mapdepth, path=[], rooms={})
	spath=path.map {|x| x[0]}.join
	where = [-spath.scan(/w/).length,spath.scan(/s/).length]
	return if -where[0] > d_limit or where[1] > d_limit
	rooms[where]=start_room
	exits=["south", "west"].reject do |x|
    r_exit_sym = "#{x[0].capitalize}Exit".to_sym
    exit_sym = x.to_sym
    (start_room.send(exit_sym)=="0" or 
    start_room.send(exit_sym).to_s[0..6]=="SPWALL-" or 
    start_room.send(r_exit_sym).door =="closed")
  end
	exits.each {|ex|
		path << ex
		map_traverse_SW(start_room.send(ex.to_sym), d_limit, path, rooms)
		path.delete_at(-1)
	}
	return rooms
end

def map_traverse_SE(start_room=$player.current_room, d_limit=$mapdepth, path=[], rooms={})
	spath=path.map {|x| x[0]}.join
	where = [spath.scan(/e/).length,spath.scan(/s/).length]
	return if where[0] > d_limit or where[1] > d_limit
	rooms[where]=start_room
	exits=["south", "east"].reject do |x|
    r_exit_sym = "#{x[0].capitalize}Exit".to_sym
    exit_sym = x.to_sym
    (start_room.send(exit_sym)=="0" or 
    start_room.send(exit_sym).to_s[0..6]=="SPWALL-" or 
    start_room.send(r_exit_sym).door =="closed")
  end
	exits.each {|ex|
		path << ex
		map_traverse_SE(start_room.send(ex.to_sym), d_limit, path, rooms)
		path.delete_at(-1)
	}
	return rooms
end


class RoomGrid
	attr_accessor :size, :grid
	
	def initialize size
		@size=size
		@grid=(0..size-1).map{(0..size-1).map{{"NWall" => false, "EWall" => false, "WWall" => false, "SWall" => false, "UWall" => false, "DWall" => false, "Terrain" => "Inside"}}}
	end
	
	def [] x, y, option; @grid[y][x][option];end
	
	def []= x, y, option, val;@grid[y][x][option]=val;end
	
	def display rooms, c
		prettymap=(0..2*@size+1).map{ (" "*(4*@size+1)).split(//) }
		for x in 0..@size-1
			for y in 0..@size-1
				r_y=2*y+1
				r_x=4*x+2
				terr=$terrains[@grid[y][x]["Terrain"]]
				if rooms[[x-3,y-3]]
					prettymap[r_y][r_x-1]=terr[0]
					prettymap[r_y][r_x]=terr[1]
					prettymap[r_y][r_x+1]=terr[2]
					if @grid[y][x]["NWall"]
						prettymap[r_y-1][r_x-1]="-"
						prettymap[r_y-1][r_x]="-"
						prettymap[r_y-1][r_x+1]="-"
					elsif @grid[y][x]["Doors"].index(:NExit)
						prettymap[r_y-1][r_x-1]="-"
						prettymap[r_y-1][r_x]="+"
						prettymap[r_y-1][r_x+1]="-"
					end
					if @grid[y][x]["SWall"]
						prettymap[r_y+1][r_x-1]="-"
						prettymap[r_y+1][r_x]="-"
						prettymap[r_y+1][r_x+1]="-"
					elsif @grid[y][x]["Doors"].index(:SExit)
						prettymap[r_y+1][r_x-1]="-"
						prettymap[r_y+1][r_x]="+"
						prettymap[r_y+1][r_x+1]="-"
					end
					if @grid[y][x]["WWall"] or @grid[y][x]["Doors"].index(:WExit)
						prettymap[r_y][r_x-2]=(@grid[y][x]["Doors"].index(:WExit) ? "+" : "|")
					end
					if @grid[y][x]["EWall"] or @grid[y][x]["Doors"].index(:EExit)
						prettymap[r_y][r_x+2]=(@grid[y][x]["Doors"].index(:EExit) ? "+" : "|")
					end
					if !@grid[y][x]["UWall"] and !@grid[y][x]["HExits"].include?(:UExit)
						prettymap[r_y][r_x+1]= (@grid[y][x]["Doors"].index(:UExit) ? "@y>@d" : "@W>@d")
					end
					if !@grid[y][x]["DWall"] and !@grid[y][x]["HExits"].include?(:DExit)
						prettymap[r_y][r_x-1]= (@grid[y][x]["Doors"].index(:DExit) ? "@y<@d" : "@W<@d")
					end
				end
			end
		end
		#smooth out map: 
		(0..prettymap.size-1).each do |i_y|
			(0..prettymap[0].size+1).each do |i_x|
				if i_y < prettymap.size-1 and (prettymap[i_y-1][i_x] == "|" or prettymap[i_y-1][i_x] == "+") and prettymap[i_y][i_x]== " " and (prettymap[i_y+1][i_x]== "|" or prettymap[i_y+1][i_x]== "+") and i_x%4==0
					prettymap[i_y][i_x]= "#{i_x==-1 ? " " : ""}|"
					#gets
				end
				if (prettymap[i_y][i_x-1] == "-") and prettymap[i_y][i_x]== " " and prettymap[i_y][i_x+1]== "-"
					prettymap[i_y][i_x]= c+"-" if i_x!=0
				end
			end
		end
		(0..prettymap.size-1).each do |i_y|
			(0..prettymap[0].size+1).each do |i_x|
				if (prettymap[i_y][i_x]=="+" and i_y%2==0 or i_x%4==0) or (prettymap[i_y][i_x]=="|" and i_x%4==0)
					prettymap[i_y][i_x]=c+prettymap[i_y][i_x]+"@d"
				end
			end
		end
		$last_map=prettymap
		rsize=size/2
		prettymap[rsize*2+1][rsize*4+2]="@M\#@d"
		prettymap.each_with_index do |line,index|
			if index%2==0 
				prettymap[index]=prettymap[index].join.gsub(/\-/,c+'-@d').split(//)
			end
		end
		return prettymap
	end
end