下面是一份可复用的 **Ubuntu 22.04 云服务器部署 3x-ui 操作手册**。默认你已经用 `root` 登录服务器。

**目标**
部署 3x-ui Web 管理面板，面板端口 `2053`，账号 `yanzo`，密码 `yanzo`。后续如果要配置入站节点，例如 `443`，还要单独放行对应端口。

**1. 安装 Docker**

```bash
apt update
apt install -y ca-certificates curl gnupg

rm -f /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.sources
rm -f /etc/apt/keyrings/docker.asc /etc/apt/keyrings/docker.gpg

install -m 0755 -d /etc/apt/keyrings

curl -fsSL http://mirrors.cloud.aliyuncs.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

tee /etc/apt/sources.list.d/docker.list >/dev/null <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] http://mirrors.cloud.aliyuncs.com/docker-ce/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable
EOF

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

docker version
docker compose version
```

**2. 配置 Docker 镜像加速**

把你的阿里云加速器写入 Docker 配置：

```bash
mkdir -p /etc/docker

tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "registry-mirrors": [
    "https://fu37pz78.mirror.aliyuncs.com"
  ]
}
EOF

systemctl daemon-reload
systemctl restart docker

docker info | grep -A 10 "Registry Mirrors"
```

**3. 部署 3x-ui**

```bash
mkdir -p /opt/3x-ui
cd /opt/3x-ui
mkdir -p db cert

tee docker-compose.yml >/dev/null <<'EOF'
services:
  3xui:
    image: ghcr.io/mhsanaei/3x-ui:latest
    container_name: 3xui_app
    restart: unless-stopped
    tty: true
    cap_add:
      - NET_ADMIN
      - NET_RAW
    volumes:
      - ./db/:/etc/x-ui/
      - ./cert/:/root/cert/
    environment:
      XRAY_VMESS_AEAD_FORCED: "false"
      XUI_ENABLE_FAIL2BAN: "true"
    ports:
      - "2053:2053"
      - "443:443"
EOF

docker compose pull
docker compose up -d

docker ps
```

`restart: unless-stopped` 会保证容器长期运行，服务器重启后也会自动恢复。

**4. 设置面板账号密码**

```bash
docker exec 3xui_app /app/x-ui setting -username yanzo -password yanzo
docker restart 3xui_app
```

建议后续登录面板后改成更强密码，不要长期使用 `yanzo/yanzo`。

**5. 检查运行状态**

```bash
docker ps
docker inspect -f 'Status={{.State.Status}} Restart={{.HostConfig.RestartPolicy.Name}} RestartCount={{.RestartCount}}' 3xui_app
ss -lntp | grep -E ':2053|:443'
docker logs --tail=100 3xui_app
```

访问地址：

```text
http://你的ECS公网IP:2053
```

**6. 阿里云安全组**

阿里云控制台进入：

```text
ECS 实例 -> 安全组 -> 入方向规则
```

至少放行：

```text
TCP 2053    用于 3x-ui 面板
TCP 443     用于后续入站节点测试
```

安全建议：

```text
2053 面板端口：建议只允许你的本地公网 IP/32
443 测试端口：按你的测试需求放行
```

**7. 常用维护命令**

查看状态：

```bash
cd /opt/3x-ui
docker compose ps
docker logs --tail=100 3xui_app
```

重启：

```bash
cd /opt/3x-ui
docker compose restart
```

更新：

```bash
cd /opt/3x-ui
docker compose pull
docker compose up -d
```

停止：

```bash
cd /opt/3x-ui
docker compose down
```

重新启动：

```bash
cd /opt/3x-ui
docker compose up -d
```

**8. 常见问题**

如果浏览器打不开，优先检查：

```bash
docker ps
ss -lntp | grep 2053
```

然后检查阿里云安全组是否放行 `2053/TCP`。

如果 `curl -I http://127.0.0.1:2053` 显示 `Connection reset by peer`，不一定是失败，可能是面板不处理 `HEAD` 请求。直接用浏览器访问，或查看日志：

```bash
docker logs --tail=100 3xui_app
```

参考文档：[Docker Ubuntu 安装文档](https://docs.docker.com/engine/install/ubuntu/)、[MHSanaei/3x-ui 官方仓库](https://github.com/MHSanaei/3x-ui)、[3x-ui 官方容器镜像](https://github.com/mhsanaei/3x-ui/pkgs/container/3x-ui)。



https://www.youtube.com/watch?v=unyXGtmYWfk