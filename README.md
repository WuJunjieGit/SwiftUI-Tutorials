# SwiftUI-Tutorials
 Apple Developer Swift-UI Tutorials

## 细节解读
> 参考：
> - [SwiftUI 的一些初步探索 (一)](https://onevcat.com/2019/06/swift-ui-firstlook/)
> - [SwiftUI 的一些初步探索 (二)](https://onevcat.com/2019/06/swift-ui-firstlook-2/)


### [教程 1 - Creating and Combining Views](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views)

#### [Section 1 - Step 4: 关于 some View](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views#create-a-new-project-and-explore-the-canvas)

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello World")
    }
}
```
一眼看上去可能会对 `some` 比较陌生，为了讲明白这件事，我们先从 `View` 说起。

View 是 `SwiftUI` 的一个最核心的协议，代表了一个屏幕上元素的描述。这个协议中含有一个 `associatedtype`：
```swift
public protocol View : _View {
    associatedtype Body : View
    var body: Self.Body { get }
}
```
这种带有 `associatedtype` 的协议不能作为**类型**来使用，而只能作为**类型约束**使用：
```swift
// Error
func createView() -> View {

}

// OK
func createView<T: View>() -> T {
    
}
```
这样一来，其实我们是不能写类似这种代码的：
```swift
// Error，含有 associatedtype 的 protocol View 只能作为类型约束使用
struct ContentView: View {
    var body: View {
        Text("Hello World")
    }
}
```
想要 Swift 帮助自动推断出 `View.Body` 的类型的话，我们需要明确地指出 `body` 的真正的类型。在这里，`body` 的实际类型是 `Text`：
```swift
struct ContentView: View {
    var body: Text {
        Text("Hello World")
    }
}
```
当然我们可以明确指定出 `body` 的类型，但是这带来一些麻烦：
1. 每次修改 `body` 的返回时我们都需要手动去更改相应的类型。
2. 新建一个 `View` 的时候，我们都需要去考虑会是什么类型。
3. 其实我们只关心返回的是不是一个 `View`，而对实际上它是什么类型并不感兴趣。

`some View` 这种写法使用了 Swift 5.1 的 [`Opaque return types`](https://github.com/apple/swift-evolution/blob/master/proposals/0244-opaque-result-types.md) 特性。它向编译器作出保证，每次 `body` 得到的一定是某一个确定的，遵守 `View` 协议的类型，但是请编译器“网开一面”，不要再细究具体的类型。返回类型**确定单一**这个条件十分重要，比如，下面的代码也是无法通过的：
```swift
let someCondition: Bool

