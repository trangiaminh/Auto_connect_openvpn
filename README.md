# Auto_connect_openvpn
Auto connect OpenVPN (AutoIT)

1. Choose path file zbarimg.exe. (auto | show open dialog)
1. Choose path file openvpn-gui.exe. (auto | show open dialog)
2. Choose config ovpn (Config must be ran before)
3. Input username
4. Input password / Input secret key / Import secret key from QR code (use cmdline zbarimg).
If use secret key, password is generated by google authenticator (is implemented in source code).

Program will check setting file at startup time and enable auto connect OpenVPN.
When VPN connection have problem and need input user & pass again, program will automatic fill user & pass to connect again.
Or when OpenVPN isn't ran on system, program will automatic open OpenVPN and fill user & pass to connect VPN.

Source code (Auto_connect_openvpn.au3) is build on AutoIt version 3.3.14.2.

Link download: https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.exe

AutoIt Editor: https://www.autoitscript.com/cgi-bin/getfile.pl?../autoit3/scite/download/SciTE4AutoIt3.exe

AutoIt IDE: https://www.isnetwork.at/isn-downloads/
