# Auto_connect_openvpn
Auto connect OpenVPN (AutoIT)

1. Choose path file zbarimg.exe. (auto | show open dialog)
1. Choose path file openvpn-gui.exe. (auto | show open dialog)
2. Choose config ovpn (Config must be ran before)
3. Input username
4. Import secret key from QR code image (use cmdline zbarimg) and password is generated by google authenticator (is implemented in source code).

Program will check setting file at startup time and enable auto connect OpenVPN.
When VPN connection have problem and need input user & pass again, program will automatic fill user & pass to connect again.
Or when OpenVPN isn't ran on system, program will automatic open OpenVPN and fill user & pass to connect VPN.
