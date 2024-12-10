::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCuDJNFZO8rn55ygnTjTcmK5CdU=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF65
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCuDJNFZO8rn55ygnTgG56g99lOUNSR9AijJp1UYNA==
::YB416Ek+ZW8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
:: 获取所有网络适配器名称并显示给用户选择
:SELECT_ADAPTER
setlocal enabledelayedexpansion
set "count=0"
echo 可用的网络适配器列表:
echo --------------------------------------------

:: 使用 netsh 列出所有网络接口名称
for /f "tokens=1,2,3,*" %%a in ('netsh interface show interface ^| findstr /i "已启用"') do (
    set /a count+=1
    echo !count!. %%d
    set "adapter!count!=%%d"
)

if %count%==0 (
    echo 未检测到任何可用的网络适配器，请检查网络环境。
    pause
    exit
)

:: 让用户选择目标网卡
:CHOOSE_ADAPTER
set /p choice=请输入要设置代理的目标网络适配器编号 (1-%count%): 

:: 验证输入是否在范围内
if %choice% gtr %count% (
    echo 输入编号超出范围，请重新选择。
    pause
    goto CHOOSE_ADAPTER
)

if %choice% lss 1 (
    echo 输入编号无效，请重新选择。
    pause
    goto CHOOSE_ADAPTER
)

:: 获取用户选择的网络适配器名称
set INTERFACE_NAME=!adapter%choice%!

:: 获取用户选择的网络适配器 IPv4 地址
:: 启用延迟变量扩展
setlocal enabledelayedexpansion

:: 初始化变量
set eth_ip=
set in_interface=false

:: 获取ipconfig输出并逐行检查
for /f "tokens=*" %%a in ('ipconfig') do (
    :: 查找网络适配器名称并设置标记
    echo %%a | findstr /i "%INTERFACE_NAME%" >nul
    if not errorlevel 1 (
        set in_interface=true
    )

    :: 如果已经找到目标网络适配器，查找IPv4地址
    if defined in_interface (
        echo %%a | findstr /i "IPv4" >nul
        if not errorlevel 1 (
            for /f "tokens=2 delims=:" %%b in ("%%a") do set eth_ip=%%b
        )
    )
)

:: 去掉 IP 地址前的空格
set eth_ip=!eth_ip: =!

:: 只输出网络适配器名称和对应的 IPv4 地址
echo 选择的网卡为: %INTERFACE_NAME%
echo 该网络适配器的 IPv4 地址是: !eth_ip!

pause
:MENU
:: 显示菜单供用户选择操作
cls
echo -------------------------------------------------------
echo 当前网络适配器名称: %INTERFACE_NAME%
if defined eth_ip (
    echo 当前 IP 地址: !eth_ip!
) else (
    echo 当前 IP 地址: 未分配或无法获取
    echo 提示: 请确保网络适配器已连接网络或已分配 IP 地址。
)
echo -------------------------------------------------------
echo 此程序退出不影响代理使用，可放心退出
echo 如遇网卡IP地址不正确，可使用恢复默认后重新选择网络适配器
echo -------------------------------------------------------
echo 请选择操作:
echo 1. 开启代理
echo 2. 关闭代理 恢复默认
echo 3. 重新选择网络适配器
echo 4. 退出程序
set /p action=请输入选项 (1, 2, 3 或 4): 

if "%action%"=="1" goto STATIC_IP
if "%action%"=="2" goto DHCP
if "%action%"=="3" goto SELECT_ADAPTER
if "%action%"=="4" exit

:: 如果选择无效，重新显示菜单
echo 无效的选择，请重新输入。
pause
goto MENU

:STATIC_IP
:: 设置静态 IP 地址、子网掩码、默认网关和 DNS 服务器
if not defined eth_ip (
    echo 无法设置代理，因为当前网络适配器未分配 IP 地址。
    pause
    goto MENU
)

set IP_ADDRESS=!eth_ip!
set SUBNET_MASK=255.255.255.0
set GATEWAY=192.168.10.3
set DNS1=202.103.24.68
set DNS2=202.103.44.150

:: 配置静态 IP 地址
netsh interface ip set address name="%INTERFACE_NAME%" static %IP_ADDRESS% %SUBNET_MASK% %GATEWAY%
netsh interface ip set dns name="%INTERFACE_NAME%" static %DNS1%
netsh interface ip add dns name="%INTERFACE_NAME%" %DNS2% index=2

echo 代理已开启！
pause
goto MENU

:DHCP
:: 切换到自动获取 IP 地址 (DHCP)
netsh interface ip set address name="%INTERFACE_NAME%" source=dhcp
netsh interface ip set dns name="%INTERFACE_NAME%" source=dhcp

echo 代理已关闭，网络适配器已恢复为默认！
pause
goto MENU
