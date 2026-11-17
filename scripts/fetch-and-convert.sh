#!/bin/bash
set -e

echo "🔄 Загрузка списка доменов из itdoginfo/allow-domains..."

# Загрузить основной список
curl -s -o data/russia-inside.raw \
  "https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-raw.lst"

# Проверить, что файл не пустой
if [ ! -s data/russia-inside.raw ]; then
  echo "❌ Ошибка: не удалось загрузить список доменов"
  exit 1
fi

echo "📊 Загружено доменов: $(wc -l < data/russia-inside.raw)"

# Конвертировать в формат domain-list-community
echo "🔄 Конвертация в формат domain-list-community..."

# Создать файл с правильным синтаксисом
{
  echo "# Russia Inside domains (without YouTube)"
  echo "# Source: https://github.com/itdoginfo/allow-domains"
  echo "# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo ""
  
  # Преобразовать каждый домен в формат domain:
  while IFS= read -r domain; do
    # Пропустить пустые строки и комментарии
    [[ -z "$domain" || "$domain" =~ ^# ]] && continue
    
    # Очистить домен (удалить пробелы)
    domain=$(echo "$domain" | xargs)
    
    # Добавить префикс domain: если его нет
    if [[ ! "$domain" =~ ^(domain:|full:|keyword:|regexp:|include:) ]]; then
      echo "domain:$domain"
    else
      echo "$domain"
    fi
  done < data/russia-inside.raw
} > data/russia-inside

# Удалить временный файл
rm -f data/russia-inside.raw

# Показать статистику
total_lines=$(grep -c "^domain:" data/russia-inside || echo "0")
echo "✅ Конвертировано доменов: $total_lines"
