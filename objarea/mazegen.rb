$invn2 = {"NExit" => "SExit", "SExit" => "NExit", "EExit" => "WExit", "WExit" => "EExit", "UExit" => "DExit", "DExit" => "UExit"}

class MazeGrid
	attr_accessor :row, :col
	def initialize( row, col )
		@row=row
		@col=col
	end
	
	def randomize
		maze={}
		place=[nil,[0,0]]
		path=[]
		
		((0..row-1).map { |y| (0..col-1).map { |x| [y,x] } }.flatten 1).each { |room| maze[room]={} }
		visited=[]
		del=false
		until visited.size==row*col
			while place
				where=[place[1][0],place[1][1]]
				if !visited.index where
					visited << where
				end
				path << place
				break if visited.size == row*col
				y=where[0]
				x=where[1]
				move_to =[["NExit", y > 0      ? visited.index([y-1,x]) ? nil : [y-1,x] : nil],
					        ["EExit", x < @col-1 ? visited.index([y,x+1]) ? nil : [y,x+1] : nil],
		              ["SExit", y < @row-1 ? visited.index([y+1,x]) ? nil : [y+1,x] : nil],
						      ["WExit", x > 0      ? visited.index([y,x-1]) ? nil : [y,x-1] : nil]]
				place=move_to.delete_if { |el| !el[1] }.shuffle[0]
				if place
					maze[where][place[0]], maze[place[1]][$invn2[place[0]]]=place[1], where
				end
			end
			path.delete_at(-1)
			place=path.shuffle!.pop
			del = !del
      visited.delete_at(0) if rand < 0.1
		end
    
		return maze
	end
end

class MazeGrid3D
	attr_accessor :row, :col, :depth, :grid
	def initialize( row, col, depth	 )
		@row=row
		@col=col
		@depth=depth
		@grid=(1..depth).map { (1..row).map { (1..col).map { [nil,nil,nil,nil] } } }
	end
	
	def randomize
		maze={}
		place=[nil,[0,0,0]]
		visited=[]
		(0..depth-1).map do |z| 
			(0..row-1).map do |y| 
				(0..col-1).map do |x| 
					[z,y,x]
				end 
			end
		end.flatten(2).each do
			|room| maze[room]={} 
		end
		until visited.size  >= row*col*depth
			until !place
				where=[place[1][0],place[1][1],place[1][2]]
				visited << where
				break if visited.length == row*col*depth
				z=where[0]
				y=where[1]
				x=where[2]
				move_to =[["NExit", y > 0 ? visited.index([z,y-1,x]) ? nil : [z,y-1,x] : nil],
						  ["EExit", x < @col-1 ? visited.index([z,y,x+1]) ? nil : [z,y,x+1] : nil],
						  ["SExit", y < @row-1 ? visited.index([z,y+1,x]) ? nil : [z,y+1,x] : nil],
						  ["WExit", x > 0 ? visited.index([z,y,x-1]) ? nil : [z,y,x-1] : nil],
						  ["UExit", z < @depth-1 ? visited.index([z+1,y,x]) ? nil : [z+1,y,x] : nil],
						  ["DExit", z > 0 ? visited.index([z-1,y,x]) ? nil : [z-1,y,x] : nil],]
				place=move_to.delete_if { |el| !el[1] }.shuffle[0]
				maze[where][place[0]], maze[place[1]][$invn2[place[0]]]=place[1], where if place
			end	
			place=[nil,visited.shuffle[0]]
		end
		return maze
	end
end