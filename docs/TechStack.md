# ⚙️ Tech Stack — SNXW Finance

## 🎯 Overview

This document defines the official technologies used in SNXW Finance.

The goal is to keep the stack:

- Modern
- Simple
- Maintainable
- Scalable for future growth

---

# 📱 Frontend

## Flutter

Why Flutter:

- Single codebase for all platforms
- High performance UI
- Strong ecosystem
- Excellent for financial dashboards

Platforms target:

- Android (Primary MVP)
- iOS (Secondary MVP)
- Windows (Future)
- Linux (Future - important for SNXW Labs)
- Web (Later stage)

---

# 💻 Programming Language

## Dart

Why Dart:

- Native language for Flutter
- Fast compilation
- Null safety
- Clean syntax for scalable apps

---

# 🧠 State Management

## Riverpod

Why Riverpod:

- Scalable architecture
- Testable logic
- Works well with Clean Architecture
- Avoids tight UI coupling

---

# 🗄️ Local Database

## Drift (SQLite abstraction)

Why Drift:

- Type-safe SQL
- Strong Dart integration
- Offline-first support
- Ideal for financial records

Alternative rejected:

- Hive → too limited for complex queries

---

# 🏗️ Architecture

## Clean Architecture

We use Clean Architecture to ensure:

- Separation of concerns
- Easy testing
- Long-term scalability
- Clear domain logic

Layers:

- Presentation
- Application (Use Cases)
- Domain
- Data

---

# 🧩 Project Structure Style

## Feature-first modular design

Instead of grouping by type, we group by feature:

```
features/
 ├── income/
 ├── expenses/
 ├── debts/
 ├── dashboard/
```

Why:

- Easier scaling
- Better maintainability
- Matches real-world product teams

---

# 🎨 UI System

## Material Design 3

Why:

- Modern UI system
- Native Flutter support
- Adaptive components
- Clean financial dashboards

---

# 🔐 Data Strategy

## Offline First

SNXW Finance works without internet:

- Local storage as primary source
- No dependency on external APIs (MVP)
- Future sync layer optional

---

# 🧠 Future Intelligence Layer (Post-MVP)

Planned upgrades:

- Financial rule engine
- Smart recommendations
- Risk analysis system
- Cash flow predictions

Note: NOT part of MVP.

---

# 🧪 Testing Strategy (Future Phase)

- Unit tests (domain layer)
- Widget tests (UI layer)
- Integration tests (critical flows)

---

# 🚫 Explicitly NOT in MVP

- Banking API integrations
- AI/ML models
- Cloud sync
- Investment features
- Crypto features

We focus on **control and clarity first**.

---

# ⚡ Performance Philosophy

- Lightweight app
- Fast startup
- Minimal dependencies
- Efficient local queries

---

# 🧭 Final Goal of Tech Stack

To build a system that:

> "Feels simple for the user, but is powerful under the hood."

SNXW Finance should remain easy to extend without rewriting core logic.

---