# Firebase config placeholders

Real Firebase credentials live here per environment (`dev` / `staging` / `prod`)
but are **gitignored**:

- `google-services.json`
- `GoogleService-Info.plist`
- `firebase_options.dart`

Checked-in `*.example.*` files show the expected shape only. Generate real
files with the FlutterFire CLI when backend integration starts
(`docs/11_ENVIRONMENT_CONFIGURATION.md` §9).
