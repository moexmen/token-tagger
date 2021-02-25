# Token Tagger

Attempt to streamline the process of assigning TT tokens to students so as to reduce manpower costs =P

Idea: Instead of scanning 3 (TT token, nric, contact number) items in SupplyAlly, this app will keep track of the students to be tagged, so it sufficies to just scan the TT token

# Setup
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
