FROM raspbian/stretch

RUN apt-get update -y \
 && apt-get update -y \
 && apt-get install -y jq less curl \
 && mkdir -p /opt/hnt_monitor

COPY src/ /opt/hnt_monitor/
COPY build/docker/entrypoint /

RUN chmod 755 /entrypoint

ENTRYPOINT ["./entrypoint"]
