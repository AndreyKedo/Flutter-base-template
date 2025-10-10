#!/bin/bash

# Скрипт для переименования Flutter пакета

# Проверяем, существует ли директория scripts
if [ ! -d "scripts" ]; then
  echo "Ошибка: Директория scripts не найдена"
  exit 1
fi

# Переходим в директорию scripts
cd scripts

# Устанавливаем зависимости, если необходимо
if [ ! -d ".dart_tool" ] || [ ! -f "pubspec.lock" ]; then
  echo "Установка зависимостей..."
  dart pub get
fi

# Возвращаемся в исходную директорию
cd ..

# Запускаем скрипт с переданными аргументами
echo "Запуск скрипта переименования..."
dart run scripts/bin/rename_package.dart "$@"