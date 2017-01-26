# Lucuber
![](http://7xrfzx.com1.z0.glb.clouddn.com/Lucuber%20icon.png)

你不仅可以在 Lucuber 中收藏查阅你的复原公式， 还可以与其他魔友交流分享经验。全新的计时器更能帮助你记录成绩提升的点点滴滴。
## 简介
Lucuber 是我个人在自学 iOS 开发过程中的成果。也是对 2014 年时上架的一款同名软件的翻新。由于起步的时候没有任何软件开发基础，走了不少弯路。在此要感谢知乎，豆瓣上各路大神提供的学习意见，同时也要感谢优秀的开源项目  [Yep](https://github.com/CatchChat/Yep) 。 Lucuber 参考了很多 [Yep](https://github.com/CatchChat/Yep) 的代码和 UI 设计。

Lucuber 使用了 [Realm](https://realm.io) 做数据持久化，你可以在 `Models/Realm.swift`中查看 Lucuber 是如何对数据库进行增、删、改、查的。

服务器端的部署使用了 [LeanCloud](https://leancloud.cn) 的 SDK。选择使用 [LeanCloud](https://leancloud.cn) 仅仅是因为官网和文档看起来比较养眼。你可以在 `Services/+Fetch & +Push.swift`中查看对模型数据的转换存储与上传的逻辑。

Lucuber 的控制器跳转逻辑由 Storyboard 完成，利用新的 Storyboard References 特性管理起来还是很方便的。在项目的 `Views & ViewControllers`目录下可以浏览所有 UI 相关代码。为了性能考虑部分视图使用了 [AsyncDisplayKit](https://github.com/facebook/AsyncDisplayKit) 框架实现，目前项目中的 FormulasViewController 还没有进行性能优化，所以在 iPhone 6 以下的设备上运行有明显掉帧问题。

`Cache`目录下是对图片进行缓存的逻辑实现，其中对 [Kingfisher](https://github.com/onevcat/Kingfisher) 的 `ImageCache` 进行了简单封装。

另外项目中很多代码结构还需要优化，我的 Macbook Air 已经在努力了。😄






