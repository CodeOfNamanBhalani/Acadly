![Logo](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/AppIcons/appstore.png)

# Campus Companion - Student Academic Planner 📚

A comprehensive Flutter application designed to help students manage their academic life efficiently. Campus Companion provides an all-in-one solution for managing timetables, assignments, exams, notes, and staying updated with campus notices.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Features

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
- Set class details including:
  - Subject name
  - Time slot
  - Room/Location
  - Instructor name

### 📝 Assignment Tracker
- Keep track of all your assignments
- **Filter assignments** by status (All, Pending, Completed)
- Mark assignments as completed
- View assignment details:
  - Subject
  - Due date
  - Description
  - Priority level (Low, Medium, High)
- Add new assignments with all relevant details

### 📖 Exam Scheduler
- **Tabbed view** for Upcoming and Past exams
- Exam countdown feature
- Add and manage exams with:
  - Subject name
  - Exam date and time
  - Exam type
  - Syllabus/Topics to cover
- Edit and delete exams

### 📒 Notes
- Create and organize your study notes
- **Search functionality** to quickly find notes
- Grid view for easy browsing
- Note features:
  - Title
  - Content
  - Subject categorization
  - Creation date tracking

### 📢 Notice Board
- Stay updated with campus announcements
- View all notices with details
- **Admin access** for creating and managing notices
- Notice categories for better organization

### 👤 Profile Management
- View and edit your profile
- Update personal information
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

---

## 🛠️ Technology Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| Language | Dart |
| State Management | Provider |
| Local Database | Hive |
| Notifications | flutter_local_notifications |
| Calendar | table_calendar |
| UI Components | Material Design 3, Google Fonts, Lottie |
| Utilities | intl, uuid, timezone |

---

## 📱 How to Use

### Getting Started
1. **Sign Up/Login**: Create an account or log in to access your personalized dashboard
2. **Dashboard Overview**: View your daily summary including today's classes, pending assignments, and upcoming exams

### Managing Your Timetable
1. Navigate to the **Timetable** tab from the bottom navigation
2. Select any day of the week using the day selector at the top
3. Tap the **+** button to add a new class
4. Fill in the class details (subject, time, room, instructor)
5. Long press on any class to edit or delete it

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
4. Organize notes by subject for easy access

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
│   ├── constants/             # App constants
│   ├── theme/                 # App theme and styling
│   └── utils/                 # Utility functions
├── data/
│   ├── database/              # Hive database service
│   └── models/                # Data models
├── presentation/
│   ├── controllers/           # State management (Providers)
│   ├── screens/               # All app screens
│   └── widgets/               # Reusable widgets
└── services/
    ├── auth_service.dart      # Authentication logic
    └── notification_service.dart  # Local notifications
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

- Flutter SDK 3.8.1 or higher
- Dart SDK compatible with Flutter 3.8.1
- Android SDK (for Android builds)
- Xcode (for iOS builds)

---

## 🤝 Support

If you encounter any issues or have suggestions, feel free to open an issue in the repository.

---

## 📄 License

This project is for educational purposes.

---

**Made with ❤️ By Naman Bhalani**

![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/1.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/2.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/3.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/4.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/5.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/6.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/7.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/13.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/8.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/9.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/10.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/11.jpeg)
![img](https://github.com/CodeOfNamanBhalani/Acadly/blob/main/screenshort/12.jpeg)
