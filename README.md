# RepoContributorRanker

This application calculates and displays a GitHub repository's top contributors based on pull requests, comments, and reviews. It allows users to save the score data to a PostgreSQL database and export it to a CSV file.

## Prerequisites

- PostgreSQL
- Ruby

## Installation

### Step 1: Install Ruby using `asdf` and `brew`

1. **Install Homebrew**:
   If you don't have Homebrew installed, run the following command in your terminal:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install `asdf`**:
   Use Homebrew to install `asdf`, a tool for managing multiple runtime versions:

   ```bash
   brew install asdf
   ```

3. **Add Ruby Plugin**:
   After installing `asdf`, add the Ruby plugin:

   ```bash
   asdf plugin-add ruby
   ```

4. **Install Ruby**:
   Install your desired Ruby version (e.g., Ruby 3.0.0):

   ```bash
   asdf install ruby 3.0.0
   asdf global ruby 3.0.0
   ```

### Step 2: Clone the Repository

Clone this repository to your local machine:

```bash
gh repo clone madkumamon/RepoContributorRanker
cd RepoContributorRanker
```

### Step 3: Install Required Gems

Install the required Ruby gems by running:

```bash
bundle install
```

### Step 4: Setup your own .ENV variables

Install the required Ruby gems by running:

```bash
GITHUB_ACCESS_TOKEN='your_access_token'
PG_DB_NAME='database_name'
PG_DB_USER='database_user'
PG_DB_PASSWORD='database_password'
```

## Usage

### First Day Solution 

The first day solution is a one file script without optimization, threads, databases and class and functionality separation. I leave it as it is for comparison purposes.

```bash
ruby RepoContributorRanker.rb
```

### Running the Scorecard

1. **Calculate and Display Scores**:
   To calculate and display the scores, run:

   ```bash
   ruby run_scorecard.rb
   ```

   Follow the prompts to enter the repository URL and other details.

2. **Default values**:
   The default values when nothing was entered into prompts will be
   `Last Week` and `12, 1, 3` for points.   

3. **Save Scores to Database**:
   After displaying the scores, the application will ask if you want to save the data to the database. Enter `yes` to save.

### Exporting Data to CSV

To export the saved data to a CSV file, run:

```bash
ruby export_to_csv.rb
```

This command will create a CSV file with the scoreboard data.

### Database Setup and Migration

Run the following script to set up your database and run necessary migrations:

```bash
ruby db_setup.rb
```

## Contributing

Contributions to this project are welcome. Please ensure to follow the code style and add tests for new features.

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.

## Console Interface

<img width="923" alt="image" src="https://github.com/madkumamon/RepoContributorRanker/assets/893147/0995f9ad-864c-401f-bfd8-62f6cb0d87a8">
