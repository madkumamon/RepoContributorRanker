# frozen_string_literal: true

class ProgressBar
  def initialize(title: "Processing", total: nil)
    @title = title
    @total_items = total
    @processed_items = 0
    @bar_length = 30
  end

  def total=(total)
    @total_items = total
  end

  def increment(title: nil)
    @processed_items += 1
    @title = title if title
    print_progress
  end

  def print_progress
    if @total_items.zero?
      puts "No items to process."
    else
      percent = (@processed_items.to_f / @total_items.to_f * 100).round(1)
      complete_size = (@processed_items.to_f / @total_items.to_f * @bar_length).round
      incomplete_size = @bar_length - complete_size

      fixed_length_title = @title.ljust(50) # Ensure title is exactly 50 chars
      bar = "\u{2588}" * complete_size + "\u{2591}" * incomplete_size
      print "\r#{fixed_length_title} |#{bar}| #{percent}% (#{@processed_items}/#{@total_items})"
      STDOUT.flush
    end
  end

  def finish
    @current = @total
    print_progress
    puts # Move to the next line
  end
end