# School management
## Description
This is a [Ruby on Rails](https://rubyonrails.org/) project that aims to create a management app for a school.
The implementation follows the [specifications file](/doc/Specifications.xlsx) translated into user [stories](https://github.com/users/Cyprien-png/projects/5) that will be used to evaluate the project.

## Getting Started
### Prerequisites
* _IDE used RubyMine 2024.3_
* ruby 3.4.1 [official doc](https://www.ruby-lang.org/en/)
* gem 3.6.2 [official doc](https://rubygems.org/)
* rails 8.0.1 [official doc](https://rubyonrails.org/)
* git version 2.44 [official doc](https://git-scm.com/)
* git-lfs 3.4.1 [official doc](https://git-lfs.github.com/)
* sqlite3 3.48 [official doc](https://www.sqlite.org/index.html)

### Database Information
The application uses SQLite3 as its database. Rails will automatically create three databases for you:
- Development: `school_management_development`
- Test: `school_management_test`
- Production: `school_management_production`

### Installation and Setup
Install Ruby dependencies
```shell
bundle install
```

Build CSS styles
```shell
rails tailwindcss:watch
```

Setup database
```shell
# Run migrations
rails db:migrate

# Seed the database with initial data
rails db:seed
```

Run development server
```shell
rails server
```

### Running Tests
Setup the DB for the tests
```shell
rails db:migrate RAILS_ENV=test
```

Run all tests:
```shell
rails test
```

Run specific test files:
```shell
rails test test/models/person_test.rb
```

Run tests with verbose output:
```shell
rails test -v
```

## Continuous Integration & Deployment
### CI Pipeline
The CI pipeline runs on GitHub Actions and performs the following checks on each pull request to the `develop` branch:
- Runs all tests in the test suite
- Verifies database migrations
- Ensures code quality and non-regression

## Collaborate
### Directory structure
_Follows the standard Rails directory structure_
```shell
├───app
│   ├───controllers
│   ├───models
│   ├───views
│   └───assets
├───config
├───db
│   ├───migrate
│   └───seeds.rb
├───doc                      # Documentation
│   └───Specifications.xlsx  # Project specifications
├───test
│   ├───models
│   ├───controllers
│   └───fixtures
└───public
```

### Workflow
* [Gitflow](https://www.atlassian.com/fr/git/tutorials/comparing-workflows/gitflow-workflow#:~:text=Gitflow%20est%20l'un%20des,les%20hotfix%20vers%20la%20production.)
* [How to commit](https://www.conventionalcommits.org/en/v1.0.0/)
* [How to use your workflow](https://nvie.com/posts/a-successful-git-branching-model/)
* Pull requests are open to merge in the develop branch.
* When creating a new feature, the branch name must be `feature/kebab-case`
