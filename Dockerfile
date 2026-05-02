FROM debian:bookworm-slim

# 安装必要工具
RUN apt-get update && apt-get install -y \
    curl unzip ca-certificates nginx \
    && rm -rf /var/lib/apt/lists/*

# 创建非 root 用户（HF Spaces 推荐）
RUN useradd -m -u 1000 user
USER user
WORKDIR /home/user/app

# 下载最新 Xray
RUN curl -L -o /tmp/Xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.4.17/Xray-linux-64.zip \
    && unzip /tmp/Xray.zip -d /home/user/app/ \
    && chmod +x /home/user/app/xray \
    && rm /tmp/Xray.zip

# 复制配置文件
COPY --chown=user nginx.conf /etc/nginx/nginx.conf
COPY --chown=user config.json /home/user/app/config.json
COPY --chown=user index.html /home/user/app/index.html   # 伪装网页

# 创建必要的目录
RUN mkdir -p /home/user/app/logs

# 暴露 HF 要求的端口
EXPOSE 7860

# 使用 supervisord 或简单脚本同时启动 Nginx 和 Xray（这里用简单 & 后台方式）
CMD nginx && ./xray run -c /home/user/app/config.json