// Error: Function declares an opaque return type, 
// but the return statements in its body do not have 
// matching underlying types.
var body: some View {
    if someCondition {
        // 这个分支返回 Text
        return Text("Hello World")
    } else {
        // 这个分支返回 Button，和 if 分支的类型不统一
        return Button(action: {}) {
            Text("Tap me")
        }
    }
}
```
这是一个**编译期间**的特性，在保证 `associatedtype protocol` 的功能的前提下，使用 `some` 可以抹消具体的类型。这个特性用在 SwiftUI 上**简化了书写难度，让不同 `View` 声明的语法上更加统一**。

#### [Section 2 - Step 1: 预览 SwiftUI](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views#customize-the-text-view)

SwiftUI 的 Preview 是 Apple 用来对标 RN 或者 Flutter 的 Hot Reloading 的开发工具。由于 IBDesignable 的性能上的惨痛教训，而且得益于 SwiftUI 经由 UIKit 的跨 Apple 平台的特性，Apple 这次选择了直接在 macOS 上进行渲染。因此，你需要使用搭载有 SwiftUI.framework 的 macOS 10.15 才能够看到 Xcode Previews 界面。

Xcode 将对代码进行静态分析 (得益于 [SwiftSyntax 框架](https://github.com/apple/swift-syntax))，找到所有遵守 `PreviewProvider` 协议的类型进行预览渲染。另外，你可以为这些预览提供合适的数据，这甚至可以让整个界面开发流程不需要实际运行 app 就能进行。

#### [Section 3 - Step 5: 关于 ViewBuilder](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views#combine-views-using-stacks)

创建 `Stack` 的语法很有趣：
```swift
VStack(alignment: .leading) {
    Text("Turtle Rock")
        .font(.title)
    Text("Joshua Tree National Park")
        .font(.subheadline)
}
```

一开始看起来好像我们给出了两个` Text`，似乎是构成的是一个类似数组形式的 `[View]`，但实际上并不是这么一回事。这里调用了 `VStack` 类型的初始化方法：
```swift
public struct VStack<Content> where Content : View {
    init(
        alignment: HorizontalAlignment = .center, 
        spacing: Length? = nil, 
        content: () -> Content)
}
```
前面的 `alignment` 和 `spacing` 没啥好说，最后一个 `content` 比较有意思。看签名的话，它是一个 `() -> Content` 类型，但是我们在创建这个 `VStack` 时所提供的代码只是简单列举了两个 `Text`，而并没有实际返回一个可用的 `Content`。

这里使用了 Swift 5.1 的另一个新特性：[Funtion builders](https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md)。如果你实际观察 `VStack` 的这个[初始化方法的签名](https://developer.apple.com/documentation/swiftui/vstack/3278367-init)，会发现 `content` 前面其实有一个 `@ViewBuilder` 标记：
```swift
init(
    alignment: HorizontalAlignment = .center, 
    spacing: Length? = nil, 
    @ViewBuilder content: () -> Content)
```
而 `ViewBuilder` 则是一个由 `@_functionBuilder` 进行标记的 `struct`：
```swift
@_functionBuilder public struct ViewBuilder { /* */ }
```
使用 `@_functionBuilder` 进行标记的类型 (这里的 `ViewBuilder`)，可以被用来对其他内容进行标记 (这里用` @ViewBuilder` 对 `content` 进行标记)。被用 `function builder` 标记过的 `ViewBuilder` 标记以后，`content` 这个输入的 `function` 在被使用前，会按照 `ViewBuilder` 中合适的 `buildBlock` [进行 build](https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md#function-building-methods) 后再使用。如果你阅读 `ViewBuilder` 的[文档](https://developer.apple.com/documentation/swiftui/viewbuilder)，会发现有很多接受不同个数参数的 `buildBlock` 方法，它们将负责把闭包中一一列举的 `Text` 和其他可能的 View 转换为一个 `TupleView``，并返回。由此，content` 的签名 `() -> Content` 可以得到满足。 

实际上构建这个 `VStack` 的代码会被转换为类似下面这样：
```swift
// 等效伪代码，不能实际编译。
VStack(alignment: .leading) { viewBuilder -> Content in
    let text1 = Text("Turtle Rock").font(.title)
    let text2 = Text("Joshua Tree National Park").font(.subheadline)
    return viewBuilder.buildBlock(text1, text2)
}
```
当然这种基于 funtion builder 的方式是有一定限制的。比如 `ViewBuilder` 就只实现了最多十个参数的 `buildBlock`，因此如果你在一个 `VStack` 中放超过十个 `View` 的话，编译器就会不太高兴。不过对于正常的 UI 构建，十个参数应该足够了。如果还不行的话，你也可以考虑直接使用 `TupleView` 来用多元组的方式合并 `View`：
```swift
TupleView<(Text, Text)>(
    (Text("Hello"), Text("Hello"))
)
```
除了按顺序接受和构建 `View` 的 `buildBlock` `以外，ViewBuilder` `还实现了两个特殊的方法：buildEither` 和 `buildIf`。它们分别对应 `block` 中的 `if...else` 的语法和 `if` 的语法。也就是说，你可以在 `VStack` 里写这样的代码：
```swift
var someCondition: Bool

