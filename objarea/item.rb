class Item < GameObject
  include Thing
  include InanimateObject
  attr_accessor :gettable

  def self.inherited(sub)
    sub.send(:attr_accessor, :container)
    sub.send(:define_method, :initialize) do
      @infohash = Marshal.load(Marshal.dump(self.class.class_variable_get("@@infohash")))
      @name = @infohash[:name]
      @shortdesc = @infohash[:shortdesc]
      @longdesc = @infohash[:longdesc]
      @m_ints = (@infohash[:m_ints] or {})
      @gettable = @infohash[:gettable]
      @keywords = (@infohash[:keywords] or [])
      @hidden = (@infohash[:hidden] or false)
      if @infohash[:inventory]
        self.class.send(:include, ObjectContainer)
        self.class.send(:attr_accessor, :open)
        @inventory = (@infohash[:inventory] or [])
        @container = true
        @open = (@infohash[:open] or true)
      end
      
      if !sub.class_variable_defined?("@@instances")
        sub.class_variable_set("@@instances", [self])
      else
        tmp = sub.class_variable_get("@@instances")
        tmp.push self
        sub.class_variable_set("@@instances", tmp)
      end
      @id = "#{@infohash[:id]}-#{self.class.class_variable_get("@@instances").length}"
      
      @infohash = nil
    end
  end

  def current_room infohash={:allow_containers => true, :allow_closed_containers => true}
    ObjectSpace.each_object(ObjectContainer) do |container|
      if container.kind_of?(Room) and container.inventory.index(self)
        return container.id
      end
      if container.inventory.index(self) #
        if container.kind_of?(Character)
          return container.current_room
        end

        if container.kind_of?(Item) and container.container and infohash[:allow_containers]
          if !container.open
            return container.current_room if infohash[:allow_closed_containers]
          else
            return container.current_room
          end
        end
      end #
    end
  end
  nil
end