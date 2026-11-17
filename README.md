# 📝 README.md для репозитория

Создайте файл `README.md` в корне репозитория и скопируйте следующее содержимое:

```markdown
# 🇷🇺 Russia Inside GeoSite — автоматический генератор geosite.dat

Автоматически обновляемый список российских доменов в формате `geosite.dat` для использования в **Xray**, **V2Ray**, **Passwall2** и других прокси-клиентах на базе Project V.

---

## 📋 Описание

Этот репозиторий ежедневно генерирует актуальный `geosite.dat` с российскими доменами:

| Файл | Формат | Назначение |
|------|--------|------------|
| `geosite.dat` | Бинарный Protobuf (V2Ray) | ⚡ Оптимальный для Xray / Passwall2 |
| `geosite.dat.sha256sum` | Контрольная сумма | Проверка целостности |
| `data/russia-inside` | Текстовый список доменов | Читаемый формат для проверки |

### 🔗 Источник данных

- **Основной список**: [itdoginfo/allow-domains](https://github.com/itdoginfo/allow-domains) — Russia/inside-raw.lst
- **Компилятор**: [v2fly/domain-list-community](https://github.com/v2fly/domain-list-community)

### ✨ Особенности

- **Автоматические ежедневные обновления** в 03:00 UTC
- **Уведомления в Telegram** при каждом обновлении
- **Пользовательские списки**: `custom_allow.lst` и `custom_deny.lst` для постоянной кастомизации
- **Корректная обработка TLD**: доменные зоны вида `.ua`, `.su` конвертируются в `regexp`-правила
- **Полная совместимость** с Xray, V2Ray, Passwall2

---

## 🚀 Быстрое использование

### Скачивание geosite.dat

Последняя версия всегда доступна по прямой ссылке:

```
https://github.com/wineperm/russia-inside-geosite/releases/latest/download/geosite.dat
```

### Использование в Passwall2

1. **Скачайте файл на роутер:**

   ```bash
   wget -O /usr/share/xray/geosite-custom.dat \
     https://github.com/wineperm/russia-inside-geosite/releases/latest/download/geosite.dat
   ```

2. **Создайте правило маршрутизации:**
   - Откройте **Passwall2 → Node List → Add Node**
   - Выберите **Node Type: Shunt Node (_shunt)**
   - Добавьте правила в порядке приоритета:

   | Приоритет | Rule Name | Match | Destination |
   |-----------|-----------|-------|-------------|
   | 1 | Russia Inside | `geosite:russia-inside` | `_direct` |
   | 2 | China Direct | `geosite:cn`, `geoip:cn` | `_direct` |
   | 3 | Proxy Blocked | `geosite:geolocation-!cn` | [ваш VLESS node] |
   | 4 | Default | (fallback) | [ваш VLESS node] |

3. **Примените правило** — выберите созданный Shunt Node в **Global Settings**.

4. **Перезапустите Passwall2:**

   ```bash
   /etc/init.d/passwall2 restart
   ```

> 💡 **Совет**: Российские сайты пойдут напрямую (быстро), заблокированные — через ваш VLESS-прокси.

---

## 📁 Структура репозитория

```
📦 russia-inside-geosite
├── 📄 README.md                          # Этот файл
├── 📄 .gitignore                         # Исключения для git
├── 📄 LICENSE                            # MIT лицензия
├── 📁 .github/
│   └── 📁 workflows/
│       └── 📄 build-geosite.yml          # GitHub Actions workflow
├── 📁 data/
│   └── 📄 russia-inside                  # Список доменов (автогенерация)
├── 📁 scripts/
│   ├── 📄 fetch-and-convert.sh           # Загрузка и конвертация доменов
│   └── 📄 apply-custom-lists.sh          # Применение custom списков
├── 📄 custom_allow.lst                   # ➕ Домены для добавления
├── 📄 custom_deny.lst                    # ➖ Домены для исключения
└── 📄 .last_checksum                     # Хеш для отслеживания изменений
```

---

## ⚙️ Как это работает

### 🔁 Автоматическое обновление

1. **Ежедневно в 03:00 UTC** запускается GitHub Actions
2. Скрипт скачивает актуальный список из `itdoginfo/allow-domains`
3. Конвертирует домены в формат `domain-list-community`:
   - Обычные домены → `domain:example.com`
   - Доменные зоны (`.ua`, `.su`) → `regexp:\.ua$`
4. **Применяет пользовательские правила**:
   - Удаляет домены из `custom_deny.lst`
   - Добавляет домены из `custom_allow.lst`
5. Компилирует финальный `geosite.dat` с помощью официального инструмента V2Fly
6. Если есть изменения — создаёт новый Release и пушит в репозиторий
7. Отправляет уведомление в Telegram (если настроено)

### 🔄 Триггеры запуска

```yaml
on:
  schedule:
    - cron: '0 3 * * *'        # Ежедневно в 3:00 UTC
  push:
    branches: [main]
    paths:
      - 'data/**'
      - 'custom_allow.lst'      # ➕ При изменении пользовательских списков
      - 'custom_deny.lst'       # ➖ тоже запускает пересборку
      - 'scripts/**'
  workflow_dispatch:            # Ручной запуск через интерфейс GitHub
