# Pokedex CLI

<div align="center">

[![Go Version](https://img.shields.io/badge/Go-1.27+-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://go.dev/)
[![PokeAPI](https://img.shields.io/badge/PokeAPI-v2-EF5350?style=for-the-badge&logo=pokemon&logoColor=white)](https://pokeapi.co/)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/CFMVCarlos/pokedexcli)
[![Curriculum](https://img.shields.io/badge/Boot.dev-Backend%20Track-805AD5?style=for-the-badge)](https://boot.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

<br />

**An interactive command-line Pokédex REPL built with idiomatic Go, featuring thread-safe TTL caching, animated CLI spinners, and zero-dependency ANSI styling.**

<br />

[Features](#-features) • [Installation](#-installation) • [Usage & Commands](#-usage-and-commands) • [Architecture](#-project-architecture) • [Testing](#-testing--verification)

</div>

---

## ⚡ Features

- 🎮 **Interactive REPL Loop**: Fast, intuitive command prompt with input sanitization, dynamic command registry, and error handling.
- ⏳ **Animated CLI Spinner**: Responsive terminal spinner providing instant visual feedback during async PokeAPI network calls.
- 🎨 **Zero-Dependency ANSI Colors**: Vibrant terminal color styling for prompts, encounter types, successful catches, and escapes (respects `NO_COLOR`).
- 💾 **Thread-Safe Repository Persistence**: Automatically stores caught Pokémon into `pokedex.json` via mutex-protected (`sync.RWMutex`) repository layer with manual `save` and `load` support.
- 🗺️ **World & Area Navigation**: Paginated exploration of Pokémon location areas (`map` / `mapb`).
- 🔍 **Area Exploration**: Discovers all Pokémon native to a specific location area (`explore`).
- 🎯 **Catch Mechanics**: Dynamic catch probability calculated against Pokémon `base_experience` (`catch`).
- 📊 **Detailed Inspection**: View captured Pokémon attributes, including height, weight, base stats, and elemental types (`inspect`).
- 📖 **Pokédex Ledger**: Real-time inventory tracking of all captured Pokémon (`pokedex`).
- 👋 **Pokémon Release**: Releases captured Pokémon back into the wild (`release`).
- 📈 **Trainer Summary**: Detailed analytics including total caught, heaviest, tallest, favorite type, and type distribution (`summary`).
- 🏷️ **Elemental Type Filter**: Filter caught Pokémon collection by specific elemental types (`filter`).
- ⚡ **Concurrent In-Memory Cache**: Custom `pokecache` package with background goroutine reaping based on configurable TTL intervals to avoid redundant HTTP requests.

---

## 🚀 Installation

### Prerequisites

- [Go](https://go.dev/dl/) **1.22+** (tested with Go 1.27)
- `git`

### Clone and Run

```bash
# Clone the repository
git clone https://github.com/CFMVCarlos/pokedexcli.git
cd pokedexcli

# Run directly
go run .

# Or build the binary executable
go build -o pokedexcli
./pokedexcli
```

---

## 🕹️ Usage and Commands

When launched, the program starts the `Pokedex > ` interactive prompt.

| Command | Arguments | Description | Example |
| :--- | :--- | :--- | :--- |
| `help` | _None_ | Displays the command menu and descriptions | `help` |
| `exit` | _None_ | Closes the Pokédex and terminates the program | `exit` |
| `map` | _None_ | Displays the next 20 location areas from PokeAPI | `map` |
| `mapb` | _None_ | Displays the previous 20 location areas | `mapb` |
| `explore` | `<area_name>` | Lists all Pokémon available in the given location area | `explore pastoria-city-area` |
| `catch` | `<pokemon_name>` | Attempts to catch a Pokémon and adds it to your Pokédex | `catch pikachu` |
| `inspect` | `<pokemon_name>` | Displays stats, dimensions, and types of a caught Pokémon | `inspect pikachu` |
| `pokedex` | _None_ | Prints a list of all caught Pokémon in your Pokédex | `pokedex` |
| `release` | `<pokemon_name>` | Releases a caught Pokémon back into the wild | `release pikachu` |
| `summary` | _None_ | Displays trainer stats, records, and type breakdown | `summary` |
| `filter` | `<type_name>` | Lists all caught Pokémon matching the specified type | `filter water` |
| `save` | _None_ | Manually saves the Pokédex to disk | `save` |
| `load` | _None_ | Manually reloads the Pokédex from disk | `load` |

### Example Session

```text
Welcome to the Pokedex!
Pokedex > map
canalave-city-area
eterna-city-area
pastoria-city-area
...
Pokedex > explore pastoria-city-area
⠋ Exploring pastoria-city-area...
Found Pokemon in pastoria-city-area:
 - tentacool
 - tentacruel
 - gyarados
 - remoraid

Pokedex > catch remoraid
⠋ Locating remoraid...
Throwing a Pokeball at remoraid...
remoraid was caught!
You may now inspect it with the inspect command.

Pokedex > inspect remoraid
Name: remoraid
Height: 6
Weight: 120
Stats:
  -hp: 35
  -attack: 65
  -defense: 35
  -special-attack: 65
  -special-defense: 35
  -speed: 65
Types:
  - water

Pokedex > summary
--- Trainer Summary ---
Total Pokémon caught: 1
Heaviest Pokémon: remoraid (120)
Tallest Pokémon: remoraid (6)
Favorite Type: water (1)
Type Breakdown:
  - water: 1

Pokedex > filter water
Water Pokémon in your Pokédex:
 - remoraid

Pokedex > release remoraid
Bye bye, remoraid! remoraid was released back into the wild.

Pokedex > exit
Closing the Pokedex... Goodbye!
```

---

## 🏗️ Project Architecture

The codebase follows idiomatic Go package design, separating CLI orchestration, HTTP client communication, caching, persistence, and UI presentation:

```text
pokedexcli/
├── internal/
│   ├── cli/
│   │   ├── commands.go         # Command registry and execution callbacks
│   │   ├── commands_test.go    # Unit tests for CLI commands
│   │   ├── config.go           # CLI state, dependencies, and configuration
│   │   ├── repl.go             # Interactive REPL prompt scanner & loop
│   │   └── repl_test.go        # Unit tests for input sanitization & routing
│   ├── pokeapi/
│   │   ├── client.go           # PokeAPI HTTP client with integrated TTL cache
│   │   └── types.go            # Domain models (Pokemon, LocationArea, Encounters)
│   ├── pokecache/
│   │   ├── pokecache.go        # Thread-safe in-memory cache with goroutine reaper
│   │   └── pokecache_test.go   # Concurrency, data race, and TTL tests
│   ├── repository/
│   │   └── pokedex.go          # Mutex-protected JSON storage layer (Pokedex ledger)
│   └── ui/
│       ├── colors.go           # ANSI terminal styling (supports NO_COLOR)
│       ├── colors_test.go      # Tests for color formatting functions
│       └── spinner.go          # Asynchronous terminal spinner with goroutines
├── main.go                     # Entrypoint configuring dependencies and starting REPL
├── go.mod                      # Go module manifest
└── LICENSE                     # MIT License
```

### Technical Highlights

- **Hexagonal / Internal Package Architecture**: Clean boundaries prevent circular dependencies and allow isolated unit testing.
- **`pokecache.Cache`**: Uses `sync.RWMutex` to protect in-memory cache reads while background ticker goroutines reap expired entries.
- **`repository.Pokedex`**: Thread-safe persistence repository ensuring reliable JSON read/write operations without race conditions.
- **Zero External Dependencies**: Implemented entirely with the Go standard library (`net/http`, `sync`, `time`, `encoding/json`, `bufio`, `strings`, `math/rand`, `os`).

---

## 🧪 Testing & Verification

Run the full automated test suite:

```bash
# Run all unit tests
go test ./...

# Run tests with verbose output
go test -v ./...

# Run tests with the Go race detector enabled
go test -race ./...
```

All package tests pass with zero data races detected:
- ✅ `pokedexcli/internal/cli`: REPL word cleaning, routing, command dispatch.
- ✅ `pokedexcli/internal/pokecache`: Cache insertion, expiration reaping, concurrent reads/writes.
- ✅ `pokedexcli/internal/ui`: ANSI color codes, strip handling, and `NO_COLOR` environment support.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  <sub>Built as part of the <a href="https://boot.dev">Boot.dev</a> Backend Engineering curriculum by <a href="https://github.com/CFMVCarlos">Carlos Valente</a>. Pokémon data provided by <a href="https://pokeapi.co/">PokeAPI</a>.</sub>
</div>
