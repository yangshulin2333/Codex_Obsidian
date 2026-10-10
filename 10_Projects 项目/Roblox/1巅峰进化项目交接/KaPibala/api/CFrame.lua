---@class CFrame @CFrame（坐标框架）是坐标框架的缩写，是一种用于旋转和定位3D对象的数据类型。 作为对象属性或独立单元，CFrame包含全局X，Y和Z坐标以及每个轴的旋转数据。 此外，CFrames包含有用的功能，可用于处理3D空间中的对象。
---@field X number @位置的x坐标
---@field Y number @位置的y坐标
---@field Z number @位置的z坐标
---@field LookVector Vector3 @CFrame方向的前向分量。
---@field RightVector Vector3 @CFrame方向的右方向分量。
---@field UpVector Vector3 @CFrame方向的向上方向部分。
---@field Position Vector3 @CFrame的3D位置
CFrame = {}
---@type fun():CFrame @创建一个空白标识CFrame。
---@return CFrame
function CFrame.new()
end
---@type fun(param:Vector3):CFrame @从Vector3创建一个CFrame
---@param pos Vector3 @位置信息
---@return CFrame
function CFrame.new()
end
---@type fun(param:Vector3,param:Vector3):CFrame @不建议使用此构造方法，而推荐使用CFrame.fromMatrix（）创建lookVector。 Itt会在pos处创建一个CFrame，其lookVector指向lookAt位置。
---@param pos Vector3 @位置信息
---@param lookAt Vector3 @朝向信息
---@return CFrame
function CFrame.new()
end
---@type fun(param:number,param:number,param:number):CFrame @从位置（x，y，z）创建一个CFrame。
---@param x number
---@param y number
---@param z number
---@return CFrame
function CFrame.new()
end
---@type fun(param:number,param:number,param:number,param:number,param:number,param:number,param:number):CFrame @根据位置（x，y，z）和四元数（qX，qY，qZ，qW）创建CFrame
---@param x number
---@param y number
---@param z number
---@param qX number
---@param qY number
---@param qZ number
---@param qW number
---@return CFrame
function CFrame.new()
end
---@type fun(param:number,param:number,param:number,param:number,param:number,param:number,param:number,param:number,param:number,param:number,param:number,param:number):CFrame @从位置（x，y，z）创建CFrame，其方向由旋转矩阵[[R00 R01 R02] [R10 R11 R12] [R20 R21 R22]]指定
---@param x number
---@param y number
---@param z number
---@param R00 number
---@param R01 number
---@param R02 number
---@param R10 number
---@param R11 number
---@param R12 number
---@param R20 number
---@param R21 number
---@param R22 number
---@return CFrame
function CFrame.new()
end
---@type fun(param:number,param:number,param:number):CFrame @使用弧度角（rx，ry，rz）创建旋转的CFrame。 旋转按Z，Y，X顺序应用。
---@param rx number
---@param ry number
---@param rz number
---@return CFrame
function CFrame.fromEulerAnglesXYZ()
end
---@type fun(param:number,param:number,param:number):CFrame @使用弧度角（rx，ry，rz）创建旋转的CFrame。 旋转以Y，X，Z顺序应用。
---@param rx number
---@param ry number
---@param rz number
---@return CFrame
function CFrame.fromEulerAnglesYXZ()
end
---@type fun(param:number,param:number,param:number):CFrame @等效于fromEulerAnglesXYZ
---@param rx number
---@param ry number
---@param rz number
---@return CFrame
function CFrame.Angles()
end
---@type fun(param:number,param:number,param:number):CFrame @等效于fromEulerAnglesYXZ
---@param rx number
---@param ry number
---@param rz number
---@return CFrame
function CFrame.fromOrientation()
end
---@type fun(param:Vector3,param:number):CFrame @根据单位Vector3创建旋转的CFrame，并以弧度为单位旋转
---@param v Vector3
---@param r number
---@return CFrame
function CFrame.fromAxisAngle()
end
---@type fun(param:Vector3,param:Vector3,param:Vector3,param:Vector3):CFrame @根据平移和旋转矩阵的列创建CFrame。 如果排除vz，则第三列计算为[vx：Cross（vy）.Unit]。
---@param pos Vector3
---@param vX Vector3
---@param vY Vector3
---@param vZ Vector3
---@return CFrame
function CFrame.fromMatrix()
end
---@type fun():CFrame @返回此CFrame的逆
---@return CFrame
function CFrame:Inverse()
end
---@type fun(param:CFrame,param:number):CFrame @返回在CFrame和目标之间按分数Alpha插值的CFrame
---@param goal CFrame
---@param alpha number
---@return CFrame
function CFrame:Lerp()
end
---@type fun(param:CFrame):CFrame @返回从Object转换为World空间的CFrame。 等效于[CFrame * cf]
---@param cf CFrame
---@return CFrame
function CFrame:ToWorldSpace()
end
---@type fun(param:CFrame):CFrame @返回从世界转换为对象空间的CFrame。 等效于[CFrame：inverse（）* cf]
function CFrame:ToObjectSpace()
end
---@type fun(param:Vector3):CFrame @返回从Object转换为World空间的Vector3。 等效于[CFrame * v3]
---@param v3 Vector3
---@return Vector3
function CFrame:PointToWorldSpace()
end
---@type fun(param:Vector3):Vector3 @返回从World转换为Object空间的Vector3。 等效于[CFrame：inverse（）* v3]
---@param v3 Vector3
---@return Vector3
function CFrame:PointToObjectSpace()
end
---@type fun(param:Vector3):Vector3 @返回从Object旋转到World空间的Vector3。 等效于[（CFrame-CFrame.p）* v3]
---@param v3 Vector3
---@return Vector3
function CFrame:VectorToWorldSpace()
end
---@type fun(param:Vector3):Vector3
---@param v3 Vector3
---@return Vector3
function CFrame:VectorToObjectSpace()
end
---@type fun():table[] @返回值：x，y，z，R00，R01，R02，R10，R11，R12，R20，R21，R22，其中R00-R22表示CFrame的3x3旋转矩阵，xyz表示CFrame的位置。
---@return table
function CFrame:GetComponents()
end
---@type fun():number,number,number @如果按Z，Y，X顺序应用角度，则返回可用于生成CFrame的近似角度
---@return number,number,number
function CFrame:ToEulerAnglesXYZ()
end
---@type fun():number,number,number @如果按Z，X，Y顺序应用角度，则返回可用于生成CFrame的近似角度
---@return number,number,number
function CFrame:ToEulerAnglesYXZ()
end
---@type fun():number,number,number @如果按Z，X，Y顺序应用角度，则返回可用于生成CFrame的近似角度（等效于toEulerAnglesYXZ）
---@return number,number,number
function CFrame:ToOrientation()
end
---@type fun():Vector3,number @返回一个Vector3的元组和一个数字，该数字表示CFrame在轴角表示中的旋转
---@return Vector3,number
function CFrame:ToAxisAngle()
end