FROM node

MAINTAINER Tadeusz Łazurski <tadeusz@lazurski.pl>

RUN mkdir /app
RUN npm i -g forever

ADD . /app
WORKDIR /app

RUN npm i
RUN npm run-script build

EXPOSE 3210

CMD ["forever", "build/backend/app.js"]
