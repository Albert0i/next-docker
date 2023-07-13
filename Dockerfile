FROM mcr.microsoft.com/windows/nanoserver:20H2 as builder

WORKDIR /app
COPY *.json *.js node-v18.16.1-win-x64.zip ./

# Add NodeJS to search path 
ENV PATH="C:\Windows\system32;C:\Windows;C:\app\node-v18.16.1-win-x64;"
 
# Because we don't have PowerShell, we will install using CURL and TAR
RUN tar.exe -xf node-v18.16.1-win-x64.zip && \
    del node-v18.16.1-win-x64.zip 

COPY src src

RUN npm ci && \
    npm run build 

### 
FROM mcr.microsoft.com/windows/nanoserver:20H2 as runner 

WORKDIR /app
COPY node-v18.16.1-win-x64.zip ./

# Add NodeJS to search path 
ENV PATH="C:\Windows\system32;C:\Windows;C:\app\node-v18.16.1-win-x64;"

# Because we don't have PowerShell, we will install using CURL and TAR
RUN tar.exe -xf node-v18.16.1-win-x64.zip && \
    del node-v18.16.1-win-x64.zip 

COPY --from=builder /app/.next/standalone .next/standalone
COPY --from=builder /app/.next/static .next/standalone/.next/static
COPY public .next/standalone/public

EXPOSE 3000
ENTRYPOINT ["node", ".next/standalone/server.js"]

#
# docker build -t nextjs-docker .
# docker run -p 3000:3000 nextjs-docker
#

#
# With Docker
# https://github.com/vercel/next.js/blob/canary/examples/with-docker/README.md
#
# Creating a Docker Image of Your Nextjs App
# https://www.locofy.ai/blog/create-a-docker-image-of-your-nextjs-app
# 
# NextJS | Output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
#
#RUN curl.exe -o node-v18.16.1-win-x64.zip -L https://nodejs.org/dist/v18.16.1/node-v18.16.1-win-x64.zip && \
#    tar.exe -xf node-v18.16.1-win-x64.zip && \
#    del node-v18.16.1-win-x64.zip 
#
# (2023/07/13)
# 