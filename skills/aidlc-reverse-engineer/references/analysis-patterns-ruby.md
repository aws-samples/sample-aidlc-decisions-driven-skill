# Analysis Patterns: Ruby

**Config files**: `Gemfile`, `Gemfile.lock`, `Rakefile`, `.ruby-version`, `config/`
**Entry points**: `config.ru`, `bin/rails`, `app.rb`, `config/application.rb`
**Frameworks**: Rails (`routes.rb`, `app/controllers/`, `app/models/`), Sinatra (`get '/'`, `post '/'`), Hanami, Grape (API), Roda
**ORM/DB**: ActiveRecord (`has_many`, `belongs_to`, `validates`), Sequel, ROM (Ruby Object Mapper), `db/migrate/`
**Route detection**: Rails `routes.rb` (`resources`, `get`, `post`), Sinatra/Grape DSL, Hanami routes
**Business logic signals**: Service objects (`app/services/`), validators, concerns, callbacks (`before_save`, `after_create`), state machines (AASM, Statesman), policy objects (Pundit)
**Test patterns**: RSpec (`describe/it/expect`), Minitest, `spec/`, `test/`, FactoryBot, fixtures

## Business Rule Extraction Heuristics

| Signal | What It Indicates |
|---|---|
| `if/switch` on status/state fields | State machine or workflow |
| Validation functions with error returns | Business validation rules |
| Functions named `calculate*`, `compute*`, `derive*` | Business calculations |
| Role/permission checks before operations | Authorization rules |
| Assertions or guard clauses at function start | Invariants |
| Cron/scheduler configurations | Scheduled business processes |
| Event handlers / message consumers | Event-driven business logic |
| Constants with business meaning (rates, limits, thresholds) | Business parameters |
| Enum types with domain names | Domain concepts / state definitions |
