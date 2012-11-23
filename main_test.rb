#WARNING: DEPRECATED!!!

require_relative "objectarea.rb"
cputs "Testing colors: @Rred @Bblue @Ggreen@D", "W"
game = Game.new
game.create
class Grape < Item
  @@infohash={
    :id=>"grape",
    :name=>"a grape",
    :shortdesc=>"Oh noes, it's a grape!",
    :longdesc=>"Oh noes, it's a grape!",
    :m_ints=>{},
    :gettable=>"true",
    :keywords=>["grape", "2012"],
  }
end

class GunnySack < Item
  @@infohash = {
    :id=>"gunny",
    :name=>"a gunny sack",
    :shortdesc=>"This sack is large.",
    :longdesc=>"This sack is very large.",
    :m_ints=>{},
    :gettable=>"true",
    :inventory=>[],
    :keywords=>["gunny", "sack", "gunnysack", "2012"],
  }
end


class Dog < Character
  @@infohash = {
    :id=>"dog",
    :name=>"a dog",
    :shortdesc=>"Oohh, so cute! A dog!",
    :longdesc=>"This is a cute dog.",
    :m_ints=>{},
    :keywords=>["dog"],
    :inventory=>[],
    :current_room=>nil,
  }
  
  def dogsayhi message = nil
    say "Hi.. oh no! I gotta run, bye!"
    north
    sleep 4
    south
    say "Hi, I decided to come back."
  end
  
  def dogpickup message = nil
    say "OOOOOO #{Message.get_object_by_id(message[:body], Item).name}!"
    i_do("get #{Message.get_object_by_id(message[:body], Item).keywords[0]}")
  end
  
  def doggiveall message = nil
    say "Ok!"
    i_do("give all #{Message.get_object_by_id(message[:sender], Character).keywords[0]}")
  end
  
  def dogscan message = nil
    i_do("scan")
    
    incur_lag(3)
  end
end

grape = Grape.new
gs=GunnySack.new
gs << grape


room1=Room.new(
  :id=>"room1",
  :name=>"Room One",
  :shortdesc=>"This is Room One",
  :longdesc=>"This is Room One",
  :m_ints=>{},
  :inventory=>[]
)
room2=Room.new(
  :id=>"room2",
  :name=>"Room Two",
  :shortdesc=>"This is Room Two",
  :longdesc=>"This is Room Two",
  :m_ints=>{},
  :inventory=>[]
)
room3=Room.new(
  :id=>"room3",
  :name=>"Room Three",
  :shortdesc=>"This is Room Three",
  :longdesc=>"This is Room Three",
  :m_ints=>{},
  :inventory=>[]
)
def connect(mode, r1, r2)
  case mode.downcase
    when "ns"
      r1.NExit = Exit[:room=>r2]
      r2.SExit = Exit[:room=>r1]
    when "ew"
      r1.EExit = Exit[:room=>r2]
      r2.WExit = Exit[:room=>r1]
  end
end
connect("ns", room1, room2) 
connect("ew", room1, room3) 

$area=Area.new(
  :id=>"objects",
  :rooms=>[room1,room2,room3],
)
$player.current_room=room1
$player << gs
room1 << Grape.new
dog = Dog.new
dog.current_room=room1
dog.m_ints[[/say/, /hi/, /(.*?)/]] = :dogsayhi
dog.m_ints[[/drop/, /(.*?)/, /(.*?)/]] = :dogpickup
dog.m_ints[[/say/, /^give it all$/i, /(.*?)/]] = :doggiveall
dog.m_ints[[/say/, /^scan$/i, /(.*?)/]] = :dogscan

#require 'pry'
#binding.pry
