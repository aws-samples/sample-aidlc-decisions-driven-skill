# Analysis Patterns: Java / Kotlin

**Config files**: `pom.xml`, `build.gradle`, `application.yml`, `application.properties`
**Entry points**: `*Application.java`, `public static void main`, `@SpringBootApplication`
**Frameworks**: Spring Boot (`@RestController`, `@Service`, `@Repository`), Quarkus (`@Path`, `@Inject`), Micronaut (`@Controller`, `@Singleton`), Ktor (`routing { get/post }`), Vert.x, Jakarta EE / Java EE (`@WebServlet`, `@EJB`)
**ORM/DB**: JPA/Hibernate (`@Entity`, `@Table`, `@Column`), MyBatis (`@Mapper`, XML mappers), jOOQ, Exposed (Kotlin), Flyway/Liquibase migrations, Spring Data (`JpaRepository`, `CrudRepository`)
**Route detection**: `@GetMapping`, `@PostMapping`, `@RequestMapping`, `@Path` (JAX-RS), Ktor `routing` DSL
**Business logic signals**: Service classes, `*Validator`, `*Calculator`, enum state machines, Bean Validation annotations
**Test patterns**: JUnit `@Test`, Mockito `@Mock`, `src/test/`, `*Test.java`, `*Spec.java`

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
