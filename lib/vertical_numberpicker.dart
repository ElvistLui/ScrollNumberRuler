import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class VerticalNumberPicker extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int step;

  ///控件的宽度
  final int widgetWidth;

  ///控件的高度
  final int widgetHeight;

  ///大格的总数
  late int gridCount;

  ///一大格中有多少个小格
  final int subGridCountPerGrid;

  ///大格的高度
  late int gridHeight;

  ///每一小格的高度
  final int subGridHeight;

  late int listViewItemCount;

  late double paddingItemHeight;

  final void Function(int) onSelectedChanged;

  ///返回标尺刻度所展示的数值字符串
  String Function(int)? scaleTransformer;

  ///刻度颜色
  final Color scaleColor;

  ///指示器颜色
  final Color indicatorColor;

  ///刻度文字颜色
  final Color scaleTextColor;

  VerticalNumberPicker({
    super.key,
    this.initialValue = 500,
    this.minValue = 100,
    this.maxValue = 900,
    this.step = 1,
    this.widgetWidth = 200,
    this.widgetHeight = 60,
    this.subGridCountPerGrid = 10,
    this.subGridHeight = 8,
    required this.onSelectedChanged,
    this.scaleTransformer,
    this.scaleColor = const Color(0xff000000), // const Color(0xffD7DCE7),
    this.indicatorColor = const Color(0xff036AFF),
    this.scaleTextColor = const Color(0x803B4664),
  }) : super() {
    if (subGridCountPerGrid % 2 != 0) {
      throw Exception("subGridCountPerGrid必须是偶数");
    }

    if ((maxValue - minValue) % step != 0) {
      throw Exception("(maxValue - minValue)必须是step的整数倍");
    }
    int totalSubGridCount = (maxValue - minValue) ~/ step;

    if (totalSubGridCount % subGridCountPerGrid != 0) {
      throw Exception("(maxValue - minValue)~/step必须是subGridCountPerGrid的整数倍");
    }
    //第一个grid和最后一个grid都只会展示一半数量的subGrid，因此gridCount需要+1
    gridCount = totalSubGridCount ~/ subGridCountPerGrid + 1;

    gridHeight = subGridHeight * subGridCountPerGrid;

    //每个grid都是listView的一个item
    //除此之外，在第一个grid之前和最后一个grid之后，还需要各填充一个空白item，
    //这样第一个item和最后一个item才能滚动到屏幕中间。
    listViewItemCount = gridCount + 2;

    //空白item的高度
    paddingItemHeight = (widgetHeight - gridHeight) / 2;

    scaleTransformer ??= (value) {
      return value.toString();
    };
  }

  @override
  State<StatefulWidget> createState() {
    return VerticalNumberPickerState();
  }
}

class VerticalNumberPickerState extends State<VerticalNumberPicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController(
      //计算初始偏移量
      initialScrollOffset: (widget.initialValue - widget.minValue) /
          widget.step *
          widget.subGridHeight,
    );
    super.initState();
  }

  ///处理state的复用
  @override
  void didUpdateWidget(VerticalNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    _scrollController.dispose();
    _scrollController = ScrollController(
      //计算初始偏移量
      initialScrollOffset: (widget.initialValue - widget.minValue) /
          widget.step *
          widget.subGridHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.widgetWidth.toDouble(),
      height: widget.widgetHeight.toDouble(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          NotificationListener(
            onNotification: _onNotification,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(0),
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              itemCount: widget.listViewItemCount,
              itemBuilder: (BuildContext context, int index) {
                //首尾空白元素
                if (index == 0 || index == widget.listViewItemCount - 1) {
                  return SizedBox(
                    width: 0,
                    height: widget.paddingItemHeight,
                  );
                  //普通元素
                } else {
                  int type;
                  //第一个普通元素
                  if (index == 1) {
                    type = 0;
                    //最后一个普通元素
                  } else if (index == widget.listViewItemCount - 2) {
                    type = 2;
                    //中间普通元素
                  } else {
                    type = 1;
                  }

                  // return NumberPickerItem(
                  //   subGridCount: widget.subGridCountPerGrid,
                  //   subGridHeight: widget.subGridHeight,
                  //   itemWidth: widget.widgetWidth,
                  //   valueStr: widget.scaleTransformer!(widget.minValue +
                  //       (index - 1) * widget.subGridCountPerGrid * widget.step),
                  //   type: type,
                  //   scaleColor: widget.scaleColor,
                  //   scaleTextColor: widget.scaleTextColor,
                  // );
                  return GestureDetector(
                    onTap: () {
                      select(widget.minValue +
                          (index - 1) *
                              widget.subGridCountPerGrid *
                              widget.step);
                    },
                    child: NumberPickerItem(
                      subGridCount: widget.subGridCountPerGrid,
                      subGridHeight: widget.subGridHeight,
                      itemWidth: widget.widgetWidth,
                      valueStr: widget.scaleTransformer!(widget.minValue +
                          (index - 1) *
                              widget.subGridCountPerGrid *
                              widget.step),
                      type: type,
                      scaleColor: widget.scaleColor,
                      scaleTextColor: widget.scaleTextColor,
                    ),
                  );
                }
              },
            ),
          ),
          //指示器
          Container(
            width: widget.widgetWidth * 0.55,
            height: 2,
            color: widget.indicatorColor,
          ),
        ],
      ),
    );
  }

  ///监听滚动通知
  bool _onNotification(Notification notification) {
    if (notification is ScrollNotification) {
      //距离widget中间最近的刻度值
      int centerValue =
          (notification.metrics.pixels / widget.subGridHeight).round() *
                  widget.step +
              widget.minValue;

      // 通知回调选中值改变了
      widget.onSelectedChanged(centerValue);

      //若用户手指离开屏幕且列表的滚动停止，则滚动到centerValue
      if (_scrollingStopped(notification, _scrollController)) {
        select(centerValue);
      }
    }

    return true; //停止通知冒泡
  }

  ///判断是否用户手指离开屏幕且列表的滚动停止
  bool _scrollingStopped(
    Notification notification,
    ScrollController scrollController,
  ) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  //public------------------------------------------------------------------------

  ///选中值
  select(int valueToSelect) {
    _scrollController.animateTo(
      (valueToSelect - widget.minValue) / widget.step * widget.subGridHeight,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }
}

