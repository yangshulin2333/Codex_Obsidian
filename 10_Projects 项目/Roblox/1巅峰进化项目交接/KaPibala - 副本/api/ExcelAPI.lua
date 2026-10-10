---@class ExcelApplication
---@field DisplayAlerts boolean @在程序执行过程中使出现的警告框是否显示
---@field ScreenUpdating boolean @是否刷新屏幕
---@field Visible boolean @是否显示
---@field Workbooks Workbooks @工作薄集
---@field ActiveWorkbook Workbook @激活中的工作薄
local ExcelApplication = {}
---@type fun() @如果使用此方法时未保存的工作簿处于打开状态, 则 Excel 将显示一个对话框, 询问您是否要保存所做的更改。 您可以通过在使用Quit方法或将**DisplayAlerts** 属性设置为False之前保存所有工作簿来阻止这种情况。 如果此属性为False, 则在您退出未保存的工作簿时, Excel 不会显示对话框;它会退出而不保存它们。 如果将工作簿的**Saved** 属性设置为True , 而不将工作簿保存到磁盘中, Excel 将退出, 而不会要求您保存工作簿。
function ExcelApplication:Quit()
end
---@class Workbooks @工作薄集
local Workbooks = {}
---@type fun(path:string):Workbook
---@param path string
---@return Workbooks
function Workbooks:Add(path)
end
---@class Workbook @工作薄
---@field Name string
---@field FullName string
local Workbook = {}
function Workbook:Save()
end
function Workbook:Close()
end