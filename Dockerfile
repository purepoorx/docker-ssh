# 使用Ubuntu 作为基础镜像
FROM ubuntu

# 更新包并安装SSH服务
RUN apt-get update \
    && apt-get install -y openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置root用户密码为yin2na
RUN echo 'root:yin2na' | chpasswd

# 允许root密码登录
RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# 创建SSH服务需要的特权分离目录
RUN mkdir -p /run/sshd

# 防止"Could not load host key"错误
RUN ssh-keygen -A

# 暴露SSH端口
EXPOSE 22

WORKDIR /app

ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared

RUN chmod +x cloudflared

# 启动SSH服务
CMD ./cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN} & /usr/sbin/sshd -D
