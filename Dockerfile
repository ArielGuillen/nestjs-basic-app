FROM node:18 as base
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM base as build
WORKDIR /app
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

FROM gcr.io/distroless/nodejs18-debian11 as pre-production
WORKDIR /app
ARG NODE_ENV=production 
ENV NODE_ENV=${NODE_ENV}
COPY --from=base /app/node_modules ./node_modules
COPY --from=build /app/dist/ .
EXPOSE 4000

FROM pre-production as production
WORKDIR /app
CMD ["main.js"]

