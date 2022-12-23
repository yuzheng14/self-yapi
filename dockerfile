FROM yuzheng14/self-use-ubuntu

LABEL maintainer="yuzheng14"

SHELL [ "/bin/zsh", "-c" ]

WORKDIR /root

# 安装 gpupg 并导入 mongodb 的 public key
RUN apt install -y gnupg && \
  wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -

# 创建 mongodb 的 apt 源列表
RUN touch /etc/apt/sources.list.d/mongodb-org-6.0.list && \
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# 更新软件列表
RUN apt update 

# 设定时区
ENV TZ=Asia/Shanghai
# 非交互模式安装（以免 tzdata 阻塞进程）
RUN DEBIAN_FRONTEND=noninteractive apt install -y mongodb-org

RUN mkdir yapi

WORKDIR /root/yapi

RUN git clone --depth=1 https://github.com/YMFE/yapi.git vendors

RUN echo $'\n\
  {\n\
  "port": "3000",\n\
  "adminAccount": "admin@admin.com",\n\
  "timeout":120000,\n\
  "db": {\n\
  "servername": "127.0.0.1",\n\
  "DATABASE": "yapi",\n\
  "port": 27017\n\
  }\n\
  }\n\
  ' >> config.json

WORKDIR /root/yapi/vendors

RUN npm install --production

RUN source ~/.zshrc && nvm install 12 && nvm use 12

EXPOSE 3000

# CMD source ~/.zshrc \
#   && nvm use 12 \
#   && nohup mongod & \
#   && npm run install-server \
#   && node server/app.js

# CMD [ "source ~/.zshrc", "nvm use 12","nohup mongod &","npm run install-server","node server/app.js" ]

COPY start.sh .
COPY db /data/db
COPY init.lock ../

# ENTRYPOINT [ "start.sh" ]
CMD [ "zsh","start.sh" ]