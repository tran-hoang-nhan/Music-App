# MusicApp

An Android music streaming application built with Java that provides users with access to playlists, albums, artists, and music discovery features.

## Features

- **Music Discovery**: Browse and discover new music through curated playlists and recommendations
- **Search**: Search for songs, artists, albums, and playlists
- **Music Player**: Full-featured music player with playback controls
- **User Authentication**: Firebase-based login and registration system
- **Library Management**: Personal music library with playlists and favorites
- **Artist & Album Views**: Dedicated views for exploring artists and albums

## Tech Stack

- **Language**: Java
- **Platform**: Android (API 23+)
- **Architecture**: MVVM with ViewModels and LiveData
- **UI**: Material Design components with ViewBinding
- **Networking**: Retrofit with Gson converter
- **Image Loading**: Glide
- **Media Playback**: ExoPlayer (Media3)
- **Authentication**: Firebase Auth with Google Sign-In
- **Database**: Firebase Firestore

## Project Structure

```
app/src/main/java/com/example/musicapp/
├── api/                    # API service interfaces
├── model/                  # Data models and adapters
├── network/               # Network configuration (Retrofit)
├── player/                # Music player management
└── ui/                    # UI components organized by feature
    ├── album/             # Album browsing
    ├── artist/            # Artist profiles
    ├── dashboard/         # Main dashboard
    ├── discover/          # Music discovery
    ├── library/           # User library
    ├── musicplayerfull/   # Full music player
    ├── profile/           # User authentication
    └── search/            # Search functionality
```

## Setup Instructions

### Prerequisites

- Android Studio Arctic Fox or later
- Android SDK API 23 or higher
- Google Services configuration file

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd MusicApp
   ```

2. Open the project in Android Studio

3. Add your `google-services.json` file to the `app/` directory for Firebase integration

4. Update the `default_web_client_id` in `strings.xml` with your Google OAuth client ID

5. Build and run the project:
   ```bash
   ./gradlew assembleDebug
   ```

## Configuration

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication and Firestore Database
3. Configure Google Sign-In in Authentication settings
4. Download and add `google-services.json` to your app module

### API Configuration

Update the API endpoints in `RetrofitClient.java` to point to your music service backend.

## Key Dependencies

- **Firebase**: Authentication and database services
- **Retrofit**: HTTP client for API communication
- **ExoPlayer**: Media playback engine
- **Glide**: Image loading and caching
- **Material Components**: UI components following Material Design

## Building

### Debug Build
```bash
./gradlew assembleDebug
```

### Release Build
```bash
./gradlew assembleRelease
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.