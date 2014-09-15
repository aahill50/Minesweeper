require 'yaml'

class Minesweeper

  def initialize
    play
  end

  def play
    puts "Would you like to load a save file? (y/n)"
    answer = gets.chomp
    if answer == 'y'
      puts "What is the filename?"
      filename = gets.chomp
      load_file = File.open(filename).read
      board = YAML::load(load_file)
    elsif answer == 'n'

      puts "Choose board dimensions: x,y"
      dimensions = gets.chomp.split(",").map(&:to_i)

      puts
      print "Choose bomb number: "
      bomb_numb = Integer(gets.chomp)
      puts

      board = Board.new(dimensions, bomb_numb)

    end

    until board.over?
      board.draw
      choice = ""
      until choice == 'r' || choice == 'f' || choice == 's'
        puts "Type r to reveal, type f to flag or unflag"
        puts "Type s to save"
        choice = gets.chomp
      end

      if choice == 's'
        puts "Enter filename to save to"
        filename = gets.chomp
        File.open(filename,'w') {|file| file.write(board.to_yaml)}
      end



      coords = []
      until coords.length == 2
        puts "Choose coordinates: x,y"
        coords = gets.chomp.split(",").map(&:to_i)
        puts
      end

      tile = board.tiles[coords[0]][coords[1]]
      if tile.status == :bomb && choice == 'r'
        puts "You lose!"
        end_time = Time.now
        elapsed_time = end_time - board.start_time
        board.reveal_bomb(tile)
        board.draw
        puts "It took you #{elapsed_time} seconds"
        puts
        puts "BOOOMMMMMM!!!!!!!!!!!"
        return nil
      elsif tile.status == :revealed
        puts "Tile already revealed!"
      elsif tile.flagged && choice == 'r'
        puts "Tile is flagged!"
      elsif tile.flagged && choice == 'f'
        puts "Unflagging tile!"
        board.unflag(tile)
      elsif tile.status != :revealed && choice == 'f'
        board.flag(tile)
      else
        board.reveal(tile)
      end
    end
    end_time = Time.now
    elapsed_time = end_time - board.start_time
    board.draw
    puts "YOU WON!!!!!!!!!!!!"
    puts "It took you #{elapsed_time} seconds"
  end
end

class Board
  attr_reader :bomb_locations, :tiles, :start_time

  def initialize(dimensions = [9,9],bomb_number = 1)
    @dimensions = dimensions
    @bomb_number = bomb_number
    @start_time = Time.now
    board_set_up
    tile_set_up
  end

  def board_set_up
    @rows = Array.new(@dimensions[1]) {"*" * @dimensions[0]}
    @bomb_locations = []

    until @bomb_locations.length == @bomb_number
      potential_location = [rand(@dimensions[1]),rand(@dimensions[0])]
      unless @bomb_locations.include?(potential_location)
        @bomb_locations << potential_location
      end
    end
  end

  def tile_set_up
    @tiles = []

    @rows.each_with_index do |row, col_index|
      @tiles << []
      row.split("").each_index do |row_index|
        new_tile = Tile.new([row_index, col_index])
        if @bomb_locations.include?([row_index, col_index])
          new_tile.status = :bomb
        end
        @tiles.last << new_tile

        y, x = row_index, col_index

        if y-1 >= 0
          @tiles[x][y].set_neighbor(@tiles[x][y-1])
          @tiles[x][y-1].set_neighbor(@tiles[x][y])
          if x-1 >= 0
            @tiles[x][y].set_neighbor(@tiles[x-1][y-1])
            @tiles[x-1][y-1].set_neighbor(@tiles[x][y])
          end
        end
        if x-1 >= 0
          @tiles[x][y].set_neighbor(@tiles[x-1][y])
          @tiles[x-1][y].set_neighbor(@tiles[x][y])
          if y+1 < @dimensions[0]
            @tiles[x][y].set_neighbor(@tiles[x-1][y+1])
            @tiles[x-1][y+1].set_neighbor(@tiles[x][y])
          end
        end
      end
    end

    def over?
      reveal_count = 0

      @tiles.each do |tile_row|
        tile_row.each do |tile|
          if tile.status == :revealed
            reveal_count += 1
          end
        end
      end

      (@dimensions[0] * @dimensions[1]) - @bomb_number == reveal_count
    end
  end

  def reveal(tile)
    tile.status = :revealed
    bomb_count = tile.neighbor_bomb_count
    if bomb_count == 0
      @rows[tile.location[0]][tile.location[1]] = " "
      tile.neighbors.each do |neighbor|

        unless neighbor.status == :revealed || neighbor.status == :bomb
          unless neighbor.flagged
            bomb_count = neighbor.neighbor_bomb_count
            if bomb_count == 0
              reveal(neighbor)
            elsif bomb_count > 0
              neighbor.status = :revealed
              @rows[neighbor.location[0]][neighbor.location[1]] = "#{bomb_count}"
            end
          end
        end
      end
    else
      @rows[tile.location[0]][tile.location[1]] = "#{bomb_count}"
    end
  end

  def flag(tile)
    tile.flagged = true
    @rows[tile.location[0]][tile.location[1]] = "f"
  end

  def unflag(tile)
    tile.flagged = false
    @rows[tile.location[0]][tile.location[1]] = "*"
  end

  def reveal_bomb(tile)
    @rows[tile.location[0]][tile.location[1]] = "B"
  end

  def draw
    print "  "
    (0..@dimensions[0]-1).each {|num| print num % 10}
    print "  "
    puts
    puts "||" + "=" * @dimensions[0] + "||"
    @rows.each_with_index do |row, index|
      puts "||#{row}||#{index}"
    end
    puts "||" + "=" * @dimensions[0] + "||"
  end

end

class Tile
  attr_accessor :location, :status, :neighbors, :flagged

  def initialize(location, status = :neutral)
    @location = location
    @status = status
    @neighbors = []
    @flagged = false
  end

  def set_neighbor(tile)
    return nil if tile.nil?
    @neighbors << tile unless @neighbors.include?(tile)
  end

  def neighbor_bomb_count
    bomb_count = 0
    @neighbors.each do |neighbor|
      bomb_count += 1 if neighbor.status == :bomb
    end
    bomb_count
  end

  def inspect
    [@location,"#{@neighbors.count} n"]
  end
end