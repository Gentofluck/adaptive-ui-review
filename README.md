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

[Workflow](.github/workflows/deploy.yml) собирает сайт и публикует его на GitHub Pages после push в `main`. Его также можно запустить вручную во вкладке Actions.

## Лицензии

Код распространяется по [MIT](LICENSE), авторские тексты по [CC BY 4.0](LICENSE-CONTENT).
