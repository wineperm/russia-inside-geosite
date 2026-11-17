#!/bin/bash
set -e

echo "🔧 Применение пользовательских списков..."

DOMAINS_FILE="data/russia-inside"

# Обработать custom_deny.lst (исключения)
if [ -f custom_deny.lst ] && [ -s custom_deny.lst ]; then
  echo "➖ Применение исключений из custom_deny.lst..."
  
  # Создать временный файл
  cp "$DOMAINS_FILE" "${DOMAINS_FILE}.tmp"
  
  # Удалить домены из списка исключений
  while IFS= read -r deny_domain; do
    # Пропустить пустые строки и комментарии
    [[ -z "$deny_domain" || "$deny_domain" =~ ^# ]] && continue
    
    # Очистить домен
    deny_domain=$(echo "$deny_domain" | xargs)
    
    # Удалить из списка (точное совпадение)
    grep -v "^domain:$deny_domain$" "${DOMAINS_FILE}.tmp" > "${DOMAINS_FILE}.tmp2" || true
    mv "${DOMAINS_FILE}.tmp2" "${DOMAINS_FILE}.tmp"
    
    echo "  Удалён: $deny_domain"
  done < custom_deny.lst
  
  mv "${DOMAINS_FILE}.tmp" "$DOMAINS_FILE"
fi

# Обработать custom_allow.lst (добавления)
if [ -f custom_allow.lst ] && [ -s custom_allow.lst ]; then
  echo "➕ Применение добавлений из custom_allow.lst..."
  
  while IFS= read -r allow_domain; do
    # Пропустить пустые строки и комментарии
    [[ -z "$allow_domain" || "$allow_domain" =~ ^# ]] && continue
    
    # Очистить домен
    allow_domain=$(echo "$allow_domain" | xargs)
    
    # Проверить, нет ли уже такого домена
    if ! grep -q "^domain:$allow_domain$" "$DOMAINS_FILE"; then
      echo "domain:$allow_domain" >> "$DOMAINS_FILE"
      echo "  Добавлен: $allow_domain"
    fi
  done < custom_allow.lst
fi

# Сортировать и удалить дубликаты
sort -u "$DOMAINS_FILE" > "${DOMAINS_FILE}.sorted"
mv "${DOMAINS_FILE}.sorted" "$DOMAINS_FILE"

echo "✅ Пользовательские списки применены"
