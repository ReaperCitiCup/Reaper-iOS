# Reaper iOS

iOS App for FOF-Navigator
Product of team Reaper
Top 20 of [Citi Financial Innovation Application Competition](http://citicup.scu.edu.cn/public/index.html)

# Main Tech

App 使用 Swift 3.0 语言编写，采用了 MVC 架构，语法更现代、可读性更强。数据加载部分利用 Alamofire 完成，从服务端得到 JSON 格式数据后转换成对应的结构体后在主线程上异步刷新。对于数据量较大的（如基金列表等），采用 MJRefresh 进行上拉/下拉刷新后分页获取，节约流量和时间。UI 展示部分，采用 xib 和代码相结合的方式构建，结构清晰、便于维护。界面风格上采取蓝白两色搭配，简洁大方，展示清晰。对于专业数据的展示，也是从服务端获取指定格式数据后，转换到 Charts 对应的图表数据格式后展示。另外对于深度分析的条目，采取表驱动策略，维护更为方便。有一些较大的图表，还可以横屏展示、双指拖动调整大小，方便查看。

# Preview
    
<table>
    <tr>
        <td><img src="https://github.com/ReaperCitiCup/Reaper-iOS/blob/master/Preview/Preview_1.png"></td>
        <td><img src="https://github.com/ReaperCitiCup/Reaper-iOS/blob/master/Preview/Preview_2.png"></td>
        <td><img src="https://github.com/ReaperCitiCup/Reaper-iOS/blob/master/Preview/Preview_3.png"></td>
        <td><img src="https://github.com/ReaperCitiCup/Reaper-iOS/blob/master/Preview/Preview_4.png"></td>
        <td><img src="https://github.com/ReaperCitiCup/Reaper-iOS/blob/master/Preview/Preview_5.png"></td>
    </tr>
</table>

# See Also

* [Server Module](https://github.com/ReaperCitiCup/Reaper-Server)
* [Web Module](https://github.com/ReaperCitiCup/Reaper-Web)
* [Mock Data](https://github.com/ReaperCitiCup/Reaper-Mock)

# Acknowledgement

Built with following 3rd party frameworks:

* [Alamofire](https://github.com/Alamofire/Alamofire)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [MJRefresh](https://github.com/CoderMJLee/MJRefresh)
* [Charts](https://github.com/danielgindi/Charts)
* [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD)
* [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)
* [BTNavigationDropdownMenu](https://github.com/PhamBaTho/BTNavigationDropdownMenu)
* [Kingfisher](https://github.com/onevcat/Kingfisher)

Produced by [songkuixi](https://github.com/songkuixi).

