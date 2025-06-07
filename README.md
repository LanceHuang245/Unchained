<p align="center">
    <a href="https://github.com/ClaretWheel1481/Unchained">
        <img src="public/logo.png" height="200"/>
    </a>
</p>

# Unchained
辅助使用Rathole的远程穿透客户端。

## 使用方法
1. 一个拥有公网IP的服务器，并且防火墙开放需要连接及通行的端口
2. 下载[Rathole](https://github.com/rapiz1/rathole)并在服务端根据[README](https://github.com/yujqiao/rathole/blob/main/README-zh.md)运行Rathole服务端，或他人提供的已经准备就绪的Rathole服务端
3. 运行Unchained
4. 在Unchained中输入Rathole服务端的[server]下的**bind.addr**和Token，以及需要转发的端口地址
5. 点击开始穿透，显示Control channel established则表示穿透成功，此时连接服务端的[server.services.*]下的**bind_addr**即可。

## 致谢
[Rathole](https://github.com/rapiz1/rathole)
[Flutter](https://github.com/flutter/flutter)

## 截图
![Main](/public/main_idle.png)
![Main](/public/main_running.png)
![Settings](/public/settings.png)