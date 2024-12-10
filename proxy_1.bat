@echo off
:: 选择网卡名称（通常是"Ethernet" 或 "Wi-Fi"）
set INTERFACE_NAME=以太网

:: 获取以太网的 IPv4 地址
for /f "tokens=1,2 delims=:" %%a in ('ipconfig ^| findstr /i "%INTERFACE_NAME%" ^| findstr /i "IPv4"') do (
    set eth_ip=%%b
)

:: 清除多余的空格
for /f "tokens=* delims= " %%c in ("%eth_ip%") do set eth_ip=%%c


:MENU
:: 显示菜单供用户选择操作
cls :: 清屏，以便每次显示时都是干净的界面

:: 显示当前网卡名称和当前 IP 地址
echo.
echo -------------------------------------------------------
echo 当前 IP 地址: %eth_ip%
echo -------------------------------------------------------
echo 此程序退出不影响代理使用，可放心退出！
echo -------------------------------------------------------
echo 请将正在使用的网络连接名称更改为以太网！
echo -------------------------------------------------------
echo.

echo 请选择操作:
echo 1. 开启代理
echo 2. 关闭代理
set /p choice=请输入选项 (1 或 2):

if "%choice%"=="1" goto STATIC_IP
if "%choice%"=="2" goto DHCP

:: 如果选择无效，重新显示菜单
echo 无效的选择，请重新选择。
pause
goto MENU

:STATIC_IP
:: 设置静态 IP 地址、子网掩码、默认网关和 DNS 服务器
set IP_ADDRESS=%eth_ip%
set SUBNET_MASK=255.255.255.0
set GATEWAY=192.168.10.3
set DNS1=223.6.6.6
set DNS2=8.8.8.8

:: 配置静态 IP 地址
netsh interface ip set address name="%INTERFACE_NAME%" static %IP_ADDRESS% %SUBNET_MASK% %GATEWAY%

:: 配置首选 DNS 服务器
netsh interface ip set dns name="%INTERFACE_NAME%" static %DNS1%

:: 配置备用 DNS 服务器
netsh interface ip add dns name="%INTERFACE_NAME%" %DNS2% index=2

echo 代理已开启！
pause
goto MENU

:DHCP
:: 切换到自动获取 IP 地址 (DHCP)
netsh interface ip set address name="%INTERFACE_NAME%" source=dhcp
netsh interface ip set dns name="%INTERFACE_NAME%" source=dhcp

echo 代理已关闭！
pause
goto MENU
