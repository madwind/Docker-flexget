FROM docker.io/python:3.13-alpine3.20
COPY requirements.txt /tmp
RUN set -eux  && \
    apk add --no-cache --upgrade \
        g++ \
        libffi-dev  && \
    pip install -r /tmp/requirements.txt --root /root-dir --no-warn-script-location && \
    find /root-dir/usr/local -depth \
	\( \
		\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
		-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
	\) -exec rm -rf '{}' +
COPY root /root-dir

FROM docker.io/python:3.13-alpine3.20
ENV PYTHONUNBUFFERED=1
COPY --from=0 /root-dir /
RUN set -eux  && \
    apk add --no-cache --upgrade \
        ca-certificates \
        tzdata \
        shadow \
	libstdc++ && \
    rm -rf /var/cache/apk/*  && \
    groupmod -g 1000 users && \
    useradd -mUu 911 flexget && \
    usermod -G users flexget && \
    chmod +x /usr/bin/entrypoint.sh
VOLUME /config /downloads
WORKDIR /config
EXPOSE 3539
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
