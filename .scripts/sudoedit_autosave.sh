#!/usr/bin/bash

# Функция для получения абсолютного пути к файлу
abs_filepath() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# Функция для копирования содержимого файла с правами sudo
su_cat() {
    sudo sh -c 'cat "$1" > "$2"' -- "$1" "$2"
}

# Получаем имя файла, путь и расширение
file_name="${1##*/}"
file_path="$(abs_filepath "$1")"
# Проверяем наличие расширения у файла
extension=$([[ "$file_name" = ?*.* ]] && printf ".%s" "${file_name##*.}" || printf '')
# Создаем временный файл с уникальным именем
tmp="$(mktemp /var/tmp/"$file_name".XXXXXXXXXXXX"$extension")"

# Если исходный файл существует, копируем его содержимое во временный файл
[ -f "$file_path" ] && sudo cat "$file_path" > "$tmp"

# Запускаем фоновый процесс для отслеживания изменений временного файла
(
    while true; do
        # Ожидаем события изменения файла
        _=$(inotifywait -q -e create -e moved_to -e close_write "$tmp")
        # Если файл существует, копируем его содержимое в исходный файл
        if [ -f "$tmp" ]; then
            su_cat "$tmp" "$file_path"
        fi
    done
) &

# Сохраняем PID фонового процесса
listener_pid=$!

# Открываем временный файл в редакторе
$EDITOR "$tmp"

# Останавливаем фоновый процесс
kill $listener_pid

# Ожидаем завершения фонового процесса
while $(kill -0 $listener_pid 2>/dev/null); do
    sleep 0.5
done

# Последний раз копируем содержимое временного файла в исходный
su_cat "$tmp" "$file_path"

# Удаляем временный файл
rm "$tmp"
