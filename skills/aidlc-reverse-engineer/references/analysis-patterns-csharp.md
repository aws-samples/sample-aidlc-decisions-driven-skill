# Analysis Patterns: C# / .NET

**Config files**: `*.csproj`, `*.sln`, `appsettings.json`, `appsettings.*.json`, `Program.cs`, `Startup.cs`, `Directory.Build.props`
**Entry points**: `Program.cs` (`Main` or top-level statements), `Startup.cs` (`Configure`, `ConfigureServices`)
**Frameworks**: ASP.NET Core (`[ApiController]`, `[HttpGet]`, `[HttpPost]`), Minimal APIs (`app.MapGet`), Blazor (`@page`), gRPC (`proto` + `ServiceBase`), MassTransit (message bus), Orleans (actors)
**ORM/DB**: Entity Framework Core (`DbContext`, `DbSet<T>`, `[Key]`, `[Required]`), Dapper, NHibernate, EF migrations (`Migrations/`)
**Route detection**: `[Route]`, `[HttpGet]`, `[HttpPost]` attributes, Minimal API `Map*` methods, `[ApiController]`
**Business logic signals**: Service classes with `I*Service` interfaces, FluentValidation (`AbstractValidator<T>`), MediatR handlers (`IRequestHandler`), domain events, `enum` state machines, specification pattern
**Test patterns**: xUnit (`[Fact]`, `[Theory]`), NUnit (`[Test]`, `[TestCase]`), MSTest, Moq (`Mock<T>`), `*.Tests` projects

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
