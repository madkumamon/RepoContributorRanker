# frozen_string_literal: true

require_relative 'db_setup'

# Filename for the CSV export
filename = "scoreboard_data_#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv"

Database.export_to_csv(filename)