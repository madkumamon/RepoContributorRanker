# frozen_string_literal: true

require 'date'
require 'terminal-table'
require 'pry'
require_relative 'github_scorecard'
require_relative 'db_setup'

# This class is responsible for the user interface and uses Command pattern

class UserInterface
  def self.run(repository_url: nil, range: nil, points_values: nil)
    # Run the migration. Temporary solution until rails API is implemented
    Database.run_migration

    repository_name ||= ask_for_repository_url
    start_datetime, range_description = select_date_range(range)
    points_config = points_values || select_points_values

    # Invoke the GitHubScorecard class to fetch and calculate the scores
    scorecard = GitHubScorecard.new(repository_name, start_datetime, points_config)

    scores = scorecard.calculate_scores

    display_table(repository_name, range_description, scores)

    # Ask the user if they want to save the data
    if ask_to_save_data
      Database.save_scoreboard(repository_name, scores, points_config, range_description)
      puts "Data saved successfully."
    else
      puts "Data not saved."
    end
  end

  def self.ask_to_save_data
    puts "Do you want to save the data? (yes/no)"
    response = gets.chomp.downcase
    response == 'yes' || response == 'y'
  end

  def self.ask_for_repository_url
    puts "Enter GitHub repository URL:"
    parse_repository_name(gets.chomp)
  end

  def self.select_date_range(range_choice = nil)
    unless range_choice
      puts "Select the date range for calculation:"
      puts "1. Last Week"
      puts "2. Last Month"
      puts "3. Last Year"
      range_choice = gets.chomp.to_i
    end

    start_date, range_description = case range_choice
                                    when 1
                                      [Date.today - 7, "Last Week"]
                                    when 2
                                      [Date.today << 1, "Last Month"]
                                    when 3
                                      [Date.today << 12, "Last Year"]
                                    else
                                      [Date.today - 7, "Default Range (Last Week)"]
                                    end

    [start_date, range_description]
  end

  def self.select_points_values
    puts "Enter the points value for each action:"

    puts "Pull Request:"
    @pull_request_points = gets.chomp.to_i
  
    puts "Pull Request Comment:"
    @pull_request_comment_points = gets.chomp.to_i
  
    puts "Pull Request Review:"
    @pull_request_review_points = gets.chomp.to_i

    {
      pull_request: @pull_request_points || 12,
      pull_request_comment: @pull_request_comment_points || 1,
      pull_request_review: @pull_request_review_points || 3
    }
  end

  def self.display_table(repository_name, range, scores)
    # Create rows for the scores
    scores_rows = scores.sort_by { |_, score| -score }.map.with_index do |(nickname, points), index|
      star = index.zero? ? '★' : ''
      [nickname, "#{points} #{star}"]
    end

    # Create rows for the Points Config block
    points_config_rows = [
      ['Pull Request(PR) Points:', {:value => @pull_request_points.to_s, :alignment => :center}],
      ['PR Comment Points:', {:value => @pull_request_comment_points.to_s, :alignment => :center}],
      ['PR Review Points:', {:value => @pull_request_review_points.to_s, :alignment => :center}]
    ]

    # Create rows for the Repository Name and Range block
    info_rows = [
      ['Repository Name:', {:value => repository_name, :alignment => :center}],
      ['Range:', {:value => range, :alignment => :center}]
    ]

    # Create the "Score Board" table
    score_board_table = Terminal::Table.new do |t|
      t.title = 'Score Board'
      t.headings = ['Nickname', 'Points']
      t.rows = [*scores_rows]
      t.style = {
        width: 80,
        border_x: '=',
        border_i: 'x',
        padding_left: 1,
        padding_right: 1,
        alignment: :center
      }
    end

    # Create the "Configuration" table
    points_config_table = Terminal::Table.new do |t|
      t.title = 'Configuration'
      t.rows = [*points_config_rows, *info_rows]
      t.style = {
        width: 80,
        border_x: '=',
        border_i: 'x',
        padding_left: 1,
        padding_right: 1,
        alignment: :left
      }
    end

    # Print the "Score Board" table
    puts score_board_table
  
    # Print the "Points Config" table
    puts points_config_table
  end

  private

  def self.parse_repository_name(url)
    URI(url.strip).path.split('/')[1..2].join('/')
  rescue URI::InvalidURIError => e
    puts "Invalid repository URL: #{e.message}"
  end
end
