# ScrabbleBot

A high-performance desktop assistant for the Turkish word game **Kelimelik** (Scrabble-variant). ScrabbleBot analyzes the current board state, your letter rack, and bonus squares to instantly surface the highest-scoring legal moves — all powered by a custom Trie engine running inside a Dart Isolate.

---

## Features

| Screen | Description |
|---|---|
| **Dashboard** | Overview of session stats, recent games, and quick-start actions |
| **Game Board** | Interactive 15×15 board — enter tiles, rack, and bonus squares to trigger the solver |
| **Analytics** | Score distribution charts, letter frequency analysis, and move history |
| **Dictionary** | Browse and search the full Turkish word list (~60 k entries) |
| **Letter Swap** | Evaluates the expected value of swapping vs. playing your current rack |
| **Opponent Analysis** | Track opponent tendencies and predict high-risk board zones |
| **AI Chat** | Contextual hints and explanations powered by an in-app chat widget |
| **Settings** | Theme toggle (dark / light), font scale, language, and solver depth |

---

## Architecture

```
lib/
├── core/
│   ├── constants/      # Board layout, tile values, bonus maps
│   ├── theme/          # AppTheme + KColors
│   └── utils/          # Shared helpers
├── domain/
│   └── entities/       # BoardCell, GameMove (pure Dart, no Flutter deps)
├── engine/
│   ├── trie.dart       # O(L) prefix trie — replaces flat Set<String>
│   └── kelimelik_solver.dart  # Anchor-based move generator (runs in Isolate)
└── presentation/
    ├── providers/      # Riverpod state (game, navigation, theme)
    ├── screens/        # One file per route
    └── widgets/        # Reusable components (sidebar, title bar, AI chat…)
```

**State management:** Riverpod 2 (`flutter_riverpod` + `riverpod_annotation`)  
**Solver algorithm:** Anchor-detection → left-part extension → right-part extension, applied twice (horizontal + transposed for vertical). Complexity is proportional to rack size × anchor count, not the full board.  
**Dictionary:** Loaded once from `Assets/sozluk.txt` into the Trie at startup; word count is exposed via `KelimelikSolver.wordCount`.

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.1`
- Windows 10 / 11 (primary target; macOS and Linux configs also included)

### Install & Run

```bash
git clone https://github.com/YOUR_USERNAME/ScrabbleBot.git
cd ScrabbleBot/kelimelik_app

flutter pub get
flutter run -d windows
```

The window opens at **1400 × 900** (minimum **1100 × 700**) with a custom hidden title bar.

### Build Release

```bash
flutter build windows --release
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | Reactive state management |
| `window_manager` | Custom window size, title bar, and focus control |
| `google_fonts` | Typography |
| `fl_chart` | Analytics charts |
| `path_provider` / `shared_preferences` | Local persistence |
| `collection` | Utility extensions |

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

## 🛠️ **CUSTOMIZING THE FRAMEWORK**

You can add custom routes to the framework by using the `@app.route()` decorator. Here’s an example:

```python
@app.route("/new-endpoint", method="GET")
def new_endpoint():
    return {"message": "This is a new custom endpoint!"}
```

Add this function to the `minimal_rest_framework.py` file and restart the server to make the new endpoint available.

---

## 🔍 **EXAMPLE USAGE**

### Fetching Data (`GET /data`)

```bash
curl -X GET http://127.0.0.1:5000/data
```

**Response:**

```json
{
    "data": [1, 2, 3, 4, 5]
}
```

### Saving Information (`POST /info`)

```bash
curl -X POST http://127.0.0.1:5000/info
```

**Response:**

```json
{
    "status": "Information saved successfully!"
}
```

---

## 🛡️ **LICENSE**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🤝 **CONTRIBUTION**

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/ca1ik/Minimal-Rest-Api-Framework/issues).

1. **Fork the repository.**
2. **Create a feature branch:**

```bash
git checkout -b feature-name
```

3. **Commit your changes:**

```bash
git commit -m 'Add a new feature'
```

4. **Push to the branch:**

```bash
git push origin feature-name
```

5. **Open a pull request.**

---

## 🌐 **CONNECT**

- **GitHub:** [ca1ik](https://github.com/ca1ik)
- **Email:** [lalochesian@gmail.com](mailto:lalochesian@gmail.com)

---

## 📸 **SCREENSHOTS**

![Welcome Endpoint](https://i.ibb.co/9cx92gT/Welcome-Endpoint-Screenshot.png)

![Data Endpoint](https://i.ibb.co/DwFkYnZ/JSON-Response-Screenshot.png)

---

## 🔮 **ENHANCEMENTS**

### Purpose:
This project is designed for **small projects, quick prototyping,** and **learning Python fundamentals.**

### Roadmap:
- [ ] Add support for `PUT` and `DELETE` methods.

- [ ] Enable XML response format.

- [ ] Add multilingual support for localization.

### Support:
If you enjoy this project, consider starring it on GitHub or contributing to its development!

---

### 🎉 **THANK YOU FOR USING MINIMAL REST API FRAMEWORK!**

---
