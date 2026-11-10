# PN Junction Diode Lab

A Flutter learning app for exploring silicon and germanium PN junction diodes, their forward and reverse V–I characteristics, and basic laboratory measurements.

## Features

- PN junction structure, biasing explanations and glossary.
- Responsive silicon/germanium comparison.
- Interactive forward and reverse characteristics with live readings.
- Optional signed V–I graph with explicitly labelled split voltage/current scales.
- Slider and validated numerical voltage entry.
- Circuit diagram with a series current meter and a voltmeter across the diode.
- Observation table with signed readings, removal/undo, CSV download and copying.
- Saved experiment settings, observations and quiz progress on Android and web.
- Eight-question offline quiz with feedback, explanations, scoring and retry.

## Run

Install Flutter and its platform tools, then run from this folder:

```sh
flutter pub get
flutter run -d chrome
```

To run on a connected Android device, use `flutter devices` followed by `flutter run -d DEVICE_ID`.

## Build an Android APK

```sh
flutter build apk --release
```

The APK is created at `build/app/outputs/flutter-apk/app-release.apk`.
The included Android configuration uses debug signing for local demonstration builds. Configure a private release signing key before publishing to an app store; do not commit signing keys.

## Checks

```sh
flutter test
flutter analyze
```

The source includes 16 tests covering diode calculations, phone/desktop layouts, voltage validation, observation recording, CSV values and progress restoration.

## Simulation assumptions

The plotted data are illustrative, not measured specifications for particular diode parts. The model uses the Shockley equation at 25 °C, ideality factor 2 and 2 Ω internal series resistance. It is calibrated to 1 mA at 0.65 V for Si and 0.28 V for Ge. Breakdown and self-heating are excluded.

The control sets diode terminal voltage, rather than supply voltage. Individual reverse graphs show magnitudes. The combined view and exported data use negative voltage/current for reverse bias. The combined graph explicitly uses different scales on the forward and reverse branches.

## Project structure

```text
lib/models/       Diode calculations and saved lab state
lib/screens/      Lessons, comparison, experiment and quiz
lib/widgets/      Navigation, circuit and combined graph
lib/services/     Browser and native storage/CSV bridge
test/             Model and interaction tests
android/          Android project and native save/export support
web/              Browser app entry files
ios/              Flutter-generated iOS scaffold; not validated
```

Android progress is stored locally in app preferences; browser progress uses local storage. Android CSV export opens the system save dialog; web export downloads a CSV file. No backend is required for the current app flow. Unused legacy lesson/API source remains in `lib/` for reference.
