FROM node:20

WORKDIR /app

COPY app/package*.json ./

RUN npm install

COPY app .

RUN npx open-next@3.1.3 build
