# hackathlone-app

Mobile app for the Hackathlone event, built with Flutter for iOS and Android.

- **Flutter**: Follow setup docs if have yet done [Flutter](https://docs.flutter.dev/get-started/install).

## Development

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/hackathlone-app.git
   cd hackathlone-app
   ```
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Setup environment variables (could move to bash_profile if this project scales):

   ```bash
   cp assets/.env.example assets/.env
   # Add your Supabase credentials to assets/.env
   ```

4. Generate Hive models (after any model changes):

   ```bash
   flutter packages pub run build_runner build
   ```

5. Run the app in debug mode:
   ```bash
   flutter run
   ```

## Features

### Authentication & Caching

- Multi-layered cache system with staleness validation
- Offline-first approach with automatic fallbacks
- User profile management with QR codes for meal tracking
