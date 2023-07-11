FROM mcr.microsoft.com/windows/nanoserver:20H2 as builder

WORKDIR /app
COPY package.json package-lock.json node-v18.16.1-win-x64.zip VC_redist.x64.exe ./

# Add NodeJS to search path 
ENV NODE_VERSION=18.16.1
ENV PATH="C:\Windows\system32;C:\Windows;C:\app\node-v18.16.1-win-x64;"
 
# Because we don't have PowerShell, we will install using CURL and TAR
RUN tar.exe -xf node-v18.16.1-win-x64.zip && \
    del node-v18.16.1-win-x64.zip && \
    start /w VC_redist.x64.exe /install /quiet /norestart && \
    del VC_redist.x64.exe

RUN npm ci 

COPY . .

RUN npm run build 

### 

FROM mcr.microsoft.com/windows/nanoserver:20H2 as runner 

WORKDIR /app
COPY package.json package-lock.json node-v18.16.1-win-x64.zip VC_redist.x64.exe ./

# Add NodeJS to search path 
ENV NODE_VERSION=18.16.1
ENV PATH="C:\Windows\system32;C:\Windows;C:\app\node-v18.16.1-win-x64;"

USER ContainerAdministrator
# Because we don't have PowerShell, we will install using CURL and TAR
RUN tar.exe -xf node-v18.16.1-win-x64.zip && \
    del node-v18.16.1-win-x64.zip && \
    start /w VC_redist.x64.exe /install /quiet /norestart && \
    del VC_redist.x64.exe

COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
ENTRYPOINT ["npm", "start"]

#
# docker build -t nextjs-docker .
# docker run -p 3000:3000 nextjs-docker
#

#
# Creating a Docker Image of Your Nextjs App
# https://www.locofy.ai/blog/create-a-docker-image-of-your-nextjs-app
# 

#
# (2023/07/11)
# 