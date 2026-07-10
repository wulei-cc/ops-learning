# 个人WordPress博客部署完整记录
## 一、部署环境信息
- 云服务器：阿里云ECS 2核4G 
- 操作系统：CentOS 7.9 x86_64 
- Web服务：Nginx 1.x 
- 数据库：MariaDB 10.x 
- PHP版本：PHP-FPM 7.4 
- 博客程序：WordPress 中文官方版 
- 服务器公网IP：121.40.24.177 

问题1:Nginx 启动后访问不了

原因：阿里云安全组没放行80端口
解决：控制台→安全组→添加规则，放行TCP 80端口
