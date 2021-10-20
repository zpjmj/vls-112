# vls-112 README
基于vlang官方语言服务器vls的代码框架构建。只实现定义跳转功能。

## Download / Installation
目前存在内存泄露,每次跳转泄露0.1Mb左右
1. 需要配合vscode插件`vscode-vlang-112`使用。vscode插件安装与配置请参考[here](https://github.com/zhangbush/vscode-vlang-112)
2. 克隆vls-112项目并且编译
```
git clone https://github.com/zhangbush/vls-112
cd vls-112
v run build.vsh
```
## 已实现
1. 自身模块内函数定义的跳转
2. 引入的外部模块的函数定义的跳转

## 接下来要实现
1. 类型推断 (优先)
2. 基于类型推断的结构体方法定义的跳转
3. 基于类型推断的变量类型定义的跳转
