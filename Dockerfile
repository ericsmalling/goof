FROM node:14.1.0

RUN mkdir /usr/src/goof
RUN mkdir /tmp/extracted_files
COPY . /usr/src/goof
WORKDIR /usr/src/goof

RUN npm ci --only=production
EXPOSE 3001
EXPOSE 9229
ENTRYPOINT ["npm", "start"]
