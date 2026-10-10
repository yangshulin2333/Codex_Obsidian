from asyncore import read
from math import fabs
from pickle import FALSE
from asyncore import read
import xlwings as xw
import os
import sys
import time
import math
import multiprocessing as mp
from multiprocessing import Pool
import collections.abc

core = mp.cpu_count()

t__ = time.time()

num_to_char = {
    0:'A',1:'B',2:'C',3:'D',4:'E',5:'F',6:'G',7:'H',8:'I',9:'J',
    10:'K',11:'L',12:'M',13:'N',14:'O',15:'P',16:'Q',17:'R',18:'S',19:'T',
    20:'U',21:'V',22:'W',23:'X',24:'Y',25:'Z',
}

def GetCharFromNumber(num):
    num = num - 1
    a = math.floor(num / 26)
    if a == 0:
        return num_to_char[num]
    else:
        b = num % 26
        return num_to_char[a-1] + num_to_char[b]


err_mark = False #标记程序是否异常退出
NoneType = "NoneType"

#源Excel表路径
source_path = sys.argv[1]#"数据采集.xlsm" #sys.argv[1]
#config路径
config_path = sys.argv[2]#"Config" #sys.argv[2]

#打开app 显示关闭
app = xw.App(visible=False,add_book=False)
app.screen_updating = False
app.display_alerts = False
#打开源Excel
xls = app.books.open(source_path,update_links=False)
#获取第一个Sheet（数据采集）
sheet = xls.sheets[0]
info = sheet.used_range
#最大行数
row = info.last_cell.row
#最大列数
col = info.last_cell.column
tab_list = {}

#切分数据采集sheet
def Split():
    #定义索引值
    count = 1
    #遍历所有行
    for i in range(1,row):
        if i%2 == 1:
            #拿到第i行的数据
            fst_col2 = sheet.range("A"+str(i+1)).expand('right').value
            #拿到上一行的数据
            fst_col1 = sheet.range("A"+str(i)).expand('right').value
            tab_list[count] = {1:fst_col1,2:fst_col2}
            count = count + 1
    return 

#根据str找到对应的config的xls
def GetXls(str):
    path = config_path + "\\" + str + ".xlsx"
    if not os.path.exists(path):
        path = config_path + "/" + str + ".xlsx"
        if not os.path.exists(path):
            print(path+" 路径不存在！请查看！")
            return False
    t_xls = app.books.open(path)
    return t_xls

#检查id唯一性
def CheckIdOnly(L):
    rel = []
    if not isinstance(L,collections.abc.Iterable):
        return True
    for val in L:
        if val != None:
            rel.append(val)
    if not isinstance(rel,collections.abc.Iterable):
        return True
    repeatList = []
    setList = set(rel)
    flag=True
    if len(rel) != len(setList):
        flag=False
        print('列表的id存在重复，其中重复项及重复次数如下：')
        for each_item in setList:
            re_count = 0
            for each_item_L in rel:
                if each_item == each_item_L:
                    re_count += 1
            if (re_count >= 2):
                print(rel.index(each_item), ": ", re_count)
        return flag
    else:
        return flag

#转表
def TransFrom():
    global err_mark
    for id,list in tab_list.items():
        my_err = False
        sourse = list[1]
        target = list[2]
        if not sourse:
            continue
        if not target:
            continue
        #源Excel表
        s_xls = xls.sheets[sourse[0]]
        rng = s_xls.used_range
        #源表最大行数
        s_row = rng.last_cell.row
        #源表最大列数
        s_col = rng.last_cell.column
        first_row_s = s_xls[0,:s_col].value
        #目标Excel表
        t_xls = GetXls(target[0])
        if t_xls:
            #目标表的sheet
            t_sheet = t_xls.sheets[0]
            #目标表最大列数
            t_col = t_sheet.used_range.last_cell.column
            # t_row = t_sheet.used_range.last_cell.row
            t_sheet.used_range.offset(3,0).delete()
            first_row_t = t_sheet[0,:t_col].value
            for index in range(1,len(sourse)):
                s_col_name = sourse[index]#源表的列名
                t_col_name = target[index]#目标表的列名
                #print(s_col_name,"----",t_col_name)
                try:
                    t_col_num = first_row_t.index(t_col_name) + 1#目标表的列数
                except ValueError:
                    err_mark = True
                    print("Config/"+t_xls.name+".xlsx 表中没有"+t_col_name)
                    xls.close()
                    t_xls.close()
                    app.quit()
                    return 
                try:
                    s_col_num = first_row_s.index(s_col_name) + 1#源表的列数
                except ValueError:
                    err_mark = True
                    print("数据采集表中/"+s_xls.name+" 表中没有"+s_col_name)
                    xls.close()
                    t_xls.close()
                    app.quit()
                    return 
                #按列数读取数据并写进目标表
                read_str = GetCharFromNumber(s_col_num)+str(2)+":"+GetCharFromNumber(s_col_num)+str(s_row)
                write_str = GetCharFromNumber(t_col_num)+str(4)
                format_str = GetCharFromNumber(t_col_num) + str(4) + ":" + GetCharFromNumber(t_col_num) + str(s_row + 2)
                values = s_xls[read_str].value
                if index == 1:
                    if not CheckIdOnly(values):
                        print(t_xls.name+"中存在重复id！！！ +++++++++++++++++++++++++++++++++++++++")
                        my_err = True
                        break
                # t_sheet.range(write_str).api.NumberFormat = "@"
                t_sheet.range(format_str).number_format = "@"
                # t_sheet[write_str].number_format = '@'
                t_sheet.range(write_str).options(transpose=True).value = values
                # t_sheet.range(write_str).api.NumberFormat = "@"
            if not my_err :
                print(t_xls.name + "完成！----------------------------------------------------------")
            t_xls.save()
            t_xls.close()
    return

Split()


TransFrom()

if not err_mark:
    xls.save()
    xls.close()
    app.quit()

print(time.time() - t__)

