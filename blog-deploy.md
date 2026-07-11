# 阿里云ECS部署WordPress博客 — 故障排查记录

## 环境信息
- 服务器：阿里云ECS（CentOS 7.9）
- Web服务：Nginx
- 数据库：MariaDB
- 应用：WordPress（PHP）
## 问题1：Nginx欢迎页无法访问
**现象**：浏览器输入 http://公网IP，长时间等待后显示"无法连接"
**排查过程**：
1. 服务器内部测试：curl localhost→ 正常返回，说明Nginx本身在运行
2. 检查监听端口：netstat -tlnp | grep :80→ Nginx正在监听80端口
**根因**：阿里云ECS的安全组默认只放行22端口（SSH），未放行80端口（HTTP）
**解决方案**：
登录阿里云找到安全组添加规则把端口设置为80端口访问来源设计为任何位置

## 问题2：WordPress页面403 Forbidden / 空白页
**现象**：Nginx欢迎页正常，但访问WordPress安装页面时出现403 Forbidden或完全空白
**排查过程（按顺序）**：
### 2.1 检查文件位置
### 检查文件位置
ls -la /usr/share/nginx/html/
如果发现文件在root下面的话Nginx是无法读取内容
**根因**：`/root` 目录的默认权限为700，只有root用户可以访问，nginx用户无读权限
**解决**：mv /root/wordpress/* /usr/share/nginx/html/
### 2.2 检查文件权限
ls -la /usr/share/nginx/html/
文件属主为root:root，nginx用户无读权限
**解决**：
chown -R nginx:nginx /usr/share/nginx/html/
### 2.3 检查PHP-FPM状态
systemctl status php-fpm
如果发现php-fpm未启动
**解决**：
systemctl start php-fpm
systemctl enable php-fpm
### 2.4 检查Nginx配置
cat /etc/nginx/conf.d/default.conf
 fastcgi_pass配置指向错误端口
**解决**：
确认fastcgi_pass指向php-fpm监听地址（通常为127.0.0.1:9000）
nginx -t              # 测试配置语法
systemctl reload nginx # 热重载配置
## 问题3：配置完成后仍显示Nginx默认欢迎页
**现象**：所有配置看起来正确，但访问网站仍显示"Welcome to CentOS/Nginx"
**排查过程**：
nginx -t              # 检查配置语法
grep -r "listen 80" /etc/nginx/  # 查找所有监听80端口的配置
**根因**：Nginx主配置（`/etc/nginx/nginx.conf`）和站点配置（`/etc/nginx/conf.d/default.conf`）中各有一个 `server` 块同时监听80端口，Nginx选择了默认server块返回欢迎页
**解决**：
注释掉nginx.conf中的默认server块，或删除多余的conf.d配置文件
# 删除冲突的默认配置
rm -f /etc/nginx/conf.d/多余的文件名.conf
systemctl reload nginx
## 问题4：WordPress数据库连接错误
**现象**：WordPress安装向导提示"建立数据库连接时出错"
**排查过程**：
1. 检查数据库服务状态：`systemctl status mariadb` → 未启动
2. 启动后仍报错 → 检查数据库用户权限
**根因**：① MariaDB服务未启动 ② 数据库用户权限未正确授予
**解决**：
# 启动数据库
systemctl start mariadb
systemctl enable mariadb
# 检查并授予权限
mysql -u root -p
-- 确认数据库存在
SHOW DATABASES;
