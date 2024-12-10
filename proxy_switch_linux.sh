#!/bin/bash

# 选择网络接口名称
select_interface() {
  # 获取所有网络接口名称
  interfaces=$(ls /sys/class/net)

  # 如果没有找到网络接口，退出
  if [ -z "$interfaces" ]; then
    echo "没有找到网络接口。"
    exit 1
  fi

  # 显示所有网络接口，并让用户选择
  echo "请选择一个网络接口配置代理(输入数字进行选择)："
  select interface in $interfaces; do
    if [ -n "$interface" ]; then
      echo "您选择的网络接口是：$interface"
      selected_interface=$interface
      break
    else
      echo "无效的选择，请重新选择。"
    fi
  done
}

# DHCP 模式
DHCP_MODE() {
  echo "正在关闭代理..."
  sudo networksetup -setdhcp "$INTERFACE"
  echo "代理已关闭."
}

# 静态模式
STATIC_MODE() {
  IP_ADDRESS=$CURRENT_IP
  SUBNET_MASK="255.255.255.0"
  ROUTER="192.168.10.3"

  echo "正在开启代理..."
  sudo networksetup -setmanual "$INTERFACE" "$IP_ADDRESS" "$SUBNET_MASK" "$ROUTER"
  echo "代理已成功开启."
}

# 检查接口是否有效（获取 IP 地址）
check_interface() {
  # 获取当前 IP 地址（使用 ip 命令代替 ifconfig）
  CURRENT_IP=$(ip addr show "$INTERFACE" | grep inet | awk '{print $2}' | cut -d/ -f1)
  
  # 检查是否获取到有效的 IP 地址
  if [ -z "$CURRENT_IP" ]; then
    echo "无法获取 IP 地址。请检查网络连接。"
    return 1  # 如果 IP 无效，返回 1
  else
    echo "当前 IP 地址是: $CURRENT_IP"
    return 0  # 如果 IP 有效，返回 0
  fi
}

# 显示菜单
show_menu() {
  clear

  # 如果没有选择网络接口，则让用户选择
  if [ -z "$selected_interface" ]; then
    select_interface
  fi

  INTERFACE=$selected_interface  # 配置网络接口的名称
  
  # 检查网络接口是否有效
  if ! check_interface; then
    echo "网络接口无效或未配置正确，重新选择网络接口..."
    selected_interface=""  # 清除已选择的接口，重新选择
    return  # 返回菜单，重新选择接口
  fi
  
  echo 此脚本无需后台保持，用完即可关闭，也可不关闭方便切换
  echo "====================================="
  echo "  代理开关切换"
  echo "====================================="
  echo "1. 开启代理"
  echo "2. 关闭代理"
  echo "3. 重新选择网络接口"
  echo "4. 退出"
  echo "====================================="
  read -p "请输入选项 [1-4]: " choice
}

# 执行菜单选项
execute_choice() {
  case $choice in
    1)
      STATIC_MODE
      ;;
    2)
      DHCP_MODE
      ;;
    3)
      echo "重新选择网络接口..."
      selected_interface=""  # 清除已选择的接口，重新选择
      ;;
    4)
      echo "退出脚本..."
      exit 0
      ;;
    *)
      echo "无效的选项，请选择 [1-4]."
      ;;
  esac
}

# 主程序循环
while true; do
  show_menu
  execute_choice
  read -p "操作完成，按 [Enter] 继续..."
done
