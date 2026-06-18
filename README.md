# 🌍 RabatLink — Super-App communautaire multi-services

**RabatLink** est une application mobile développée avec **Flutter + Firebase**, conçue pour centraliser les services urbains, la communication locale et les échanges commerciaux dans la ville de Rabat.

L’objectif du projet est de proposer une **super-app locale intelligente**, inspirée de modèles comme WeChat ou Grab, mais adaptée au contexte urbain marocain.

---

## 📱 Aperçu du projet

RabatLink connecte les habitants d’une même ville à travers :

* 💬 Chat communautaire par quartier
* 🛒 Marketplace locale (produits & services)
* 📦 Système de commandes simplifié
* 📅 Événements et bons plans locaux
* 👤 Gestion des profils utilisateurs et rôles

---

## 🎯 Objectifs du projet

### Objectif principal

Créer une plateforme unique regroupant communication, commerce local et services communautaires.

### Objectifs secondaires

* Centraliser les échanges entre habitants d’un même quartier
* Faciliter les transactions locales entre utilisateurs et commerçants
* Offrir une base évolutive vers une super-app nationale (MoroccoLink)

---

## 🧠 Concept

RabatLink repose sur une logique de **ville intelligente segmentée par quartiers** :

* Chaque quartier possède son espace de discussion
* Les commerçants peuvent publier des annonces
* Les utilisateurs interagissent via chat et marketplace
* Les événements locaux sont visibles en temps réel

---

## 🏗️ Architecture technique

### 🔧 Stack technologique

* **Flutter** (Frontend mobile multiplateforme)
* **Firebase Authentication** (gestion des utilisateurs)
* **Cloud Firestore** (base de données temps réel)
* **Firebase Cloud Messaging** (notifications)
* **Provider** (gestion d’état)

---

### 📂 Structure du projet

```bash
lib/
│
├── main.dart
├── providers/        # Gestion d’état (Auth, Chat, Products)
├── core/             # Thème & configuration globale
├── models/           # Structures de données
├── services/         # Firebase & logique métier
├── screens/          # Interfaces utilisateur
├── widgets/          # Composants réutilisables
└── utils/            # Constantes globales
```

---

## 🔐 Système d’authentification

* Authentification via Firebase (Email/Password)
* Attribution automatique de rôles :

  * 👤 User
  * 🏪 Commerçant
  * 🛠 Admin
* Sécurisation des routes sensibles (dashboard admin)

---

## 💬 Fonctionnalités principales

### 👤 Utilisateur

* Inscription / connexion
* Chat par quartier
* Chat privé
* Consultation marketplace
* Participation aux événements

### 🏪 Commerçant

* Publication de produits/services
* Gestion des commandes
* Interaction directe avec clients

### 🛠 Administrateur

* Gestion des utilisateurs
* Validation et modération
* Supervision globale de la plateforme

---

## 🛒 Marketplace

* Publication d’annonces (CRUD complet)
* Consultation des produits par catégorie
* Système de commande simplifié (sans paiement intégré)
* Chat lié aux produits

---

## 💬 Système de chat

* Chat public par quartier
* Messages en temps réel (Firestore)
* Conversations privées
* Chat lié aux produits (vendeur ↔ client)

---

## 📅 Événements

* Création et consultation d’événements locaux
* Diffusion dans les quartiers
* Partage dans les chats communautaires

---

## 🔥 Modèle de données (Firestore)

Collections principales :

* `users` → profils utilisateurs + rôles
* `products` → annonces marketplace
* `events` → événements locaux
* `public_chats` → chats par quartier
* `product_chats` → conversations privées

---

## 🎨 UI / Design

* Design moderne et minimaliste
* Couleurs principales :

  * Vert doux `#2F8D7B`
  * Orange brun `#C07B4A`
  * Blanc `#FFFFFF`
* Interface optimisée mobile-first

---

## 🚀 Installation du projet

### 1. Cloner le repo

```bash
git clone https://github.com/MERYEM-LABYAD/RabatLink.git
cd RabatLink
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configurer Firebase

* Ajouter `google-services.json` (Android)
* Ajouter `GoogleService-Info.plist` (iOS)
* Activer Authentication + Firestore

### 4. Lancer l’application

```bash
flutter run
```

---

## 📸 Captures d’écran

> (À ajouter : Home, Chat, Marketplace, Events, Admin Panel)

---

## 🧪 Tests

* Authentification utilisateur
* Chat temps réel
* CRUD marketplace
* Gestion des rôles
* Firestore integration

---

## 📈 Perspectives futures

* 💳 Paiement intégré (wallet local)
* 🤖 Recommandations intelligentes (IA)
* 🔔 Notifications avancées
* 🌍 Extension multi-ville (Casablanca, Marrakech…)
* ⭐ Système de notation et avis
* 🚕 Services urbains (transport, livraison)

---

## 👨‍🎓 Contexte académique

Projet réalisé dans le cadre du module **Développement Mobile (Flutter)**
Année universitaire : **2025 / 2026**

---

## 👩‍💻 Développeur

* Meryem Labyad

---

## 📄 Licence

Projet académique — utilisation éducative uniquement
