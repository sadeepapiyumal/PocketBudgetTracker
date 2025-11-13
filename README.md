# 💰 Pocket Budget Tracker

> *"Track smart. Spend wiser."*

Pocket Budget Tracker is a modern iOS application built with **SwiftUI**, **Core Data**, and **CoreML** to help users manage their personal finances.  
It allows users to record income and expenses, visualize spending trends through interactive charts, and predict future expenses using an integrated machine learning model.

---

## 🚀 Features

- ✅ **Expense & Income Tracking** — Add, edit, and delete financial transactions.
- 📊 **Analytics Dashboard** — Visualize spending with Swift Charts.
- 🧠 **AI-Powered Predictions** — Predict next month’s expenses using CoreML.
- 💾 **Offline Storage** — Persistent data via Core Data.
- 🧭 **Onboarding Flow** — 3-screen introduction with app logo and tagline.
- 🎨 **Clean SwiftUI Interface** — Modern and responsive design with light mode consistency.

---

## 🏗️ Tech Stack

| Technology | Purpose |
|-------------|----------|
| **SwiftUI** | Declarative user interface |
| **Core Data** | Local data persistence |
| **CoreML** | Machine learning model integration |
| **CreateML** | Model training (Tabular Regression) |
| **Swift Charts** | Data visualization |
| **Xcode** | IDE for iOS development |

---

## 📱 App Overview

### **Onboarding**
The app greets users with a simple 3-screen onboarding experience introducing the main features of Pocket Budget Tracker, along with the tagline:

> “Track smart. Spend wiser.”

### **Dashboard**
Displays total income, total expenses, balance, and AI-predicted next month’s expense.  
Includes a small version of the app logo at the top for brand consistency.

### **Transactions**
Users can add, edit, and delete transactions with details like title, amount, category, and date.

### **Analytics**
Charts summarize spending habits and trends for better decision-making.

---

## 🧠 Machine Learning Model

**Model Name:** `MonthlyExpensePredictor.mlmodel`

**Inputs:**
- `totalIncome` (Double)  
- `totalExpense` (Double)  
- `month` (Int)

**Output:**
- `nextMonthExpense` (Double)

**Trained With:**  
Apple’s *CreateML* using historical monthly expense data.

---

## 🧩 Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern.



SwiftUI Views (UI)
↓
ViewModel (Logic)
↓
Core Data & CoreML Models

## 🧑‍💻 Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/sadeepapiyumal/PocketBudgetTracker.git
Open the project in Xcode:

open PocketBudgetTracker.xcodeproj


Build and run the app on the simulator (⌘ + R).

🧭 Author
Sadeepa Piyumal
📧 sadeepapiyumal530@gmail.com
🌐 https://github.com/sadeepapiyumal
