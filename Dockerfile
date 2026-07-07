FROM alpine:3.18
RUN apk add --no-cache bash postgresql-client
COPY simuladorcpu.sh /simuladorcpu.sh
RUN chmod +x /simuladorcpu.sh
CMD ["/bin/bash", "/simuladorcpu.sh"]
