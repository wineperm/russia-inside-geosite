#!/bin/bash
set -e

echo "🔄 Загрузка списка доменов из itdoginfo/allow-domains..."
mkdir -p data

curl -fsSL -o data/russia-inside.raw \
  "https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-raw.lst"

if [ ! -s data/russia-inside.raw ]; then
  echo "❌ Ошибка: не удалось загрузить список доменов (пустой файл или 404)"
  exit 1
fi

loaded=$(wc -l < data/russia-inside.raw)
echo "📊 Загружено строк: $loaded"

echo "🔄 Конвертация в формат domain-list-community..."

# 1. Валидный обычный домен: example.com, sub.example.com
VALID_DOMAIN_REGEX='^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)+$'
# 2. Валидный TLD (начинается с точки): .ua, .com.ua, .рф и т.д.
TLD_REGEX='^\.[a-zA-Z0-9.-]+$'

skipped=0
converted=0

{
  echo "# Russia Inside domains"
  echo "# Source: https://github.com/itdoginfo/allow-domains"
  echo "# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo ""

  while IFS= read -r domain || [ -n "$domain" ]; do
    # Пропустить пустые строки и комментарии
    [[ -z "${domain// }" || "$domain" =~ ^[[:space:]]*# ]] && continue

    # Очистка: убрать \r (Windows переносы), пробелы, привести к нижнему регистру
    domain=$(printf '%s' "$domain" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]')
    
    [[ -z "$domain" ]] && continue

    # Сценарий А: Строка уже размечена (domain:, full:, и т.д.)
    if [[ "$domain" =~ ^(domain:|full:|keyword:|regexp:|include:) ]]; then
      echo "$domain"
      converted=$((converted + 1))
      continue
    fi

    # Сценарий Б: Это доменная зона (начинается с точки, например ".ua")
    # Превращаем ".ua" в "regexp:\.ua$" для корректной компиляции и матчинга в Xray
    if [[ "$domain" =~ $TLD_REGEX ]]; then
      clean_tld="${domain#.}"
      # Экранируем точки внутри (например .com.ua -> \.com\.ua$)
      escaped_tld=$(echo "$clean_tld" | sed 's/\./\\./g')
      echo "regexp:\\.${escaped_tld}\$"
      converted=$((converted + 1))
      continue
    fi

    # Сценарий В: Обычный валидный домен
    if [[ "$domain" =~ $VALID_DOMAIN_REGEX ]]; then
      echo "domain:$domain"
      converted=$((converted + 1))
    else
      # Сценарий Г: Мусор, который точно не нужен (например, просто "http", "ua" без точки)
      skipped=$((skipped + 1))
    fi
  done < data/russia-inside.raw
} > data/russia-inside

rm -f data/russia-inside.raw

echo "✅ Конвертировано правил: $converted"
echo "⚠️ Пропущено невалидных строк (мусор): $skipped"
