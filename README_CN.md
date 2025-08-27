[English](README.md) | 简体中文

<p align="center">
    <a href="https://github.com/LanceHuang245/Unchained">
        <img src="public/logo.png" height="200"/>
    </a>
</p>

# Unchained
Unchained为内网穿透工具Rathole提供了一款直观的GUI，旨在简化Rathole的配置和管理流程，帮助用户轻松地同时转发和管理多个服务，让强大的Rathole变得更加简单易用。

## 特性
- 直观图形界面：告别复杂命令行，通过简洁界面轻松管理转发服务。
- 简化配置流程：可视化呈现Rathole配置过程，降低学习门槛。
- 多服务管理：便捷添加、编辑及删除多个转发服务。
- 清晰状态显示：实时查看连接状态——成功或失败的连接一目了然。

## 使用方法
1. 准备一个拥有公网IP的服务器，并且防火墙开放需要连接及通行的端口
2. 下载[Rathole](https://github.com/rathole-org/rathole)并在服务端根据[README](https://github.com/rathole-org/rathole/blob/main/README-zh.md)运行Rathole服务端，或他人提供的已经准备就绪的Rathole服务端
3. 运行Unchained
4. 在Unchained中输入Rathole服务端的[server]下的**bind.addr**和Token，以及需要转发的端口地址
5. 点击开始穿透，显示Control channel established则表示穿透成功，此时连接服务端的[server.services.*]下的**bind_addr**即可。

## 截图
![Main](/public/main_idle.png)
![Main](/public/main_running.png)
![Settings](/public/settings.png)