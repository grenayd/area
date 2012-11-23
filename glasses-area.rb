require_relative 'objectarea.rb'
area = {}
area[:house] ||= {}
area[:house] ||= {}
area[:house] ||= {}
area[:house] ||= {}
r_house_diningroo = area[:house][:diningroo];r_house_ente = area[:house][:ente];r_house_kitche = area[:house][:kitche];r_house_livingroo = area[:house][:livingroo];

house_diningroom.room = (area[:house][:diningroom.room] = Room.new({
:id=>"house_diningroom.room",:name=>"A cozy dining room",
:longdesc=>"In this cozy room is a small table and three chairs surrounding it. To your west is where the food that will be here comes from.",
:WExit=>Exit[:room=>house_kitchen],
:color=>"b",
:terrain=>"inside",
}))

house_enter.room = (area[:house][:enter.room] = Room.new({
:id=>"house_enter.room",:name=>"Entering a small house",
:longdesc=>"You have entered a small house.  To the east you see a modest living room and to the south there is a small kitchen. The aroma of food coming from there makes your mouth slightly water.",
:EExit=>Exit[:room=>house_livingroom],
:SExit=>Exit[:room=>house_kitchen],
:color=>"b",
:terrain=>"inside",
}))

house_kitchen.room = (area[:house][:kitchen.room] = Room.new({
:id=>"house_kitchen.room",:name=>"A small kitchen",
:longdesc=>"In this kitchen there is a stove with a pan on it. The food smells good. To your north is the enterance to this house and to your east is a cozy dining room.",
:EExit=>Exit[:room=>house_diningroom],
:NExit=>Exit[:room=>house_enter],
:color=>"b",
:terrain=>"inside",
}))

house_livingroom.room = (area[:house][:livingroom.room] = Room.new({
:id=>"house_livingroom.room",:name=>"A modest living room",
:longdesc=>"In this room there is a painting and a sofa. You can detect the faint aroma of food cooking. To your west is the room where you can exit the house.",
:WExit=>Exit[:room=>house_enter],
:color=>"b",
:terain=>"inside",
}))