VStack(alignment: .leading) {
    Text("Turtle Rock")
        .font(.title)
    Text("Joshua Tree National Park")
        .font(.subheadline)
    if someCondition {
        Text("Condition")
    } else {
        Text("Not Condition")
    }
}
```
其他的命令式的代码在 `VStack` 的 `content` 闭包里是不被接受的，下面这样也不行：
```swift
VStack(alignment: .leading) {
    // let 语句无法通过 function builder 创建合适的输出
    let someCondition = model.condition
    if someCondition {
        Text("Condition")
    } else {
        Text("Not Condition")
    }
}
```
到目前为止，只有以下三种写法能被接受 (有可能随着 SwiftUI 的发展出现别的可接受写法)：
- 结果为 `View` 的语句
- `if` 语句
- `if...else...` 语句
  

#### [Section 4 - Step 7: 链式调用修改 View 的属性](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views#create-a-custom-image-view)

教程到这一步的话，相信大家已经对 SwiftUI 的超强表达能力有所感悟了。
```swift
var body: some View {
    Image("turtlerock")
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
}
```
可以试想一下，在 UIKit 中要动手撸一个这个效果的困难程度。我大概可以保证，99% 的开发者很难在不借助文档或者 copy paste 的前提下完成这些事情，但是在 SwiftUI 中简直信手拈来。在创建 `View` 之后，用链式调用的方式，可以将 `View` 转换为一个含有变更后内容的对象。

### [教程 2 - Building Lists and Navigation](https://developer.apple.com/tutorials/swiftui/building-lists-and-navigation)

#### [Section 4 - Step 2: 静态 List](https://developer.apple.com/tutorials/swiftui/building-lists-and-navigation#create-the-list-of-landmarks)

```swift
var body: some View {
    List {
        LandmarkRow(landmark: landmarkData[0])
        LandmarkRow(landmark: landmarkData[1])
    }
}
```
这里的 `List` 和 `HStack` 或者 `VStack` 之类的容器很相似，接受一个 `view builder` 并采用 `View DSL` 的方式列举了两个 `LandmarkRow`。这种方式构建了对应着 `UITableView` 的静态 `cell` 的组织方式。
```swift
public init(content: () -> Content)
```
我们可以运行 app，并使用 Xcode 的 View Hierarchy 工具来观察 UI，结果可能会让你觉得很眼熟：

![](https://images.xiaozhuanlan.com/photo/2019/a900c8d2687dab13ba438602da826552.png)

实际上在屏幕上绘制的 `UpdateCoalesingTableView` 是一个 `UITableView` 的子类，而两个 `cell` `ListCoreCellHost` 也是 `UITableViewCell` 的子类。对于 `List` 来说，SwiftUI 底层直接使用了成熟的 `UITableView` 的一套实现逻辑，而并非重新进行绘制。
相比起来，像是 `Text` 或者 `Image` 这样的单一 `View` 在 UIKit 层则全部统一由 `DisplayList.ViewUpdater.Platform.CGDrawingView` 这个 `UIView` 的子类进行绘制。

不过在使用 SwiftUI 时，我们首先需要做的就是跳出 UIKit 的思维方式，不应该去关心背后的绘制和实现。使用 UITableView 来表达 List 也许只是权宜之计，也许在未来也会被另外更高效的绘制方式取代。由于 SwiftUI 层只是 View 描述的数据抽象，因此和 React 的 Virtual DOM 以及 Flutter 的 Widget 一样，背后的具体绘制方式是完全解耦合，并且可以进行替换的。这为今后 SwiftUI 更进一步留出了足够的可能性。

#### [Section 5 - Step 2: 动态 List 和 Identifiable](https://developer.apple.com/tutorials/swiftui/building-lists-and-navigation#make-the-list-dynamic)

```swift
List(landmarkData.identified(by: \.id)) { landmark in
    LandmarkRow(landmark: landmark)
}
```
除了静态方式以外，`List` 当然也可以接受动态方式的输入，这时使用的初始化方法和上面静态的情况不一样：

```swift
public struct List<Selection, Content> where Selection : SelectionManager, Content : View {
    public init<Data, RowContent>(
        _ data: Data, action: @escaping (Data.Element.IdentifiedValue) -> Void,
        rowContent: @escaping (Data.Element.IdentifiedValue) -> RowContent) 
    where 
        Content == ForEach<Data, Button<HStack<RowContent>>>, 
        Data : RandomAccessCollection, 
        RowContent : View, 
        Data.Element : Identifiable
        
