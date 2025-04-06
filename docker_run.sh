#!/bin/bash

# Проверяем операционную систему
OS_TYPE=$(uname)

if [ "$OS_TYPE" = "Darwin" ]; then
    # Логика для macOS
    rm -rf ~/Library/Containers/com.docker.docker
    mkdir -p ~/goinfre/Docker/Data
    ln -s ~/goinfre/Docker ~/Library/Containers/com.docker.docker

    # Запускаем Docker Desktop
    open /Applications/Docker.app

    # Ожидаем запуска Docker
    while ! docker info >/dev/null 2>&1; do
        echo "Ожидание запуска Docker на macOS..."
        sleep 2
    done
else
    # Логика для Linux (и других ОС, кроме macOS)
    echo "Обнаружен Linux (или другая ОС). Пропускаем шаги для macOS..."
    while ! docker info >/dev/null 2>&1; do
        echo "Ожидание доступности Docker на Linux..."
        sleep 2
    done
fi

# Загружаем образ ubuntu:latest, если его нет
echo "Загрузка образа ubuntu:latest..."
docker pull ubuntu || { echo "Не удалось загрузить ubuntu:latest"; exit 1; }

# Проверяем, существует ли контейнер
if [ "$(docker ps -aq -f name=ubuntu_dev)" ]; then
    echo "Контейнер 'ubuntu_dev' существует. Запуск контейнера 'ubuntu_dev'..."
    # Если контейнер остановлен, запускаем его
    if [ -z "$(docker ps -q -f name=ubuntu_dev)" ]; then
        docker start ubuntu_dev
    fi
    docker exec -it -e TERM=xterm-256color ubuntu_dev zsh
else
    read -p "Введите ваше имя для GitHub: " GIT_NAME
    read -p "Введите ваш email для GitHub: " GIT_EMAIL

    echo "Контейнер 'ubuntu_dev' не найден. Создание нового образа и запуск контейнера 'ubuntu_dev'..."
    docker build -t ubuntu_dev . || { echo "Сборка образа провалилась."; exit 1; }
    docker run -it \
        -e TERM=xterm-256color \
        -e GIT_NAME="$GIT_NAME" \
        -e GIT_EMAIL="$GIT_EMAIL" \
        -v "$PWD:/ubuntu_dev" \
        -w /ubuntu_dev \
        --name ubuntu_dev \
        ubuntu_dev \
        /bin/bash -c "git config --global user.name '$GIT_NAME' && git config --global user.email '$GIT_EMAIL' && zsh"
fi
