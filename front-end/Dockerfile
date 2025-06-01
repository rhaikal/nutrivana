FROM node:lts-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

ARG VITE_BACKEND_URL
RUN echo "VITE_BACKEND_URL=$VITE_BACKEND_URL" > .env.production

RUN npm run build
RUN npm install -g serve

EXPOSE 3000
CMD ["serve", "-s", "dist"]