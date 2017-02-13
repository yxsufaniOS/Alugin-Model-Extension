# Alugin-Model-Extension
Xcode 工具排版代码和json转模型,A Xcode Source Editor Extension to align your code or exchange jsondata.

![](http://upload-images.jianshu.io/upload_images/2106071-1b5d38020bac058c.gif?imageMogr2/auto-orient/strip)

![](http://upload-images.jianshu.io/upload_images/2106071-1f2e2a5991a26d66.gif?imageMogr2/auto-orient/strip)

![](http://upload-images.jianshu.io/upload_images/2106071-654112d8dabf9300.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### Installation Guide (Xcode 8 / OSX 10.11+)

* 1.下载项目 [Align](https://codeload.github.com/yxsufaniOS/Alugin-Model-Extension/zip/master) \n
* 2.打开项目，编译(Command+B)。\n
* 3.找到products中的appex文件，拷贝到/Applications/Xcode.app/Contents/PlugIns中。
* 4.重启Xcode，查看Editor中是否存在AlignPlugin。
* 5.可在Xcode -> "Preferences" -> "Key Bindings" -> 搜索插件plugin或者插件名字 -> 添加对应的快捷键。
* 6. (/^▽^)/

###How


### Usage

- 对光标所在位置进行排版，'Editor -> AlignPlugin -> AlignCommand(排版)'

- 对光标所在的json数据生成model属性，'Editor -> AlignPlugin -> JsonExchangeCommand(生成Model)'

### Supported languages
	- Objective-C
	
### License

MIT, see LICENSE
