# 🛒 UniCart

**UniCart** is a collaborative grocery and budget-sharing Flutter application designed for students and roommates to manage grocery lists, track expenses, and optimize shopping experiences. Built with **Flutter** and **Firebase**, the app enables real-time list syncing, item tracking, group management, and future integrations like iOS Live Activities and budget split tools.

## ✨ Features

* Firebase Auth for secure login and registration.
* Group creation and management (create, join, invite, assign roles).
* Real-time grocery lists per group with items organized by category.
* Kroger API integration for auto-filling item data (brand, price, image, etc.).
* Dynamic theming (light/dark/system) with persistent user preference.
* **(Planned)** iOS Live Activities for showing grocery progress on the lock screen & Dynamic Island.
* **(Planned)** Budget and expense-splitting tabs for group payments.

## 🖌️ Design & Architecture

UniCart follows the **Model-View-Controller (MVC)** architecture and UI designed with clean Material-inspired principles.

* `controllers/` for user and auth logic.
* `providers/` with `ChangeNotifier` for reactive state.
* `services/` for Firestore and HTTP abstraction layers.
* `utils/` for UI helpers like avatars and theming.

## 🛠️ Getting Started

To run UniCart locally:

```bash
flutter pub get
flutter run
```

> Make sure you have Firebase configured and a `.env` file with Kroger credentials:

```
KROGER_CLIENT_ID=your_id
KROGER_CLIENT_SECRET=your_secret
```

## 🔗 Deployment

Currently in development phase. Final app will be deployed to both **iOS App Store** and **Google Play** after full feature integration.

## 📚 Resources

* [Flutter Documentation](https://docs.flutter.dev/)
* [Firebase for Flutter](https://firebase.flutter.dev/)
* [Kroger API Docs](https://developer.kroger.com/)
* [Material Design Guidelines](https://m3.material.io/)

## 📷 Screenshots
### Step 1: Create a Group and invite your roomies or family!
![User1Create](https://github.com/user-attachments/assets/58b2e25e-0651-4d17-b6f8-15ba48704f24)

### Step 2: Create a list for others to collaborate in.
![NewLists](https://github.com/user-attachments/assets/43a22749-bd4b-40ff-822d-e1915ae050f4)

### Step 3: Real time updates between members in the group.
![SharedLists](https://github.com/user-attachments/assets/e53f31e3-ee4a-431c-8021-6d17d1c32e86)

### Step 4: Add items from your nearest Kroger grocery store with accurate real time inventory updates.
![Items](https://github.com/user-attachments/assets/cdcf43c2-c94f-4c03-9604-a1722e555a13)
