# Task Master: Full-Stack Task Management App

This project was built using **Track A** with the following details:
- **Frontend:** Flutter & Dart.
- **Backend:** Python (FastAPI, Flask, or Django).
- **Database:** SQLite or PostgreSQL.
- **Requirement:** Connect the Flutter app to your Python REST API.

---

A functional, visually polished Task Management application built with **Flutter** (Frontend) and **FastAPI** (Backend).

## 🚀 Key Features

*   **Full CRUD:** Create, Read, Update, and Delete tasks seamlessly.
*   **Intelligent Dependencies:** Tasks can be "Blocked By" another task. Blocked tasks are visually greyed out and disabled until their dependency is marked as "Done".
*   **Draft Persistence:** Never lose your work! Typed text in the creation screen is automatically saved and restored using `SharedPreferences`.
*   **Simulated Real-World Latency:** A 2-second delay is implemented on all Create/Update operations to demonstrate elegant loading states and double-tap prevention.
*   **Search & Filter:** Search tasks by title and filter the list by status (To-Do, In Progress, Done).
*   **Premium UI:** Modern Teal-themed interface with Material 3, rounded cards, and colorful status badges.

---

## 🛠️ Technology Stack

*   **Frontend:** Flutter (Dart) with Provider for state management.
*   **Backend:** Python (FastAPI) with SQLAlchemy ORM.
*   **Database:** SQLite.

---

## ⚙️ Setup and Running

### 1. Backend Setup
The backend handles the data logic and artificial delays.

```bash
cd backend
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn sqlalchemy pydantic

# Start the server
uvicorn main:app --reload
```
*The backend will run at `http://127.0.0.1:8000`.*

### 2. Frontend Setup
The frontend is optimized for Web (Chrome) and Android (Emulator).

**Note for Android Emulators:** The app is configured to use `10.0.2.2` to communicate with the host machine's localhost.

```bash
cd frontend
# Install dependencies
flutter pub get

# Run the app
# For Chrome:
flutter run -d chrome

# For Android Emulator (e.g., Pixel 9 Pro):
flutter run
```

---

## 📂 Project Structure
```text
task_manager/
├── backend/          # FastAPI server, SQLite db, and logic
├── frontend/         # Flutter application source code
└── README.md         # This file
```
