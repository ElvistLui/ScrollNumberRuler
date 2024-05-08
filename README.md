# 功能

水平滚动的数字选择标尺。支持：

- 选取整数、小数。不同的步进。
- 自定义刻度样式。
- 自定义数字显示的格式、单位。
- 惯性滚动。手指离开后自动对齐。

为了使用的灵活性，控件被拆分为两部分，分别是：

- HorizontalNumberPicker：标尺。
- HorizontalNumberPickerWrapper：对HorizontalNumberPicker进行简单包装，添加顶部的选中值显示和两边的半透明遮罩。

> 控件的代码比较简单，若有无法调整的样式，建议直接修改源码。

# 效果

![](1.png)

![](2.gif)

# HorizontalNumberPicker

标尺。

```dart
HorizontalNumberPicker({
    super.key,
    this.initialValue = 500, //初始值
    this.minValue = 100, //最小可选值
    this.maxValue = 900, //最大可选值
    this.step = 1, //步进
    this.widgetWidth = 200, //标尺宽度
    this.widgetHeight = 60, //标尺高度
    this.subGridCountPerGrid = 10, //每个大格中的小格数
    this.subGridWidth = 8, //每个小格的宽度
    required this.onSelectedChanged, //选中值改变回调
    this.scaleTransformer, //自定义标尺下的文字显示格式
    this.scaleColor = const Color(0xFFE9E9E9), //刻度颜色
    this.indicatorColor = const Color(0xFF3995FF), //指示器颜色
    this.scaleTextColor = const Color(0xFF8E99A0), //刻度下的文字颜色
  }) : super(key: key) {
	...
}
```

# HorizontalNumberPickerWrapper

对HorizontalNumberPicker进行简单包装，添加顶部的选中值显示和两边的半透明遮罩。

```dart
HorizontalNumberPickerWrapper({
    super.key,
    this.initialValue = 500,
    this.minValue = 100,
    this.maxValue = 900,
    this.step = 1,
    this.unit = "", //顶部title的单位
    this.widgetWidth = 200,
    this.subGridCountPerGrid = 10,
    this.subGridWidth = 8,
    required this.onSelectedChanged,
    this.titleTransformer, //自定义title的显示格式
    this.scaleTransformer,
    this.titleTextColor = const Color(0xFF3995FF), //title文字的颜色
    this.scaleColor = const Color(0xFFE9E9E9),
    this.indicatorColor = const Color(0xFF3995FF),
    this.scaleTextColor = const Color(0xFF8E99A0),
  }) : super(key: key) {
    ...
}
```

# 使用示例

```dart
...

class _MyHomePageState extends State<MyHomePage> {
  NumberFormat _numberFormat = NumberFormat(',000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("横向滚动"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              HorizontalNumberPickerWrapper(
                initialValue: 160,
                minValue: 100,
                maxValue: 200,
                step: 1,
                unit: 'CM',
                widgetWidth: MediaQuery.of(context).size.width.round() - 30,
                subGridCountPerGrid: 10,
                subGridWidth: 8,
                onSelectedChanged: (value) {
                  print(value);
                },
              ),
              Container(height: 10),
              HorizontalNumberPickerWrapper(
                initialValue: 600,
                minValue: 100,
                maxValue: 1500,
                step: 1,
                unit: 'KG',
                widgetWidth: MediaQuery.of(context).size.width.round() - 30,
                subGridCountPerGrid: 10,
                subGridWidth: 8,
                onSelectedChanged: (value) {
                  print(value / 10);
                },
                titleTransformer: (value) {
                  return formatIntegerStr(value / 10);
                },
                scaleTransformer: (value) {
                  return formatIntegerStr(value / 10);
                },
              ),
              Container(height: 10),
              HorizontalNumberPickerWrapper(
                initialValue: 100,
                minValue: 0,
                maxValue: 300,
                step: 1,
                unit: 'mmHg',
                widgetWidth: MediaQuery.of(context).size.width.round() - 30,
                subGridCountPerGrid: 2,
                subGridWidth: 20,
                onSelectedChanged: (value) {
                  print(value);
                },
              ),
              Container(height: 10),
              HorizontalNumberPickerWrapper(
                initialValue: 80,
                minValue: 10,
                maxValue: 250,
                step: 1,
                unit: 'mmol/L',
                widgetWidth: MediaQuery.of(context).size.width.round() - 30,
                subGridCountPerGrid: 2,
                subGridWidth: 20,
                onSelectedChanged: (value) {
                  print(value / 10);
                },
                titleTransformer: (value) {
                  return formatIntegerStr(value / 10);
                },
                scaleTransformer: (value) {
                  return formatIntegerStr(value / 10);
                },
              ),
              Container(height: 10),
              HorizontalNumberPickerWrapper(
                initialValue: 6000,
                minValue: 1000,
                maxValue: 21000,
                step: 1000,
                unit: '步',
                widgetWidth: MediaQuery.of(context).size.width.round() - 30,
                subGridCountPerGrid: 2,
                subGridWidth: 20,
                onSelectedChanged: (value) {
                  print(value);
                },
                titleTransformer: (value) {
                  return _numberFormat.format(value);
                },
                scaleTransformer: (value) {
                  return '${value ~/ 1000}k';
                },
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

///去掉整数后的小数点和0
///1.0 -> "1"
///1.2 -> "1.2"
String formatIntegerStr(num number) {
  int intNumber = number.truncate();

  //是整数
  if (intNumber == number) {
    return intNumber.toString();
  } else {
    return number.toString();
  }
}
```

# 源码

https://github.com/al4fun/HorizontalNumberPicker

