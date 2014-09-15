class Minesweeper
  def play

  end
end

class Board
  def initialize(dimensions = [9,9],bomb_number = 15)
    @dimensions = dimensions
    @bomb_number = bomb_number
    set_up
  end

  def set_up
    @rows = Array.new(@dimensions[1]) {"*" * @dimensions[0]}
    @bomb_locations = []

    until @bomb_locations.length == @bomb_number
      potential_location = [rand(@dimensions[1]),rand(@dimensions[0])]
      unless @bomb_locations.include?(potential_location)
        @bomb_locations << potential_location
      end
    end

    # @bomb_locations.each do |loc|
    #   @rows[loc[0]][loc[1 ]] = "b"
    # end

  end

end

class Tile

end