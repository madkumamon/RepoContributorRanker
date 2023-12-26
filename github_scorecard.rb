# frozen_string_literal: true

require 'octokit'
require 'uri'
require 'dotenv'
require 'date'
require 'faraday'
require 'oj'
require 'parallel'
require 'pry'
require_relative 'progress_bar'
Dotenv.load

# Define and register the custom middleware
module FaradayMiddleware
  class OjParser < Faraday::Middleware
    def on_complete(env)
      if env.response_headers['content-type'].to_s.match?(/\bjson$/)
        env.body = Oj.load(env.body, mode: :compat) unless env.body.strip.empty?
      end
    end
  end
end

Faraday::Response.register_middleware(oj_parser: FaradayMiddleware::OjParser)

# Configure Octokit to use the custom OjParser middleware
Octokit.middleware = Faraday::RackBuilder.new do |builder|
  builder.use FaradayMiddleware::OjParser
  builder.adapter Faraday.default_adapter
end

class GitHubScorecard
  attr_reader :client, :repository, :start_datetime, :points_config

  def initialize(repository_name, start_datetime, points_config)
    @repository = repository_name
    @start_datetime = start_datetime.to_time
    @points_config = points_config
    @client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
  end

  def calculate_scores
    progress_bar = ProgressBar.new(title: "Starting download...", total: pull_requests.size)
    scores = Hash.new(0)  # Initialize scores with default value of 0
    mutex = Mutex.new
  
    Parallel.each(pull_requests, in_threads: 10) do |pr|
      begin
        next if pr.created_at < start_datetime
  
        truncated_title = pr.title[0..49].ljust(50)
        mutex.synchronize { progress_bar.increment(title: "Processing PR: #{truncated_title}") }
  
        local_scores = process_pr_related_activities(pr)
        mutex.synchronize do
          local_scores.each do |user, points|
            points ||= 0  # Ensure points is not nil
            scores[user] += points
          end
        end
      rescue Octokit::TooManyRequests => e
        puts "Rate limit exceeded: #{e.message}"
        break
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
      end
    end
  
    progress_bar.finish
    scores
  end  

  private

  def pull_requests
    @pull_requests ||= client.pull_requests(repository, state: 'all')
  rescue Octokit::Error => e
    puts "Error occurred while fetching pull requests: #{e.message}"
    []
  end

  def process_pr_related_activities(pr)
    local_scores = Hash.new(0)
  
    # Score for creating the pull request
    local_scores[pr.user.login] += points_config.fetch(:pull_request, 0)
  
    # Process comments and reviews
    local_scores.merge!(process_comments(pr)) { |_, a, b| a + b }
    local_scores.merge!(process_reviews(pr)) { |_, a, b| a + b }
  
    local_scores
  end
  
  def process_comments(pr)
    local_scores = Hash.new(0)
    
    issue_comments(pr.number).each do |comment|
      next if comment.created_at < start_datetime
      user = comment.user.login
      local_scores[user] += points_config.fetch(:pull_request_comment, 0)
    end
    
    local_scores
  rescue Octokit::Error => e
    puts "Error occurred while fetching issue comments: #{e.message}"
    local_scores
  end
  
  def process_reviews(pr)
    local_scores = Hash.new(0)
    
    pull_request_reviews(pr.number).each do |review|
      next if review.submitted_at < start_datetime
      user = review.user.login
      local_scores[user] += points_config.fetch(:pull_request_review, 0)
    end
    
    local_scores
  rescue Octokit::Error => e
    puts "Error occurred while fetching pull request reviews: #{e.message}"
    local_scores
  end

  def issue_comments(number)
    @issue_comments ||= {}
    @issue_comments[number] ||= client.issue_comments(repository, number, per_page: 100)
  rescue Octokit::Error => e
    puts "Error occurred while fetching issue comments: #{e.message}"
    []
  end

  def pull_request_reviews(number)
    @pull_request_reviews ||= {}
    @pull_request_reviews[number] ||= client.pull_request_reviews(repository, number, per_page: 100)
  rescue Octokit::Error => e
    puts "Error occurred while fetching pull request reviews: #{e.message}"
    []
  end
end