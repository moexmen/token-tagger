# Token Tagger

Attempt to streamline the process of assigning TT tokens to students so as to reduce manpower costs =P

Idea: Instead of scanning 3 (TT token, nric, contact number) items in SupplyAlly, this app will keep track of the students to be tagged, so it sufficies to just scan the TT token

## Setup
1. Copy `.env.example` to `.env` and set the variables accordingly.
1. Install gem dependencies
    - `bundle install`
1. `rails s` to start server

## Database
Make sure that an instance of postgres is running. An instance of postgres can be started in docker by running `docker-compose -f  docker-compose-local.yml up`

### Setup

1. Start fresh with a new database by running:
    ```
    rails db:setup
    ```

### Migrations

1. If you need to make changes to existing tables, add a new migration
    ```
    rails generate migration <migration_name>
    ```

2. Run the new migrations
    ```
    rails db:migrate
    ```

3. Update schema diagram

    ```
    make schema
    ```

## Operations

Load a single Excel file:

`bin/rails 'data:load[./27Feb5pm/S2-2-Fairfield\ Methodist\ Primary\ School\ \(HQ\).xlsx]'`

Load all Excel files in a directory:

`find ./27Feb5pm/ -mindepth 1 -type f -print0 | xargs -0 -I{} bin/rails 'data:load[{}]';`
