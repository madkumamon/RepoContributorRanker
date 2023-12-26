# RepoContributorRanker Application

This application calculates and displays a GitHub repository's top contributors based on pull requests, comments, and reviews. It allows users to save the score data to a PostgreSQL database and export it to a CSV file.

## Prerequisites

- PostgreSQL
- Ruby

## Installation

<<<<<<< Updated upstream
- Ruby is preferred.
- Possibility to choose any org/repo you wish.
- In-memory storage is perfectly fine, but we’d love to at least see a sketch of how you would design a schema around this problem and which storage technology you would choose, assuming that the team wants to store results long-term.
- Maybe you can show us some unit testing skills for written business logic.
=======
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
git clone [REPOSITORY_URL]
cd [REPOSITORY_DIRECTORY]
```

### Step 3: Install Required Gems

Install the required Ruby gems by running:

```bash
bundle install
```

## Usage

### Running the Scorecard

1. **Calculate and Display Scores**:
   To calculate and display the scores, run:

   ```bash
   ruby run_scorecard.rb
   ```

   Follow the prompts to enter the repository URL and other details.

2. **Save Scores to Database**:
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

>>>>>>> Stashed changes
<img width="923" alt="image" src="https://github.com/madkumamon/RepoContributorRanker/assets/893147/0995f9ad-864c-401f-bfd8-62f6cb0d87a8">
