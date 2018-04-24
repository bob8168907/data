按F8 在 Debug 模式下，进入下一步，如果当前行断点是一个方法，则不进入当前方法体内，跳到下一条执行语句
按F7在 Debug 模式下，进入下一步，如果当前行断点是一个方法，则进入当前方法体内，如果该方法体还有方法，则会进入该内嵌的方法中 .
        继续按F7，则跳到StopWatch() 构造方法中。
        跳出该方法，可以按Shift+F8，在 Debug 模式下，跳回原来地方。
当我们执行到第二个断点处，如果想直接执行到第三个断点处，可以按F9。
Alt+F8 可以通过在 Debug 的状态下，选中对象，弹出可输入计算表达式调试框，查看该输入内容的调试结果 。
    

F9            resume programe 恢复程序
Alt+F10       show execution point 显示执行断点
F8            Step Over 相当于eclipse的f6      跳到下一步
F7            Step Into 相当于eclipse的f5就是  进入到代码
Alt+shift+F7  Force Step Into 这个是强制进入代码
Shift+F8      Step Out  相当于eclipse的f8跳到下一个断点，也相当于eclipse的f7跳出函数
Atl+F9        Run To Cursor 运行到光标处
ctrl+shift+F9   debug运行java类
ctrl+shift+F10  正常运行java类
alt+F8          debug时选中查看值
