# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* Testing Notes

## Setup database

I used pgAdmin to connect to the database and create a fleet-management-test user in the postgresql database with all privileges.

The command:

```sh
RAILS_ENV=test ./bin/rails dd:setup
```

creates the test database. And I also had a test specific environment file named:
**.env.test** with test specific variables like the database name and password.

