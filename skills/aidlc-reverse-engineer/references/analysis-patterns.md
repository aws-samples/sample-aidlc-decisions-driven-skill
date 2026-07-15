# Analysis Patterns — Index

Load ONLY the file matching the detected primary language. Do NOT load multiple files.

| Detected Language | File to Load |
|---|---|
| TypeScript, JavaScript, Node.js | `analysis-patterns-typescript.md` |
| Python | `analysis-patterns-python.md` |
| Java, Kotlin | `analysis-patterns-java.md` |
| Go | `analysis-patterns-go.md` |
| Rust | `analysis-patterns-rust.md` |
| C#, .NET, F# | `analysis-patterns-csharp.md` |
| Ruby | `analysis-patterns-ruby.md` |
| PHP | `analysis-patterns-php.md` |
| RPG, RPG ILE, COBOL/400, CL, DDS (IBM i / AS400) | `analysis-patterns-rpg-as400.md` |
| All others (Swift, Scala, Elixir, C/C++, Haskell, Perl, Clojure, z/OS COBOL, etc.) | `analysis-patterns-other.md` |

All files are at `{REFERENCES_DIR}/`.

**IMPORTANT**: Read only ONE file based on the primary language detected during Scan & Map. If the project is polyglot, read the file for the dominant backend language.
