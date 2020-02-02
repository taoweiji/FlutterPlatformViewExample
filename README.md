# Flutter Platform View
[Flutter Platform View：在 Flutter 中使用原生的 View](https://www.jianshu.com/p/8d74a7318c26)
我们在进行Flutter开发的时候，有时候是需要用到原生的View，比如WebView、MapView、第三方广告SDK等，Flutter提供了AndroidView、UiKitView可以实现相关功能。
#### 创建项目
这里以在Flutter显示原生的TextView为案例，展示如何实现，创建项目过程这里不展示，建议使用Android Studio进行开发。
#### 编写平台相关的代码
##### Android
创建PlatformView类
```kotlin
class AndroidTextView(context: Context) : PlatformView {
    val contentView: TextView = TextView(context)
    override fun getView(): View {
        return contentView
    }
    override fun dispose() {}
}
```
创建PlatformViewFactory类
```kotlin
class AndroidTextViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val androidTextView = AndroidTextView(context)
        androidTextView.contentView.id = viewId
        val params = args?.let { args as Map<*, *> }
        val text = params?.get("text") as CharSequence?
        text?.let {
            androidTextView.contentView.text = it
        }
        return androidTextView
    }
}
```
注册工厂，不同版本的注册方式有所不同，这里是1.12.13版本
```kotlin
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val registry = flutterEngine.platformViewsController.registry
        registry.registerViewFactory("platform_text_view", AndroidTextViewFactory())
    }
}
```
##### iOS
第一步：在info.plist增加`io.flutter.embedded_views_preview=true`，至关重要。
![](https://upload-images.jianshu.io/upload_images/2431302-6a5a97428c006ac2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
第二步：创建 PlatformTextView.swift
```swift
import Foundation
import Flutter
class PlatformTextView: NSObject,FlutterPlatformView {
    let frame: CGRect;
    let viewId: Int64;
    var text:String = "iOS Label"

    init(_ frame: CGRect,viewID: Int64,args :Any?) {
        self.frame = frame
        self.viewId = viewID
        if(args is NSDictionary){
            let dict = args as! NSDictionary
            if(dict.allKeys(for: "text").count > 0){
                self.text = dict.value(forKey: "text") as! String
            }
        }
    }
    func view() -> UIView {
        let label = UILabel()
        label.text = self.text
        label.textColor = UIColor.red
        label.frame = self.frame
        return label
    }
}
```
第三步：创建PlatformTextViewFactory.swift
```swift
class PlatformTextViewFactory: NSObject,FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return PlatformTextView(frame,viewID: viewId,args: args)
    }
}
```
第四步：在 AppDelegate.swift 注册
```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let factory = PlatformTextViewFactory()
    let registrar = self.registrar(forPlugin: "platform_text_view_plugin")
    registrar.register(factory, withId: "platform_text_view")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
#### 编写Flutter代码
```
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget getPlatformTextView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
          viewType: "platform_text_view",
          creationParams: <String, dynamic>{"text": "Android Text View"},
          creationParamsCodec: const StandardMessageCodec());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
          viewType: "platform_text_view",
          creationParams: <String, dynamic>{"text": "iOS Text View"},
          creationParamsCodec: const StandardMessageCodec());
    } else {
      return Text("Not supported");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:getPlatformTextView(),
    );
  }
}
```
#### 运行
![](https://upload-images.jianshu.io/upload_images/2431302-4e141f6e23b469c9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



#### 参考
[https://60devs.com/how-to-add-native-code-to-flutter-app-using-platform-views-android.html](https://60devs.com/how-to-add-native-code-to-flutter-app-using-platform-views-android.html)

