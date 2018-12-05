<div align=center>
    <img width="150" height="150" src="https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Icons/Weiwei.png"/>
</div>


# Electsys Utility

上海交通大学教务处实用程序

# 功能

 - [x] 将教务处的课程表信息和你的日历同步。支持本地日历和 CalDAV 日历
 
 - [x] 同步考试信息到日历提醒事件中
 
 - [x] 从 [finda-studyroom](https://github.com/yuxiqian/finda-studyroom) 获取课程数据并分析
 
 - [x] 处理闵行、徐汇、卢湾、法华、七宝、临港等校区数据
 
 - [ ] 导出为标准 ics 格式

# 已知问题

* 日历中包含无写入权限的 CalDAV 账户（如：QQ 邮箱同步的日历）时会产生异常。

* 2017 年秋季学期开始前，教务处对部分教室的门牌号进行了调整。由于缺乏必要信息，无法给出进一步提示。

* 在 2016 到 2017 年的春季学期教改并产生暑期小学期之前，每个学期并不只有 16 个星期。

* ~~部分暑期小学期的课程未能在 json 数据中列出。~~

* ~~研究生课程及陈瑞球楼信息无法显示。~~

* ~~当未得到系统日历充分授权时会反应过度。~~

# 起因

* 受够了 ×× 课程表和 ×× 格子之后，希望可以获得一个方便稳定的方式来给自己课程提示。
> (虽然写起来并不方便，用起来也并不稳定……)

* 又因为难以在工作日找到自习教室，还想知道每间教室的课程安排ˊ_>ˋ

# 第三方库使用

* [Kanna](https://github.com/tid-kijyun/Kanna)

* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

* [Alamofire](https://github.com/Alamofire/Alamofire)

* [CrossroadRegex](https://github.com/crossroadlabs/Regex)

# 屏幕截图
## 在课程库中筛选
### 按教室
![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/按教室筛选.png)

### 按教师
![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/按教师筛选.png)

### 按课程名称
![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/按课名筛选.png)

## 同步课程到系统日历
![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/系统日历.png)

## 同步方式 A
> 通过 jAccount 账号和密码来获取课程信息、考试安排
![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/登录界面.png)

## 同步方式 B
> 不想暴露密码的话，也可以手动置入 newsinside.html
![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/手动置入页面.png)

## 同步课程信息和考试安排
![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/课程同步页面.png)

![](https://raw.githubusercontent.com/yuxiqian/electsys-utility/master/Electsys%20Utility/Screenshots/考试同步页面.png)

> (P.S.点 🎲 按钮可以……)