    //...
}
```

这个初始化方法的约束比较多，我们一行行来看：

- `Content == ForEach<Data, Button<HStack<RowContent>>>` 因为这个函数签名中并没有出现 `Content`，`Content` 仅只 `List<Selection, Content>` 的类型声明中有定义，所以在这与其说是一个约束，不如说是一个用来反向确定 `List` 实际类型的描述。现在让我们先将注意力放在更重要的地方，稍后会再多讲一些这个。
- `Data : RandomAccessCollection` 这基本上等同于要求第一个输入参数是 `Array`。
- `RowContent : View` 对于构建每一行的 `rowContent` 来说，需要返回是 `View` 是很正常的事情。注意 `rowContent` 其实也是被 `@ViewBuilder `标记的，因此你也可以把 `LandmarkRow` 的内容展开写进去。不过一般我们会更希望尽可能拆小 UI 部件，而不是把东西堆在一起。
- `Data.Element : Identifiable` 要求 `Data.Element` (也就是数组元素的类型) 上存在一个可以辨别出某个实例的满足[ `Hashable`](https://developer.apple.com/documentation/swiftui/identifiable/3285392-id) 的 `id`。这个要求将在数据变更时**快速定位到变化的数据**所对应的 `cell`，并进行 UI 刷新。

关于 `List` 以及其他一些常见的基础 `View`，有一个比较有趣的事实。在下面的代码中，我们期望 `List` 的初始化方法生成的是某个类型的 `View`：
```swift
var body: some View {
    List {
        //...
    }
}
```
但是你看遍 [List 的文档](https://developer.apple.com/documentation/swiftui/list)，甚至是 Cmd + Click 到 SwiftUI 的 `interface` 中查找 `View` 相关的内容，都找不到 `List : View`之类的声明。

难道是因为 SwiftUI 做了什么手脚，让本来没有满足 `View` 的类型都可以“充当”一个 `View` 吗？当然不是这样…如果你在运行时暂定 app 并用 lldb 打印一下 `List` 的类型信息，可以看到下面的下面的信息：

```
(lldb) type lookup List
...
struct List<Selection, Content> : SwiftUI._UnaryView where ...
```
进一步，`_UnaryView` 的声明是：
```swift
protocol _UnaryView : View where Self.Body : _UnaryView {
}
```
SwiftUI 内部的一元视图 `_UnaryView` 协议虽然是满足 `View` 的，但它被隐藏起来了，而满足它的 `List` 虽然是 `public` 的，但是却可以把这个协议链的信息也作为内部信息隐藏起来。这是 Swift 内部框架的特权，第三方的开发者无法这样在在两个 `public` 的声明之间插入一个私有声明。

最后，SwiftUI 中当前 (Xcode 11 beta 1) 只有对应 `UITableView` 的` List`，而没有 `UICollectionView` 对应的像是 `Grid` 这样的类型。现在想要实现类似效果的话，只能嵌套使用 `VStack` 和 `HStack`。这是比较奇怪的，因为技术层面上应该和 `table view` 没有太多区别，大概是因为工期不太够？相信今后应该会补充上 `Grid`。
> 现在，在 SwiftUI 中已经有 **Grid** 类型

### [教程 3 - Handling User Input](https://developer.apple.com/tutorials/swiftui/handling-user-input)

#### [Section 3 - Step 2: @State 和 Binding](https://developer.apple.com/tutorials/swiftui/handling-user-input#add-a-control-to-toggle-the-state)

```swift
@State var showFavoritesOnly = true

