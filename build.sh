#!/bin/bash

# Проверка наличия Flutter
if ! command -v flutter &> /dev/null; then
  echo "Flutter не установлен. Пожалуйста, установите Flutter и добавьте его в PATH."
  exit 1
fi

DIRECTORY="./artifacts"

APP_NAME="starter_template"

# Типы артефактов
ANDROID=$((1<<0))
IOS=$((1<<1))

# Опции
QA=$((1<<2))

MASK=0

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --android) MASK=$(($MASK | $ANDROID)) ;;
    --ios) MASK=$(($MASK | $IOS)) ;;
    --qa) MASK=$(($MASK | $QA)) ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

MODE=$((ANDROID|IOS))
IS_QA="false"

if (( ($MASK & $QA) > 0 )); then IS_QA="true"; MASK=$(($MASK ^ $QA)); fi
if (( $MASK != 0 )); then MODE=$(($MODE & $MASK)); fi

version=$(grep -Eo -m 1 "[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+" pubspec.yaml)

if [ -d "$DIRECTORY" ]; then
   rm -rf $DIRECTORY
fi


if ((($MODE & $ANDROID) > 0)); then
  echo "Build android"
  flutter build apk --release --target-platform android-arm,android-arm64 --obfuscate --split-debug-info=./v$version
fi


if ((($MODE & $IOS) > 0)); then
  echo "Build iOS"
  flutter build ipa --release --obfuscate --split-debug-info=./v$version
fi

echo "Загрузка артефактов"
mkdir -p artifacts

SUFFIX=""

if [ "$IS_QA" == 'true' ] ; then SUFFIX="-QA"; fi

if ((($MODE & $ANDROID) > 0)); then
  echo "Save android$SUFFIX"
  mv build/app/outputs/flutter-apk/app-release.apk "$DIRECTORY/$APP_NAME-($version)$SUFFIX.apk"
fi

if ((( $MODE & $IOS ) > 0)); then
  echo "Save iOS$SUFFIX"
  mv build/ios/ipa/*.ipa "$DIRECTORY/$APP_NAME-($version)$SUFFIX.ipa"
fi