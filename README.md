# Методы адаптации интерфейсов

Сайт по методам адаптации интерфейсов под поведение пользователей. Задание 1 по курсу «Проектирование и развертывание веб-решений в эко-системе Python».

## Окружение

В каталоге проекта:

```sh
virtualenv --python python3.15 .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python --version
python -m pip --version
```

Используются Python 3.15.2 и virtualenv 21.15.6.

## Локальный запуск

```sh
mkdocs serve
```

Проверка сборки:

```sh
mkdocs build --strict
```

## Публикация

Публикация на [GitHub Pages](https://gentofluck.github.io/adaptive-ui-review/) и [Helios](https://se.ifmo.ru/~s336456/adaptive-interfaces-review/) запускается после push в `main`. Для других веток создаётся отдельная версия на Helios.

Настройки находятся в [deploy.yml](.github/workflows/deploy.yml) и [deploy-helios.yml](.github/workflows/deploy-helios.yml). Для ручного отката на Helios нужно запустить workflow `Helios` из ветки `main` с действием `rollback`.

## Лицензии

Код распространяется по [MIT](LICENSE), авторские тексты по [CC BY 4.0](LICENSE-CONTENT).
