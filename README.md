# MMS - Machine monitoring system
Приложение работает совместо с [Lathe emulator](https://github.com/AndreyMukhametzyanov/lathe_emulator),который эмулирует станок.

Приложение сканирует станки подключенные к локальной сети, используя код написанный на языке **Crystal** [ip_scanner_for_mms](https://github.com/AndreyMukhametzyanov/ip_scanner_for_mms).

Позволяет отслежить информацию о станках в режиме онлайн, перейдя на страницу нужного станка, а также управлять станками удаленно (вкл/выкл). Приложение покрыто тестами rspec.

<br>
<details>
       <summary> Запуск приложения (спойлер) </summary>

***ВАЖНО!***
> Если вы используете WINDOWS + WSL убедитесь что вы запустили базу данных Postgresql !

- Установить зависимости

```shell
bundle install
```

- Установить гем 'foreman' https://github.com/ddollar/foreman

```shell
gem install foreman
```

- Запустить 'foreman'

```shell
foreman start
```

- Тесты

```shell
rspec
```
