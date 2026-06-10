# Premium Venue Booking System

A premium mobile application for booking flight and sports venues, featuring real-time schedule slot mapping, conflict-free transactions, and a robust admin dashboard.

---

## 🛠️ Tech Stack
- **Frontend Framework**: Flutter (Dart)
- **Backend & Database**: Firebase (Authentication & Firestore)
- **State Management**: flutter_bloc (Cubits)
- **Theme**: Red & Black Premium Aesthetic (Dark/Goth themed accents)

---

## 🔑 Admin Credentials
- **Email**: `admin@gmail.com`
- **Password**: `pass-1234567`

---

## 🚀 Key Features

### 🔐 Authentication (Auth)
- Email & password signup and signin.
- Enhanced Firebase exception parsing mapping exact error messages (e.g. `invalid-credential` to "Invalid email or password").
- Deferred post-frame transitions resolving navigation lock crashes (`!_debugLocked`) across all dialogs and bottom sheets.
- Logout confirmation prompt dialog guards.

### 🏟️ Venue Management
- **User Side**:
  - Interactive grid cards highlighting sports venues, pricing per slot, locations, and pricing badges.
- **Admin Side**:
  - Manage venues panel with sheets to create and edit venue entries (Name, Location, Sport, Price per slot).

### 📅 Calendar & Booking System
- **User Side**:
  - Interactive 4-day slot booking grid showcasing dynamic slot states (Available, Booked, Your Booking, Filling Fast, and Expired/Past slots).
  - Multi-slot selection and checkout with atomic Cloud Firestore transactions to block simultaneous/duplicate bookings.
  - History tab displaying the user's latest 10 bookings, date filters, and cancellation request alerts.
- **Admin Side**:
  - Dual-mode dashboard supporting **Chronological List View** and **Calendar View**.
  - Dropdown filter to dynamically scope bookings by venue.
  - Date navigator allowing past & future date lookup (-1/+1 day, Today, and calendar picker selection).
  - Tapping booked slots launches a detail popup displaying reservation properties (Venue, Client name, Email, Slot time, Status, and Creation date).

---

## 📂 Project Structure
- `lib/core/` - Global styling themes, router routing configuration, Firestore collections, and date format helpers.
- `lib/features/auth/` - Authentication logic, repositories, and registration screens.
- `lib/features/venue/` - Venue list screens, creation forms, and state models.
- `lib/features/booking/` - Slot selection widgets, booking transactions, and user histories.
- `lib/features/admin/` - Admin shell, venue creation forms, client users tables, and calendar dashboards.


- `Link`:-https://youtu.be/R2DFMKVkLVQ
