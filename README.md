<img src="https://github.com/CodeOfNamanBhalani/Acadly/blob/main/AppIcons/appstore.png" width="220"/>



# Campus Companion - Student Academic Planner 📚

A comprehensive full-stack Flutter application designed to help students manage their academic life efficiently. Campus Companion provides an all-in-one solution for managing timetables, assignments, exams, notes, and staying updated with campus notices — all powered by a secure REST API backend with PostgreSQL database.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![REST API](https://img.shields.io/badge/REST_API-009688?style=for-the-badge&logo=fastapi&logoColor=white)

---

## 🏗️ Architecture

This application follows a **client-server architecture**:

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Flutter App   │ ──────► │    REST API     │ ──────► │   PostgreSQL    │
│   (Frontend)    │ ◄────── │    (Backend)    │ ◄────── │   (Database)    │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

- **Frontend**: Flutter mobile application with Provider state management
- **Backend**: RESTful API with JWT authentication
- **Database**: PostgreSQL for persistent data storage

---

## ✨ Features

### 🔐 Authentication & Security
- **User Registration** with secure password hashing
- **JWT Token-based Authentication** (Access & Refresh tokens)
- **Auto Token Refresh** on session expiry
- **Secure API Communication** with Bearer token headers
- **Persistent Login** using SharedPreferences

### 🏠 Dashboard
- **Personalized greeting** with the current date
- **Today's classes** at a glance
- **Upcoming assignments** with due dates
- **Exam countdown** for the next upcoming exam
- **Recent notices** from the notice board
- Quick navigation to all app sections

### 📅 Timetable Management
- View your weekly class schedule
- **Day-wise navigation** with an intuitive day selector
- Add, edit, and delete classes
- **Real-time sync** with cloud database
- Set class details including:
  - Subject name
  - Time slot (Start & End time)
  - Room/Location
  - Instructor name

### 📝 Assignment Tracker
- Keep track of all your assignments
- **Filter assignments** by status (All, Pending, Completed)
- Mark assignments as completed with one tap
- **Upcoming & Overdue** assignment filters
- View assignment details:
  - Subject
  - Due date
  - Description
  - Priority level (Low, Medium, High)
- Add new assignments with all relevant details

### 📖 Exam Scheduler
- **Tabbed view** for Upcoming and Past exams
- Exam countdown feature
- **7-day upcoming exam alerts**
- Add and manage exams with:
  - Subject name
  - Exam date and time
  - Exam type (Midterm, Final, Quiz)
  - Room location
  - Notes/Syllabus
- Edit and delete exams

### 📒 Notes
- Create and organize your study notes
- **Search functionality** to quickly find notes
- Grid view for easy browsing
- **Cloud-synced** notes across devices
- Note features:
  - Title
  - Content
  - Creation & update timestamps

### 📢 Notice Board
- Stay updated with campus announcements
- View all notices with details
- **Admin access** for creating and managing notices
- Notice categories for better organization

### 👤 Profile Management
- View and edit your profile
- Update personal information
- **Sync profile** from server
- Secure authentication with login/logout
- User data management

### 🔔 Notifications
- Get reminders for upcoming assignments
- Exam notifications
- Class reminders
- Customizable notification settings

---

## 🎨 UI/UX Highlights

- **Modern Material Design 3** interface
- Beautiful **gradient accents** and color schemes
- Smooth **animations and transitions**
- **Responsive design** that works on all screen sizes
- Clean and intuitive navigation with bottom navigation bar
- **Google Fonts** (Poppins) for elegant typography
- **Loading states** and error handling for better UX

---

## 🛠️ Technology Stack

### Frontend (Flutter App)

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.8.1+ |
| Language | Dart |
| State Management | Provider |
| HTTP Client | http package |
| Local Storage | SharedPreferences |
| Notifications | flutter_local_notifications |
| Calendar | table_calendar |
| UI Components | Material Design 3, Google Fonts, Lottie |
| Utilities | intl, uuid, timezone |

### Backend (REST API)

| Category | Technology |
|----------|------------|
| Database | PostgreSQL |
| Authentication | JWT (Access & Refresh Tokens) |
| API Architecture | RESTful API |
| Hosting | Render Cloud Platform |

---

## 🔌 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | User registration |
| POST | `/login` | User login |
| POST | `/refresh` | Refresh access token |
| GET | `/me` | Get user profile |

### Timetable
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/timetable` | Get all timetable entries |
| POST | `/timetable` | Create new entry |
| PUT | `/timetable/{id}` | Update entry |
| DELETE | `/timetable/{id}` | Delete entry |

### Assignments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/assignments` | Get all assignments |
| POST | `/assignments` | Create new assignment |
| PUT | `/assignments/{id}` | Update assignment |
| DELETE | `/assignments/{id}` | Delete assignment |
| PATCH | `/assignments/{id}/complete` | Mark as complete |
| GET | `/assignments/upcoming` | Due in 7 days |
| GET | `/assignments/overdue` | Past due date |

### Exams
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/exams` | Get all exams |
| POST | `/exams` | Create new exam |
| PUT | `/exams/{id}` | Update exam |
| DELETE | `/exams/{id}` | Delete exam |
| GET | `/exams/upcoming` | Next 7 days |

### Notes
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notes` | Get all notes |
| POST | `/notes` | Create new note |
| PUT | `/notes/{id}` | Update note |
| DELETE | `/notes/{id}` | Delete note |

---

## 📱 How to Use

### Getting Started
1. **Sign Up**: Create a new account with username, email, and password
2. **Login**: Access your personalized dashboard with your credentials
3. **Dashboard Overview**: View your daily summary including today's classes, pending assignments, and upcoming exams

### Managing Your Timetable
1. Navigate to the **Timetable** tab from the bottom navigation
2. Select any day of the week using the day selector at the top
3. Tap the **+** button to add a new class
4. Fill in the class details (subject, time, room, instructor)
5. Long press on any class to edit or delete it
6. Changes sync automatically with the cloud

### Tracking Assignments
1. Go to the **Assignments** tab
2. Use the filter icon to view All, Pending, or Completed assignments
3. Tap **+** to add a new assignment
4. Fill in assignment details including subject, due date, and priority
5. Tap on an assignment to mark it as completed or view details

### Managing Exams
1. Navigate to the **Exams** tab
2. Switch between **Upcoming** and **Past** tabs
3. Add new exams using the **+** button
4. Enter exam details like subject, date, type, and syllabus
5. Track countdown to your next exam

### Taking Notes
1. Open the **Notes** section from the bottom navigation
2. Use the search bar to find specific notes
3. Create new notes by tapping the **+** button
4. Notes are automatically synced to the cloud

### Viewing Notices
1. Access the **Notice Board** from the dashboard
2. Browse through campus announcements
3. Admins can add, edit, or delete notices

### Profile Settings
1. Tap on **Profile** in the navigation
2. View your account information
3. Edit your profile details
4. Log out when needed

---

## 📂 Project Structure

```
lib/
├── main.dart                  # App entry point
├── core/
│   ├── constants/             # App constants & API URLs
│   ├── theme/                 # App theme and styling
│   └── utils/                 # Utility functions
├── data/
│   └── models/                # Data models (JSON serialization)
├── presentation/
│   ├── controllers/           # State management (Providers)
│   ├── screens/               # All app screens
│   └── widgets/               # Reusable widgets
└── services/
    ├── api_service.dart       # REST API client & token management
    ├── auth_service.dart      # Authentication logic
    └── notification_service.dart  # Local notifications
```

---

## 🗄️ Database Schema

### Users
```sql
- id (Primary Key)
- username (Unique)
- email (Unique)
- password (Hashed)
- created_at
```

### Timetables
```sql
- id (Primary Key)
- subject
- day (Monday-Sunday)
- start_time
- end_time
- room
- teacher
- user_id (Foreign Key)
```

### Assignments
```sql
- id (Primary Key)
- title
- subject
- description
- due_date
- status (pending/completed)
- priority (low/medium/high)
- created_at
- user_id (Foreign Key)
```

### Exams
```sql
- id (Primary Key)
- subject
- exam_type (midterm/final/quiz)
- exam_date
- room
- notes
- created_at
- user_id (Foreign Key)
```

### Notes
```sql
- id (Primary Key)
- title
- content
- created_at
- updated_at
- user_id (Foreign Key)
```

---

## 🎯 Key Screens

| Screen | Description |
|--------|-------------|
| Login/Signup | User authentication screens |
| Dashboard | Home screen with overview |
| Timetable | Weekly class schedule |
| Assignments | Assignment tracker |
| Exams | Exam scheduler |
| Notes | Note-taking screen |
| Notice Board | Campus announcements |
| Profile | User profile management |

---

## 📋 Requirements

### Frontend
- Flutter SDK 3.8.1 or higher
- Dart SDK compatible with Flutter 3.8.1
- Android SDK (for Android builds)
- Xcode (for iOS builds)

### Backend
- PostgreSQL database
- REST API server (hosted on Render)

---

## 🚀 Getting Started

### Prerequisites
```bash
# Ensure Flutter is installed
flutter --version

# Get dependencies
flutter pub get
```

### Running the App
```bash
# Run in debug mode
flutter run

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

---

## 🔒 Security Features

- **Password Hashing**: Secure password storage
- **JWT Authentication**: Stateless, secure token-based auth
- **Token Refresh**: Automatic session renewal
- **HTTPS**: Encrypted API communication
- **User Isolation**: Data segregation per user

---

## 🤝 Support

If you encounter any issues or have suggestions, feel free to open an issue in the repository.

---

## 📄 License

This project is for educational purposes.

---



<p align="center"> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/1.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/2.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/3.jpeg" width="220"/> </p> <p align="center"> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/4.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/5.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/6.jpeg" width="220"/> </p> <p align="center"> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/7.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/8.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/9.jpeg" width="220"/> </p> <p align="center"> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/10.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/11.jpeg" width="220"/> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/12.jpeg" width="220"/> </p> <p align="center"> <img src="https://raw.githubusercontent.com/CodeOfNamanBhalani/Acadly/main/screenshort/13.jpeg" width="220"/> </p>
