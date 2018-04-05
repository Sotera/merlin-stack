#
# Dockerfile for samba (without netbios)
#

# Original location of docker base container
#FROM alpine:edge


FROM 52.0.211.45:5000/samba4-base
LABEL maintainer="robert.parkhurst@keywcorp.com"


# Run updates and install software
RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

# Expose necessary ports
EXPOSE 445/tcp


# script to perform our user management
COPY samba4_run.sh /

#RUN /samba4_run.sh
#CMD ["/samba4_run.sh"]
#ENTRYPOINT ["smbd", "--foreground", "--log-stdout"]
ENTRYPOINT [ "/samba4_run.sh" ]
