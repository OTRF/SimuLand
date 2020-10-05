# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# Referneces:
# https://github.com/mitre-attack/attack-arsenal/tree/master/adversary_emulation/APT29

FROM cyb3rward0g/docker-caldera:2.8.0-201004
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile FIN6 emulation plan"

USER ${USER}

COPY plugin $CALDERA_HOME/plugins/ctid_fin6
COPY conf/local.yml ${CALDERA_HOME}/conf/local.yml