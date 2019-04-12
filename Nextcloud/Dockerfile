
FROM ubuntu:18.04

COPY ./Scripts/NextcloudInstall.sh /app/NextcloudInstall.sh
COPY ./Scripts/NextcloudStart.sh /app/NextcloudStart.sh

ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
&& chmod +x /app/NextcloudInstall.sh \
&& chmod +x /app/NextcloudStart.sh \
&& /bin/bash /app/NextcloudInstall.sh

CMD /bin/bash /app/NextcloudStart.sh \
&& tail -f /dev/null

EXPOSE 80/tcp
EXPOSE 80/udp

EXPOSE 443/tcp
EXPOSE 443/udp