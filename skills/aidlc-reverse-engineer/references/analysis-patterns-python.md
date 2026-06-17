# Analysis Patterns: Python

**Config files**: `pyproject.toml`, `setup.py`, `requirements.txt`, `Pipfile`, `poetry.lock`
**Entry points**: `main.py`, `app.py`, `manage.py`, `wsgi.py`, `asgi.py`, `__main__.py`
**Frameworks**: Django (`urls.py`, `views.py`, `models.py`), FastAPI (`@app.get`, `@router`), Flask (`@app.route`), Starlette, Litestar, Tornado (`RequestHandler`), aiohttp
**ORM/DB**: Django ORM (`models.Model`), SQLAlchemy (`Base`, `Column`), Alembic (`versions/`), Tortoise ORM, Peewee, SQLModel, Beanie (MongoDB), Motor (async MongoDB)
**Route detection**: Django `urlpatterns`, FastAPI/Flask/Litestar decorators, file-based routing
**Business logic signals**: Service modules, `validators.py`, `rules.py`, dataclasses with methods, Pydantic models with validators
**Test patterns**: pytest `test_*.py`, `conftest.py`, Django `TestCase`

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