```

---

## 🛠️ Развёртывание своей копии

### 1. Форкните репозиторий

Нажмите **Fork** в правом верхнем углу GitHub.

### 2. Настройте секреты (для Telegram-уведомлений)

Перейдите в **Settings → Secrets and variables → Actions** и добавьте:

| Secret | Описание |
|--------|----------|
| `TELEGRAM_BOT_TOKEN` | Токен бота от @BotFather |
| `TELEGRAM_CHAT_ID` | ID чата для уведомлений (узнать через @getidsbot) |

> ⚠️ Уведомления в Telegram — опциональны. Если не настроите, воркфлоу будет работать без них.

### 3. Разрешите права на запись

В `.github/workflows/build-geosite.yml` убедитесь, что есть блок:

```yaml
permissions:
  contents: write
```

### 4. Настройте пользовательские списки (по желанию)

- **`custom_deny.lst`** — домены для **исключения** (по одному на строку)
- **`custom_allow.lst`** — домены для **добавления** (по одному на строку)

Эти файлы можно изменять в любое время — после пуша сразу пересобирается `geosite.dat`.

### 5. Запустите первое обновление вручную

1. Перейдите во вкладку **Actions**
2. Выберите воркфлоу **Build GeoSite Database**
3. Нажмите **Run workflow** → **Run workflow**

### 6. Готово! 🎉

Файл `geosite.dat` появится в разделе **Releases** после успешного выполнения.

---

## 🔧 Локальное тестирование

```bash
# 1. Клонируйте репозиторий
git clone https://github.com/wineperm/russia-inside-geosite.git
cd russia-inside-geosite

# 2. Клонируйте domain-list-community
git clone https://github.com/v2fly/domain-list-community.git dlc
cd dlc && go mod download && cd ..

