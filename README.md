# CloudPlatformOperations

## 1. 使用说明
* 关闭云平台服务，所有节点关机、重启操作
```shell
  # cd /root/CloudPlatformOperations/bin
  # ./stop-all.sh
```
安装字符提示，确认云平台关闭，关机、重启操作即可。

* 启动云平台操作
```shell
  # cd /root/CloudPlatformOperations/bin
  # ./start-all.sh
```
## 2. 注意事项
启动云平台时需要按顺序进行连通性检测、消息队列集群启动、Galera数据库集群启动、云服务启动、Ceph集群状态检测和Rest-api服务启动、计算节点服务启动、虚拟机状态恢复、管理系统Web服务器启动等操作，如果中间发生错误，启动流程会失败，需要手动排故障才能恢复。
