# ChartUI

A multiplatform `SwiftUI` chart framework.

![BarchartExample](assets/README/BarchartExample.gif) ![LinechartExample](assets/README/LinechartExample.gif)![PiechartExample](assets/README/PiechartExample.gif) 

## Features

* Bar charts
  * Multiple Bar charts


- Line charts
  - Multiple Line charts

- Pie charts



## Usage

### Installation

In Xcode go to `File -> Add Packages...` and paste in the repo's url: `https://github.com/Chocoford/ChartUI`

Chose `up to next major version` to be `0.0.2`<`1.0.0`

### basic usage

```swift
<#T##AnyChart#>() // BarChart(), LineChart(), PieChart()
    .data(<#T##ChartDataset#>)
    .options(.default)
```

### Data structures

a dataset contains `labels` and `data`, they are both `array`.

#### example

```swift
var labels: [String] = {
    var result: [String] = []
    for i in 0..<5 {
        result.append(String(format: "2021-01-%.2i", i))
    }
    return result
}()
var data: ChartData = ChartData(data: [1, 2, 3, 4, 5],
                                label: "data 1",
                                backgroundColor: ChartColor.primary)
var dataset: ChartDataset = .init(labels: labels, data: [data])
```

## Options

`ChartUI` charts take an `ChartOption` to configure itself. You can set `.automatic` to quickly apply default config.

```swift
var options: ChartOptions = .init(dataset: .init(showValue: false),
                                             axes: .automatic,
                                             coordinateLine: .automatic) 
																						 // legend is default to `.automatic`
```

options are as below:

### dataset

| name      | description                        | type   | default |
| --------- | ---------------------------------- | ------ | ------- |
| showValue | show numerical value on chart cell | `Bool` | `false` |

### axes

| name | description       | type                  | default      |
| ---- | ----------------- | --------------------- | ------------ |
| x    | Options for x axe | `AxesOptions.Options` | `.automatic` |
| y    | Options for y axe | `AxesOptions.Options` | `.automatic` |

### AxesOptions.Options

| name         | description                                      | type      | default    |
| ------------ | ------------------------------------------------ | --------- | ---------- |
| startAtZero  | indicates chart view should start at zero in `y` | `Bool`    | `true`     |
| max          | the max value should show in chart               | `Double?` | `nil`      |
| min          | the min value should show in chart               | `Double?` | `nil`      |
| showValue    | show value on axes                               | `Bool`    | `true`     |
| valuePadding | distance from value to axes                      | `CGFloat` | 6          |
| showAxes     | indicates should show axes on chart              | `Bool`    | `true`     |
| axesWidth    | the width of axes                                | `CGFloat` | 1          |
| axesColor    | the color of axes                                | `Color`   | `.primary` |

### Coordinate Line

| name | description             | type                            | default      |
| ---- | ----------------------- | ------------------------------- | ------------ |
| x    | Options for x direction | `CoordinateLineOptions.Options` | `.automatic` |
| y    | Options for y direction | `CoordinateLineOptions.Options` | `.automatic` |

#### CoordinateLineOptions.Options

| name      | description                                                  | type       | default    |
| --------- | ------------------------------------------------------------ | ---------- | ---------- |
| number    | the number of coordinate lines, `nil` indicates automatic caculating the number. | `Int?`     | `nil`      |
| lineType  | the type of coordinate lines                                 | `LineType` | `.dash`    |
| lineColor | the color of coordinate lines                                | `Color`    | `.primary` |
| lineWidth | the width of coordinate lines                                | `CGFloat`  | 0.5        |

### Legend

| name | description        | type   | default |
| ---- | ------------------ | ------ | ------- |
| show | show legend or not | `Bool` | `true`  |

## Document

[XCode Document Archive](https://github.com/chocoford/ChartUI/releases/download/v0.0.2/ChartUI.doccarchive.zip) can be import to Xcode Document.

## License

**`ChartUI` is released under the terms of the [MIT](./LICENSE) license.**

## Acknowledgement

* [AppPear](https://github.com/AppPear)/[ChartView](https://github.com/AppPear/ChartView) for starting. (yes, we start from forking it)
* [chartjs](https://github.com/chartjs)/[Chart.js](https://github.com/chartjs/Chart.js) for api design inspiration

