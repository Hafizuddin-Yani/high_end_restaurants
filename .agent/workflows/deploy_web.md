---
description: How to deploy the Flutter Web App to Firebase Hosting
---

1.  **Build the Web Application**
    Run the following command to generate the release build of the web app. This compiles the Dart code into JavaScript and places the assets in the `build/web` directory.
    ```bash
    flutter build web --release --wasm
    ```
    *Note: If wasm fails, use `flutter build web --release`.*

2.  **Deploy to Firebase Hosting**
    Use the Firebase CLI to deploy the contents of `build/web` to your Firebase Hosting URL.
    ```bash
    // turbo
    firebase deploy --only hosting --project high-end-restaurants
    ```
