# frozen_string_literal: true

require 'dotenv'
require 'octokit'
require 'uri'
require 'date'
require 'terminal-table'
require_relative 'progress_bar'

Dotenv.load

# ------------------------------------------------------------------------------
# First day solution without thread, class breaking, database solution and optimisations


# Developer Scorecard
# Dev team wants to track who did the most work each week for bragging rights. Using the GitHub API, create a maintainable API or interface that exposes a scorecard that shows the top contributors on a single GitHub repository in the past week. Assume the team uses GitHub flow and that the team only cares about pull request related events.
# Score guidelines:
# ● Pull Request: 12 points
# ● Pull Request Comment: 1 point
# ● Pull Request Review: 3 points
# Notes:
# ● Ruby is preferred.
# ● Possibility to choose any org/repo you wish.
# ● In-memory storage is perfectly fine, but we’d love to at least see a sketch of how you
# would design a schema around this problem and which storage technology you would
# choose, assuming that the team wants to store results long-term.
# ● Maybe you can show us some unit testing skills for written business logic

# ------------------------------------------------------------------------------

def parse_repository_name(url)
  URI(url).path.split('/')[1..2].join('/')
end

def fetch_contributor_scores(client, repository, start_datetime, progress_bar)
  contributor_scores = Hash.new(0)
  pull_requests = client.pull_requests(repository, state: 'all')
  
  progress_bar.total = pull_requests.size

  pull_requests.each do |pr|
    truncated_title = pr.title[0..49].ljust(50)
    progress_bar.increment(title: "Processing PR: #{truncated_title}")
    
    next if pr.created_at < start_datetime

    contributor_scores[pr.user.login] += @pull_request_points
    process_comments_and_reviews(client, repository, pr, start_datetime, contributor_scores)
  end

  progress_bar.finish
  contributor_scores
end

def process_comments_and_reviews(client, repository, pr, start_datetime, contributor_scores)
  process_comments(client, repository, pr, start_datetime, contributor_scores)
  process_reviews(client, repository, pr, start_datetime, contributor_scores)
end

def process_comments(client, repository, pr, start_datetime, scores)
  client.issue_comments(repository, pr.number).each do |comment|
    next if comment.created_at < start_datetime
    scores[comment.user.login] += @pull_request_comment_points
  end
end

def process_reviews(client, repository, pr, start_datetime, scores)
  client.pull_request_reviews(repository, pr.number).each do |review|
    next if review.submitted_at < start_datetime
    scores[review.user.login] += @pull_request_review_points
  end
end

def select_date_range
  puts "Select the date range for calculation:"
  puts "1. Last Week"
  puts "2. Last Month"
  puts "3. Last Year"
  choice = gets.chomp.to_i

  start_date = case choice
               when 1
                 Date.today - 7
               when 2
                 Date.today << 1
               when 3
                 Date.today << 12
               else
                 Date.today - 7
               end
  return start_date, choice
end

def select_points_values
  puts "Enter the points value for each action:"

  puts "Pull Request:"
  @pull_request_points = gets.chomp.to_i

  puts "Pull Request Comment:"
  @pull_request_comment_points = gets.chomp.to_i

  puts "Pull Request Review:"
  @pull_request_review_points = gets.chomp.to_i
end

def display_scores(scores)
  scores.sort_by { |_, score| -score }.first(10).each do |author, score|
    puts "#{author}: #{score} points"
  end
end

def display_table(repository_name, range, scores)
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

# ------------------------------------------------------------------------------

puts "Enter GitHub repository URL:"
repo_url = gets.chomp
repo_name = parse_repository_name(repo_url)

start_date, choice = select_date_range
start_datetime = start_date.to_time

select_points_values

# Determine the progress bar title based on the selected date range
date_range_str = case choice
                 when 1 then "Last Week"
                 when 2 then "Last Month"
                 when 3 then "Last Year"
                 else "Custom Range"
                 end

github_client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
progress_bar = ProgressBar.new(title: "Starting download...")
contributor_scores = fetch_contributor_scores(github_client, repo_name, start_datetime, progress_bar)

display_table(repo_name, date_range_str, contributor_scores)