var body: some View {
    NavigationView {
        List {
            Toggle(isOn: $showFavoritesOnly) {
                Text("Favorites only")
            }
    //...
            if !self.showFavoritesOnly || landmark.isFavorite {
```
这里出现了两个以前在 Swift 里没有的特性：`@State` 和` $showFavoritesOnly`。

如果你 Cmd + Click 点到 `State` 的定义里面，可以看到它其实是一个特殊的 `struct`：
```swift
@propertyWrapper public struct State<Value> : DynamicViewProperty, BindingConvertible {

    /// Initialize with the provided initial value.
    public init(initialValue value: Value)

    /// The current state value.
    public var value: Value { get nonmutating set }

    /// Returns a binding referencing the state value.
    public var binding: Binding<Value> { get }

    /// Produces the binding referencing this state value
    public var delegateValue: Binding<Value> { get }
}
```

`@propertyWrapper` 标注和上一篇中提到的 `@_functionBuilder` 类似，它修饰的 `struct` 可以变成一个新的修饰符并作用在其他代码上，来改变这些代码默认的行为。这里 `@propertyWrapper` 修饰的 `State` 被用做了 `@State` 修饰符，并用来修饰 `View` 中的 `showFavoritesOnly` 变量。

和 @`_functionBuilder` 负责按照规矩“重新构造”**函数**的作用不同，`@propertyWrapper` 的修饰符最终会作用在**属性**上，将属性“包裹”起来，以达到**控制某个属性的读写行为的目的**。如果将这部分代码“展开”，它实际上是这个样子的：
```swift
// @State var showFavoritesOnly = true
   var showFavoritesOnly = State(initialValue: true)
    
var body: some View {
    NavigationView {
        List {
//          Toggle(isOn: $showFavoritesOnly) {
            Toggle(isOn: showFavoritesOnly.binding) {
                Text("Favorites only")
            }
    //...
//          if !self.showFavoritesOnly || landmark.isFavorite {
            if !self.showFavoritesOnly.value || landmark.isFavorite {
```
我把变化之前的部分注释了一下，并且在后面一行写上了展开后的结果。可以看到 `@State` 只是声明 `State` `struct` 的一种简写方式而已。`State` 里对具体要如何读写属性的规则进行了定义。对于读取，非常简单，使用 showFavoritesOnly.value 就能拿到 `State` 中存储的实际值。而原代码中 `$showFavoritesOnly` 的写法也只不过是 `showFavoritesOnly.binding` `的简化。binding` 将创建一个 `showFavoritesOnly` 的引用，并将它传递给 `Toggle`。再次强调，这个 `binding` 是一个引用类型，所以 `Toggle` 中对它的修改，会直接反应到当前 View 的 `showFavoritesOnly` 去设置它的` value`。而 `State` 的 `value didSet` 将触发 `body` 的刷新，从而完成 `State -> View` 的绑定。

SwiftUI 中还有几个常见的 @ 开头的修饰，比如 `@Binding`，`@Environment`，`@EnvironmentObject` 等，原理上和 `@State` 都一样，只不过它们所对应的 `struct` 中定义读写方式有区别。它们共同构成了 SwiftUI 数据流的最基本的单元。对于 SwiftUI 的数据流，如果展开的话足够一整篇文章了。在这里还是十分建议看一看 [Session 226 - Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226/) 的相关内容。


### [教程 5 - Animating Views and Transitions](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions)

#### [Section 2 - Step 4: 两种动画的方式](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions#customize-view-transitions)

在 SwiftUI 中，做动画变的十分简单。Apple 的教程里提供了两种动画的方式：
1. 直接在 `View` 上使用 `.animation` modifier
2. 使用` withAnimation { }` 来控制某个 `State`，进而触发动画。

对于只需要对单个 `View` 做动画的时候，`animation(_:)` 要更方便一些，它和其他各类 modifier 并没有太大不同，返回的是一个包装了对象 `View` 和对应的动画类型的新的` View`。`animation(_:)` 接受的参数 `Animation` 并不是直接定义 `View` 上的动画的数值内容的，它是描述的是动画所使用的时间曲线，动画的延迟等这些和 `View` 无关的东西。具体和 `View` 有关的，想要进行动画的数值方面的变更，由其他的诸如 `rotationEffect` 和 `scaleEffect` 这样的 modifier 来描述。

在上面的 [教程 5 - Section 1 - Step 5](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions#add-animations-to-individual-views) 里有这样一段代码：

```swift
Button(action: {
    self.showDetail.toggle()
}) {
    Image(systemName: "chevron.right.circle")
        .imageScale(.large)
        .rotationEffect(.degrees(showDetail ? 90 : 0))
        .animation(nil)
        .scaleEffect(showDetail ? 1.5 : 1)
        .padding()
        .animation(.spring())
}
```

要注意，SwiftUI 的 modifier 是有顺序的。在我们调用 `animation(_:)` 时，SwiftUI 做的事情等效于是把之前的所有 modifier 检查一遍，然后找出所有满足 `Animatable` 协议的 `view` 上的数值变化，比如角度、位置、尺寸等，然后将这些变化打个包，创建一个事物 (`Transaction`) 并提交给底层渲染去做动画。在上面的代码中，`.rotationEffect` 后的 `.animation(nil)` 将 `rotation` 的动画提交，因为指定了 nil 所以这里没有实际的动画。在最后，`.rotationEffect` 已经被处理了，所以末行的 .`animation(.spring())` 提交的只有 `.scaleEffect`。

`withAnimation { }` 是一个顶层函数，在闭包内部，我们一般会触发某个 `State` 的变化，并让 `View.body` 进行重新计算：

```swift
Button(action: {
    withAnimation {
        self.showDetail.toggle()
    }
}) { 
  //...
}
```

如果需要，你也可以为它指定一个具体的 `Animation`：

```swift
withAnimation(.basic()) {
    self.showDetail.toggle()
}
```

这个方法相当于把一个 `animation` 设置到 `View` 数值变化的 `Transaction` 上，并提交给底层渲染去做动画。从原理上来说，`withAnimation` 是统一控制单个的 `Transaction`，而针对不同 `View` 的 `animation(_:)` 调用则可能对应多个不同的 `Transaction`。

### [教程 7 - Working with UI Controls](https://developer.apple.com/tutorials/swiftui/working-with-ui-controls)

#### [Section 4 - Step 2: 关于 View 的生命周期](https://developer.apple.com/tutorials/swiftui/working-with-ui-controls#delay-edit-propagation)

```swift
ProfileEditor(profile: $draftProfile)
    .onDisappear {
        self.draftProfile = self.profile
    }
```

在 UIKit 开发时，我们经常会接触一些像是 `viewDidLoad`，`viewWillAppear` 这样的生命周期的方法，并在里面进行一些配置。SwiftUI 里也有一部分这类生命周期的方法，比如 `.onAppear` 和 .`onDisappear`，它们也被“统一”在了 modifier 这面大旗下。

但是相对于 UIKit 来说，SwiftUI 中能 `hook` 的生命周期方法比较少，而且相对要通用一些。本身在生命周期中做操作这种方式就和声明式的编程理念有些相悖，看上去就像是加上了一些命令式的` hack`。我个人比较期待 `View` 和 `Combine` 能再深度结合一些，把像是 `self.draftProfile = self.profile` 这类依赖生命周期的操作也用绑定的方式搞定。

相比于 `.onAppear` 和 `.onDisappear`，更通用的事件响应 `hook` 是 `.onReceive(_:perform:)`，它定义了一个可以响应目标 `Publisher` 的任意的 `View`，一旦订阅的 `Publisher` 发出新的事件时，`onReceive` 就将被调用。因为我们可以自行定义这些 `publisher`，所以它是完备的，这在把现有的 UIKit View 转换到 SwiftUI View 时会十分有用。





