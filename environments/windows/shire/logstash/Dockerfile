# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM docker.elastic.co/logstash/logstash:7.7.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"

# ** Updating kafka integration plugin to 10.1.0
# Reference: https://github.com/logstash-plugins/logstash-integration-kafka/pull/8
RUN logstash-plugin update logstash-integration-kafka