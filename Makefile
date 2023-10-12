build-runner:
	flutter pub get
	flutter pub run build_runner build

build-apk:
	flutter build apk

install-apk:
	adb install build/app/outputs/flutter-apk/app-release.apk

build-bundle:
	flutter build appbundle

apk: build-runner build-apk install-apk

bundle: build-runner build-bundle