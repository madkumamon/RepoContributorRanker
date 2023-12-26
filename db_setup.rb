# frozen_string_literal: true

require 'pg'
require 'json'
require 'csv'
require 'pry'
require 'dotenv'
Dotenv.load

class Database
  def self.connect
    PG.connect(dbname: ENV['PG_DB_NAME'], user: ENV['PG_DB_USER'], password: ENV['PG_DB_PASSWORD'])
  end

  def self.export_to_csv(filename)
    conn = connect
    begin
      result = conn.exec("SELECT * FROM scoreboards;")
      CSV.open(filename, "w") do |csv|
        csv << result.fields  # Adds the column names as the first row
        result.each do |row|
          csv << row.values
        end
      end
      puts "Data exported to #{filename}"
    rescue PG::Error => e
      puts "An error occurred while exporting to CSV: #{e.message}"
    ensure
      conn&.close
    end
  end

  def self.save_scoreboard(repository_name, score_data, config_data, score_range)
    conn = connect
    conn.transaction do |conn|
      conn.exec_params(
        "INSERT INTO scoreboards (repository_name, score_data, config_data, score_range, created_at, updated_at) VALUES ($1, $2, $3, $4, NOW(), NOW())",
        [repository_name, score_data.to_json, config_data.to_json, score_range]
      )
    end
  rescue PG::Error => e
    puts "Database transaction failed: #{e.message}"
  ensure
    conn&.close
  end

  def self.run_migration
    conn = connect
    begin
      # Check if the 'scoreboards' table exists
      result = conn.exec("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'scoreboards');")
      table_exists = result.first['exists'] == 't'

      # Create the table if it does not exist
      unless table_exists
        conn.exec <<-SQL
          CREATE TABLE scoreboards (
            id SERIAL PRIMARY KEY,
            repository_name VARCHAR(255),
            score_data JSONB,
            config_data JSONB,
            score_range VARCHAR(255),
            created_at TIMESTAMP NOT NULL,
            updated_at TIMESTAMP NOT NULL
          );
        SQL
        puts "Table 'scoreboards' created."
      else
        puts "Table 'scoreboards' already exists."
      end
    rescue PG::Error => e
      puts "An error occurred while running the migration: #{e.message}"
    ensure
      conn&.close
    end
  end
end