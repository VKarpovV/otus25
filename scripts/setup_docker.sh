#!/bin/bash

# Проверяем, установлен ли Docker
if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose
    sudo systemctl enable --now docker
    echo "Docker установлен."
else
    echo "Docker уже установлен."
fi
