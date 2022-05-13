FROM node:16.15.0-alpine3.15

WORKDIR /usr/src/app/

COPY src/ /usr/src/app/
RUN npm install

EXPOSE 8080

CMD ["node", "/usr/src/app/ratings.js", "8080"]