//------------------------------------------------------------------------------

///每个item中间为长刻度，并在下方显示数值。两边都是短刻度
class NumberPickerItem extends StatelessWidget {
  final int subGridCount;
  final int subGridHeight;
  final int itemWidth;
  final String valueStr;

  //0:列表首item 1:中间item 2:尾item
  final int type;

  final Color scaleColor;
  final Color scaleTextColor;

  const NumberPickerItem({
    super.key,
    required this.subGridCount,
    required this.subGridHeight,
    required this.itemWidth,
    required this.valueStr,
    required this.type,
    required this.scaleColor,
    required this.scaleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    double itemWidth = this.itemWidth.toDouble();
    double itemHeight = (subGridHeight * subGridCount).toDouble();

    return CustomPaint(
      size: Size(itemWidth, itemHeight),
      painter:
          MyPainter(subGridHeight, valueStr, type, scaleColor, scaleTextColor),
    );
  }
}

class MyPainter extends CustomPainter {
  final int subGridHeight;

  final String valueStr;

  //0:列表首item 1:中间item 2:尾item
  final int type;

  final Color scaleColor;

  final Color scaleTextColor;

  late Paint _linePaint;

  final double _lineHeight = 2;

  MyPainter(
    this.subGridHeight,
    this.valueStr,
    this.type,
    this.scaleColor,
    this.scaleTextColor,
  ) {
    _linePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = _lineHeight
      ..color = scaleColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawLine(canvas, size);
    drawText(canvas, size);
  }

  void drawLine(Canvas canvas, Size size) {
    double startY, endY;
    switch (type) {
      case 0: //首元素只绘制下半部分
        startY = size.height / 2;
        endY = size.height;
        break;
      case 2: //尾元素只绘制上半部分
        startY = 0;
        endY = size.height / 2;
        break;
      default: //中间元素全部绘制
        startY = 0;
        endY = size.height;
    }

    double largeLine = size.width * 0.383;
    double smallLine = size.width * 0.183;
    double offset = (largeLine - smallLine) / 2;

    //绘制竖线
    canvas.drawLine(
        Offset(largeLine / 2, startY), Offset(largeLine / 2, endY), _linePaint);

    //绘制横线
    for (double y = startY; y <= endY; y += subGridHeight) {
      // if (x == size.width / 2) {
      //   //中间为长刻度
      //   canvas.drawLine(
      //       Offset(x, 0), Offset(x, size.height * 0.183), _linePaint);
      // } else {
      //   //其他为短刻度
      //   canvas.drawLine(
      //       Offset(x, 0), Offset(x, size.height * 0.383), _linePaint);
      // }
      if (y == size.height / 2) {
        //中间为长刻度
        canvas.drawLine(Offset(0, y), Offset(largeLine, y), _linePaint);
      } else {
        //其他为短刻度
        canvas.drawLine(
            Offset(offset, y), Offset(offset + smallLine, y), _linePaint);
      }
    }
  }

  void drawText(Canvas canvas, Size size) {
    //文字水平方向居中对齐，竖直方向底对齐
    ui.Paragraph p = _buildText(valueStr, size.height);
    //获得文字的宽高
    double halfWidth = p.minIntrinsicWidth / 2;
    canvas.drawParagraph(
        p, Offset(size.width / 2 - halfWidth, (size.height - p.height) / 2));
  }

  ui.Paragraph _buildText(String content, double maxWidth) {
    ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle());
    paragraphBuilder.pushStyle(
      ui.TextStyle(
        color: scaleTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
    paragraphBuilder.addText(content);

    ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWidth));

    return paragraph;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
