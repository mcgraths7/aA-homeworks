# frozen_string_literal: true

require 'byebug'

# The Board class maintains the board state of the game of mancala, including
# the number of stones in each cup, and the names of the players
# (to know which points cup belongs to whom)
class Board
  attr_accessor :cups

  def initialize(name1, name2)
    @cups = Array.new(14) { Array.new(1) }
    @player1 = name1
    @player2 = name2
    place_stones
  end

  def place_stones
    @cups.each_index do |c_idx|
      points_cup_idx = [6, 13]
      cups[c_idx] = points_cup_idx.include?(c_idx) ? [] : %i[stone stone stone stone]
    end
    @cups
    # helper method to #initialize every non-store cup with four stones each
  end

  def valid_move?(start_pos)
    valid_start_pos = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    raise ArgumentError, 'Invalid starting cup' unless valid_start_pos.include?(start_pos)
    raise ArgumentError, 'Starting cup is empty' if @cups[start_pos].empty?
  end

  def make_move(start_pos, current_player_name)
    num_stones = @cups[start_pos].count
    @cups[start_pos] = []
    placement_indices = get_placement_indices(start_pos, num_stones, current_player_name)
    @cups.each_index do |c_idx|
      @cups[c_idx] << :stone if placement_indices.include?(c_idx)
    end
    render
    next_turn(placement_indices[-1])
  end

  # Helper method to determine which cups will get stones placed in them on a given turn
  def get_placement_indices(start_pos, num_stones, current_player_name)
    current_cup_idx = start_pos
    enemy_points_cup_idx = current_player_name == @player1 ? 13 : 6
    current_turn_place_stones(current_cup_idx, num_stones, enemy_points_cup_idx)
  end

  def next_turn(ending_cup_idx)
    points_cup_idx = [6, 13]
    if points_cup_idx.include?(ending_cup_idx)
      :prompt
    elsif @cups[ending_cup_idx].length == 1
      :switch
    else
      ending_cup_idx
    end
    # helper method to determine whether #make_move returns :switch, :prompt, or ending_cup_idx
  end

  def render
    print "      #{@cups[7..12].reverse.map(&:count)}      \n"
    puts "#{@cups[13].count} -------------------------- #{@cups[6].count}"
    print "      #{@cups.take(6).map(&:count)}      \n"
    puts ''
    puts ''
  end

  def one_side_empty?
    bottom_side_empty = side_empty?(0..5)
    top_side_empty = side_empty?(7..12)
    top_side_empty || bottom_side_empty ? true : false
  end

  def winner
    if @cups[6].length > @cups[13].length
      @player1
    elsif @cups[13].length > @cups[6].length
      @player2
    else
      :draw
    end
  end

  private

  def current_turn_place_stones(current_cup_idx, num_stones, enemy_points_cup_idx)
    placement_indices = []
    while num_stones.positive?
      current_cup_idx += 1
      current_cup_idx = 0 if current_cup_idx > 13
      unless current_cup_idx == enemy_points_cup_idx
        placement_indices << current_cup_idx
        num_stones -= 1
      end
    end
    placement_indices
  end

  def side_empty?(cup_range)
    cup_range.to_a.each do |c|
      return false unless @cups[c].empty?
    end
    true
  end
end
