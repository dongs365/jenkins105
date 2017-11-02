#!/bin/bash

 

#build in jenkins 

 

# 你的docker 仓库的地址 

REG_URL=XXX

 

#你的swarm manage 节点的地址

SWARM_MANAGE_URL=xx:2376

 

#根据时间生成版本号

TAG=$REG_URL/$JOB_NAME:`date +%y%m%d-%H-%M`

 

#使用maven 镜像进行编译 打包出 war 文件 （其他语言这里换成其他编译镜像）

docker run --rm --name mvn  -v /mnt/maven:/root/.m2   \

 -v /mnt/jenkins_home/workspace/$JOB_NAME:/usr/src/mvn -w /usr/src/mvn/\

 maven:3.3.3-jdk-8 mvn clean install -Dmaven.test.skip=true

  

#使用我们刚才写好的 放在项目下面的Dockerfile 文件打包 

docker build -t  $TAG  $WORKSPACE/.

docker push   $TAG

docker rmi $TAG

 

 

# 如果有以前运行的版本就删了 

if docker -H $SWARM_MANAGE_URL ps -a| grep -i $JOB_NAME; then

        docker -H $SWARM_MANAGE_URL rm -f  $JOB_NAME

fi

 

#运行到集群

docker -H $SWARM_MANAGE_URL run  -d  -p 80:8080  --name $JOB_NAME  $TAG
