English | [简体中文](README_CN.md)
<p align="center">
    <a href="https://github.com/LanceHuang245/Unchained">
        <img src="public/logo.png" height="200"/>
    </a>
</p>

# Unchained
Unchained provides a GUI for Rathole, simplifies the process of configuring and managing multiple forwarding services, making the powerful features of Rathole more accessible to everyone.

## Features
- Intuitive graphical interface: Say goodbye to complex command lines and effortlessly manage forwarding services through a streamlined interface.
- Simplified configuration: Visualizes Rathole's configuration process, lowering the learning curve.
- Multi-service management: Conveniently add, edit, and delete multiple forwarding services.
- Clear status: View connection status in real time—successful or failed connections are immediately apparent.


## Usage Instructions
1. A server with a public IP address, with the required ports open in the firewall for connection and traffic.
2. Download [Rathole](https://github.com/rathole-org/rathole) and run the Rathole server on your server following the [README](https://github.com/rathole-org/rathole/blob/main/README.md), or use a pre-configured Rathole server provided by others
3. Run Unchained
4. In Unchained, enter the **bind.addr** and Token from the Rathole server's [server] section, along with the port address to be forwarded
5. Click Start Penetration. If “Control channel established” appears, penetration is successful. You can now connect to the **bind_addr** under [server.services.*] on the server.

## Screenshots
![Main](/public/main_idle.png)
![Main](/public/main_running.png)
![Settings](/public/settings.png)