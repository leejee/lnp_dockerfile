# lnp_dockerfile
通过dockerfile 生成包含centos+nginx+php的docker镜像

#### docker version：1.7.1

## 镜像说明：

本镜像为常用的web服务镜像（nginx+php），使用supervisor管理nginx和php。

#### 镜像内服务：

	基础镜像centos6

	nginx-1.12.2

	php-5.6.33
	
	supervisor

#### 镜像内服务安装目录：

	/home/work/lnp/nginx  nginx目录

	/home/work/lnp/php  php-fpm目录

	/home/work/vhost  自定义虚拟目录

	/home/work/webroot  web程序目录

	/home/work/logs  日志目录

#### 容器开放端口：8080

## 使用示例

docker build -t lnp .

docker run -d --name lnp_app -p 80:8080 -v /home/users/vhost:/home/work/vhost -v /home/users/webroot:/home/work/webroot lnp

curl http://127.0.0.1 (需要在宿主存在/home/users/webroot/html/index.html)

#### 参数说明：

容器内使用work账户运行

映射宿主机 80 端口到 容器的8080
	
挂在宿主主机目录 /home/users/vhost /home/users/webroot

在/home/users/vhost/*.conf 中配置个性化虚拟目录

在/home/users/webroot 中存在web程序

默认使用/home/users/webroot/html 为入口文件目录。参考：nginx.conf

#### web服务log日志对应的宿主主机目录：

docker inspect -f '{{.Volumes}}' CONTAINER
