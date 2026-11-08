FROM alpine:3.20
RUN apk add --no-cache bash gawk coreutils
WORKDIR /app
COPY Processus.sh .
RUN chmod +x Processus.sh
CMD ["sh", "-c", "while true; do ./Processus.sh; sleep 10; done"]