# 3. Сделайте скрипты исполняемыми
chmod +x scripts/*.sh

# 4. Загрузите и конвертируйте домены
./scripts/fetch-and-convert.sh

# 5. Примените пользовательские списки
./scripts/apply-custom-lists.sh

# 6. Сгенерируйте geosite.dat
cd dlc
go run ./ --datapath=../data
mv dlc.dat ../geosite.dat
cd ..

# 7. Проверьте результат
sha256sum geosite.dat
```

---

## 🔄 Обновление на роутере

### Автоматическое (через cron)

Создайте скрипт `/root/update-geosite.sh`:

```bash
#!/bin/sh
GEOSITE_PATH="/usr/share/xray/geosite-custom.dat"
GEOSITE_URL="https://github.com/YOUR_USERNAME/russia-inside-geosite/releases/latest/download/geosite.dat"

wget -q -O "$GEOSITE_PATH.tmp" "$GEOSITE_URL" && \
  mv "$GEOSITE_PATH.tmp" "$GEOSITE_PATH" && \
  /etc/init.d/passwall2 restart
```

Добавьте в cron (`crontab -e`):

```bash
# Ежедневно в 04:00
0 4 * * * /root/update-geosite.sh >> /var/log/geosite-update.log 2>&1
```

### Ручное обновление

```bash
wget -O /usr/share/xray/geosite-custom.dat \
  https://github.com/wineperm/russia-inside-geosite/releases/latest/download/geosite.dat
/etc/init.d/passwall2 restart
```

---

## ❓ FAQ

### Почему файл geosite.dat бинарный?

Это нормально. `geosite.dat` использует бинарный формат Protobuf для максимальной производительности. Не пытайтесь читать его в текстовом редакторе — используйте `data/russia-inside` для просмотра содержимого.

### Как добавить свои исключения или домены **постоянно**?

Отредактируйте файлы `custom_deny.lst` (для исключения) или `custom_allow.lst` (для добавления) в корне репозитория. Каждый домен с новой строки. После пуша этих файлов автоматически пересоберётся `geosite.dat` с применёнными правками. При следующих обновлениях ваши правки сохранятся.

### Почему я вижу домен в `data/russia-inside`, но его нет в `geosite.dat`?

Это нормально, если вы добавили его в `custom_deny.lst`. Файл `data/russia-inside` содержит исходный список до конвертации, а `geosite.dat` — финальный после применения пользовательских правил.

### Можно ли исключить YouTube или другие сервисы?

Да! Добавьте их в `custom_deny.lst` — они будут постоянно исключены из финального списка. Например:

```
youtube.com
ytimg.com
googlevideo.com
```

### Можно ли использовать в других клиентах?

- ✅ **Xray / V2Ray** — нативная поддержка
- ✅ **Passwall2** — полная поддержка
- ✅ **Qv2ray** — через импорт geosite.dat
- ⚠️ **sing-box / Podkop** — требуется конвертация в `.srs`

### Почему не обновляется список?

1. Проверьте вкладку **Actions** — нет ли ошибок в логах
2. Убедитесь, что исходный список `itdoginfo` изменился (скрипт сравнивает SHA256-хеши)
3. Проверьте, что файлы не добавлены в `.gitignore`
4. Убедитесь, что у GitHub Actions есть права на запись (`permissions: contents: write`)

### Что означает `geosite:russia-inside`?

Это имя списка внутри `geosite.dat`. Оно соответствует имени файла `data/russia-inside` без расширения. Вы можете использовать это имя в правилах маршрутизации Xray/V2Ray.

### Как работают TLD (`.ua`, `.su`)?

Доменные зоны автоматически конвертируются в регулярные выражения: `.ua` → `regexp:\.ua$`. Это позволяет матчить все домены, заканчивающиеся на `.ua` (например, `test.ua`, `my.com.ua`).

---

## 🤝 Вклад в проект

Предложения по улучшению приветствуются! 🙌

1. Создайте форк репозитория
2. Создайте ветку для вашей фичи: `git checkout -b feature/amazing-feature`
3. Внесите изменения и закоммитьте: `git commit -m 'Add: amazing feature'`
4. Отправьте в свой форк: `git push origin feature/amazing-feature`
5. Откройте **Pull Request**

---

## 📜 Лицензия

Проект распространяется под лицензией **MIT**. См. файл [LICENSE](LICENSE) для деталей.

Исходные данные взяты из репозитория [itdoginfo/allow-domains](https://github.com/itdoginfo/allow-domains) (лицензия автора).

---

## ⚠️ Отказ от ответственности

> Этот проект предоставляется «как есть», без каких-либо гарантий. Автор не несёт ответственности за возможные проблемы при использовании списков.

---

## 📬 Контакты

- 🐛 Сообщить об ошибке: [Issues](https://github.com/wineperm/russia-inside-geosite/issues)
- 💡 Предложить улучшение: [Discussions](https://github.com/wineperm/russia-inside-geosite/discussions)

---

> ⭐ **Понравился проект?** Поставьте звезду — это помогает другим найти репозиторий!

# Если этот репозиторий оказался полезным — поделитесь ссылкой с друзьями! 🙏
```
