module ObjectContainer
  include Thing
  attr_accessor :inventory

  def << item
    @inventory << item
    self
  end

  def remove item
    @inventory.delete item
    self
  end

  def index item
    return @inventory.index item
  end
  
  def format_inventory
    broadcast_pr("check_inventory", "")
    return inventory.map.with_index {|x, i| "  @B- @d#{x.inspect}"} * "\n" + "@d"
  end
end
