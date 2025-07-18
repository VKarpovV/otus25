# Проект развертывания инфраструктуры с Docker

Автоматизированное развертывание распределенной инфраструктуры на трех виртуальных машинах.

## Состав инфраструктуры

- **VM1 (192.168.140.132)**:
  - Nginx (балансировщик нагрузки)
  - Apache1
  - MySQL Master

- **VM2 (192.168.140.133)**:
  - Apache2
  - MySQL Slave

- **VM3 (192.168.140.134)**:
  - Prometheus
  - Grafana
  - ELK-стек (Elasticsearch, Logstash, Kibana)

## Инструкция по развертыванию

1. **Клонирование репозитория на всех VM**:
   ```bash
   git clone https://github.com/VKarpovV/otus25.git
Настройка VM1:
bash

cd otus25
chmod +x setup_vm1.sh
./setup_vm1.sh

Сохраните значения MASTER_LOG_FILE и MASTER_LOG_POS из вывода.

Настройка VM2:
bash

cd otus25
chmod +x setup_vm2.sh
./setup_vm2.sh

Введите сохраненные значения MASTER_LOG_FILE и MASTER_LOG_POS.

Настройка VM3:
bash

    cd otus25
    chmod +x setup_vm3.sh
    ./setup_vm3.sh

Проверка работы

    Веб-серверы: http://192.168.140.132

    Prometheus: http://192.168.140.134:9090

    Grafana: http://192.168.140.134:3000 (admin/admin)

    Kibana: http://192.168.140.134:5601
