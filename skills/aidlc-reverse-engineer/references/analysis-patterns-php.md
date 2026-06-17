# Analysis Patterns: PHP

**Config files**: `composer.json`, `composer.lock`, `.env`, `phpunit.xml`, `webpack.mix.js`/`vite.config.js`
**Entry points**: `public/index.php`, `artisan`, `bin/console`, `index.php`
**Frameworks**: Laravel (`routes/web.php`, `routes/api.php`, `app/Http/Controllers/`), Symfony (`config/routes.yaml`, `src/Controller/`), Slim, Lumen, CodeIgniter
**ORM/DB**: Eloquent (`Model`, `hasMany`, `belongsTo`, `$fillable`), Doctrine (`@ORM\Entity`, `@ORM\Column`), `database/migrations/`
**Route detection**: Laravel `Route::get/post`, Symfony `#[Route]` attributes, `routes/*.php`
**Business logic signals**: Service classes, Form Requests (Laravel validation), Events/Listeners, Jobs, Policies (authorization), Eloquent observers, enum-backed classes (PHP 8.1+)
**Test patterns**: PHPUnit (`@test`, `testMethod`), Pest (`it('...')`, `test('...')`), `tests/Feature/`, `tests/Unit/`, Laravel factories

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
