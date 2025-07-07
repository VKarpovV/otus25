# Установка Elasticsearch
sudo dpkg -i /home/kva/elk-8.9-deb/elasticsearch-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/elasticsearch/elasticsearch.yml /etc/elasticsearch/
sudo chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Установка Logstash
sudo dpkg -i /home/kva/elk-8.9-deb/logstash-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/logstash/logstash.conf /etc/logstash/conf.d/
sudo chown root:logstash /etc/logstash/conf.d/logstash.conf
sudo systemctl enable logstash
sudo systemctl start logstash

# Установка Kibana
sudo dpkg -i /home/kva/elk-8.9-deb/kibana-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/kibana/kibana.yml /etc/kibana/
sudo chown root:kibana /etc/kibana/kibana.yml
sudo systemctl enable kibana
sudo systemctl start kibana

echo "ELK stack установлен и настроен!"
