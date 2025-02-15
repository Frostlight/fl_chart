# BarChart

<img src="https://github.com/imaNNeoFighT/fl_chart/raw/master/repo_files/images/bar_chart/bar_chart.jpg" width="300" >

### How to use
```
BarChart(
  BarChartData(
    // read about it in the below section
  ),
);
```

### BarChartData
|PropName		|Description	|default value|
|:---------------|:---------------|:-------|
|barGroups| list of [BarChartGroupData ](#BarChartGroupData) to show the bar lines together, you can provide one item per group to show normal bar chart|[]|
|alignment| a [BarChartAlignment](#BarChartAlignment) that determines the alignment of the barGroups, inspired by [Flutter MainAxisAlignment](https://docs.flutter.io/flutter/rendering/MainAxisAlignment-class.html)| BarChartAlignment.spaceBetween|
|titlesData| check the [FlTitlesData](base_chart.md#FlTitlesData)|FlTitlesData()|
|backgroundColor| a background color which is drawn behind the chart| null |
|barTouchData| [BarTouchData](#BarTouchData) holds the touch interactivity details|BarTouchData()|
|gridData| check the [FlGridData](base_chart.md#FlGridData)|FlGridData()|
|borderData| check the [FlBorderData](base_chart.md#FlBorderData)|FlBorderData()|
|maxY| gets maximum y of y axis, if null, value will be read from the input barGroups | null|


### BarChartGroupData
|PropName		|Description	|default value|
|:---------------|:---------------|:-------|
|x| x position of the group on horizontal axis|null|
|barRods| list of [BarChartRodData](#BarChartRodData) that are a bar line| []
|barsSpace| the space between barRods of the group|2|
|showingTooltipIndicators| indexes of barRods to show the tooltip on top of them | []|


### BarChartAlignment
enum values {`start`, `end`, `center`, `spaceEvenly`, `spaceAround`, `spaceBetween`}


### BarChartRodData
|PropName|Description|default value|
|:-------|:----------|:------------|
|y|endY position of the bar on vertical axis (height of the bar)|null|
|color|colors the rod bar|Colors.blueAccent|
|width|stroke width of the rod bar|8|
|isRound|determines that the bar lines is round or qubic |true|
|backDrawRodData|if provided, draws a rod in the background of the line bar, check the [BackgroundBarChartRodData](#BackgroundBarChartRodData)|null|


### BackgroundBarChartRodData
|PropName|Description|default value|
|:-------|:----------|:------------|
|y|same as [BarChartRodData](#BarChartRodData)'s y|8|
|show|determines to show or hide this section|false|
|color|same as [BarChartRodData](#BarChartRodData)'s color|Colors.blueGrey|

### BarTouchData ([read about touch handling](handle_touches.md))
|PropName|Description|default value|
|:-------|:----------|:------------|
|enabled|determines to enable or disable touch behaviors|true|
|enableNormalTouch| set it false if you just want to handle long press|true|
|touchTooltipData|a [BarTouchTooltipData](#BarTouchTooltipData), that determines how show the tooltip on top of touched spots (appearance of the showing tooltip bubble)|BarTouchTooltipData()|
|touchExtraThreshold|an [EdgeInsets](https://api.flutter.dev/flutter/painting/EdgeInsets-class.html) class to hold a bounding threshold of touch accuracy|EdgeInsets.all(4)|
|allowTouchBarBackDraw| if sets true, touch works on backdraw bar line| false |
|handleBuiltInTouches| set this true if you want the built in touch handling (show a tooltip bubble and an indicator on touched spots) | true|
|touchCallback| listen to this callback to retrieve touch events, it gives you a [BarTouchResponse](#BarTouchResponse)| null|

### BarTouchTooltipData
 |PropName|Description|default value|
 |:-------|:----------|:------------|
 |tooltipBgColor|background color of the tooltip bubble|Colors.white|
 |tooltipRoundedRadius|background corner radius of the tooltip bubble|4|
 |tooltipPadding|padding of the tooltip|EdgeInsets.symmetric(horizontal: 16, vertical: 8)|
 |tooltipBottomMargin|bottom margin of the tooltip (to the top of most top spot)|16|
 |maxContentWidth|maximum width of the tooltip (if a text row is wider than this, then the text breaks to a new line|120|
 |getTooltipItems|a callback that retrieve [BarTooltipItem](#BarTooltipItem) by the given [BarChartGroupData](#BarChartGroupData), groupIndex, [BarChartRodData](#BarChartRodData) and rodIndex |defaultBarTooltipItem|

### BarTooltipItem
|PropName|Description|default value|
|:-------|:----------|:------------|
|text|text string of each row in the tooltip bubble|null|
|textStyle|[TextStyle](https://api.flutter.dev/flutter/dart-ui/TextStyle-class.html) of the showing text row|null|


### BarTouchResponse
|PropName|Description|default value|
|:-------|:----------|:------------|
|spot|a [BarTouchedSpot](#BarTouchedSpot) class to hold data about touched spot| null |
|touchInput|a [FlTouchInput](base_chart.md#FlTouchInput) that is the touch behaviour|null|


### BarTouchedSpot
|PropName|Description|default value|
|:-------|:----------|:------------|
|touchedBarGroup|the [BarChartGroupData](#BarChartGroupData) that user touched its rod's spot| null |
|touchedBarGroupIndex| index of touched barGroup| null|
|touchedRodData|the [BarChartRodData](#BarChartRodData) that user touched its spot|null|
|touchedRodDataIndex| index of touchedRod | null|


### Some Samples
----
##### Sample 1 ([Source Code](/example/lib/bar_chart/samples/bar_chart_sample1.dart))
<img src="https://github.com/imaNNeoFighT/fl_chart/raw/master/repo_files/images/bar_chart/bar_chart_sample_1.gif" width="300" >

<img src="https://github.com/imaNNeoFighT/fl_chart/raw/master/repo_files/images/bar_chart/bar_chart_sample_1_anim.gif" width="300" >



##### Sample 2 ([Source Code](/example/lib/bar_chart/samples/bar_chart_sample2.dart))
<img src="https://github.com/imaNNeoFighT/fl_chart/raw/master/repo_files/images/bar_chart/bar_chart_sample_2.gif" width="300" >

##### Sample 3 ([Source Code](/example/lib/bar_chart/samples/bar_chart_sample3.dart))
<img src="https://github.com/imaNNeoFighT/fl_chart/raw/master/repo_files/images/bar_chart/bar_chart_sample_3.png" width="300" >
