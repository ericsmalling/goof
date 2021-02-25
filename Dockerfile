FROM ericsmalling/custom-node:10.23.1-buster-slim

RUN mkdir /tmp/extracted_files
COPY --chown=node . /usr/src/node

RUN npm update
RUN npm install
EXPOSE 3001
EXPOSE 9229
ENTRYPOINT ["npm", "start"]
