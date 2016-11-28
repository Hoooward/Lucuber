
## Model
使用 objcetID 的模型中, 比如: Formula, Message, Feed 等 Realm 中的数据模型, 都有其对应的 Discover -> LeanCloud 中的模型. 因为 objectID 的生成在远端, 所以根据不同情况在本地需要使用不同的 objectID.hj

暂时命名为: 
lcObjectID -> leanCloud
localObjectID -> 本地创建的字符串

暂时使用规则:
RUser 使用远端的 lcObjectID, 其余使用本地的 localObjectID.


###------------未来更新计划---------------

1. 将 Formula 显示的 Cell 中的图片进行网络获取，目前是存储在本地
3. 应用程序启动如果没有网络，”且数据库无内容“ 会直接崩溃
4. 创建新公式保存时候回到 FormulaViewControll 后没有刷新 collectionView，新公式已经保存到了 Realm 和 LeanCloud 中。
5. 如果我创建一个新类别的公式， 当前项目只有一个此类公式， 如果通过编辑修改了其公式类别， NewFeed视图消失的时候 App 会崩。


###---------------已解决-------------------
2. CategoryMenu 的排列顺序没有按照魔方类型排。-> 已经解决
5. 新建公式中的 FormulaTextCell 目前输入的属性字符串以及计算Cell行高在 iOS10 下工作正常。但在iOS9 下没有进行测试。 -> 已经解决
