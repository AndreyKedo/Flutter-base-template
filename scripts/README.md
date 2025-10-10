# Скрипт для переименования Flutter пакета

Этот скрипт помогает переименовать Flutter пакет, обновляя имя в `pubspec.yaml` и во всех импортах Dart файлов.

## Установка зависимостей

Перед использованием скрипта необходимо установить зависимости:

```bash
dart pub get
```

## Использование

### Переименование пакета

```bash
dart run rename_package.dart --new-name your_new_package_name
```

Опционально, можно явно указать старое имя пакета:

```bash
dart run rename_package.dart --old-name old_package_name --new-name your_new_package_name
```

### Инициализация нового репозитория

Для удаления существующего .git и инициализации нового репозитория:

```bash
dart run rename_package.dart --init-repo
```

## Аргументы командной строки

- `--new-name` или `-n`: Новое имя пакета (обязательный параметр для переименования)
- `--old-name` или `-o`: Старое имя пакета (опционально, будет извлечено из pubspec.yaml если не указано)
- `--init-repo`: Инициализировать новый git репозиторий
- `--help` или `-h`: Показать справку

## Пример использования

```bash
# Переименовать пакет с "starter_template" на "my_awesome_app"
dart run rename_package.dart --new-name my_awesome_app

# Переименовать пакет с явным указанием старого имени
dart run rename_package.dart --old-name starter_template --new-name my_awesome_app

# Инициализировать новый репозиторий после переименования
dart run rename_package.dart --init-repo