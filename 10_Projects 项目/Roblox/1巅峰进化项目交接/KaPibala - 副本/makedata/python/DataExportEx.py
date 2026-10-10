import math
import os.path
import warnings
import time

import numpy as np
import pandas
import argparse

parser = argparse.ArgumentParser(description="export data to config")
parser.add_argument('--input', '-i',
                    help='input 需要导出的数据表路径，需要符合第一张sheet的名称为【同步配置】，或者第一张sheet符合同步配置')
parser.add_argument('--output', '-o', help="output 导出的excel文件存放路径")
args = parser.parse_args()


def load_sync_list(path: str):
    print("收集同步配置--------")

    def check_empty_filter(s):
        return s != ''

    sync_df = pandas.read_excel(path, sheet_name=0, header=None).replace(np.nan, '')
    sync_list = []
    # 检查配置文件是否符合规范，并检查到断行处，将结果形成表返回
    for i in range(0, math.floor(len(sync_df) / 4)):
        # 数据表
        data_row = i * 4
        data_name = sync_df.loc[data_row, 0]
        # 没有配置的数据表名，视为下面的配置不生效
        if data_name == '':
            print("没有数据名称")
            break
        data_props = list(filter(check_empty_filter, sync_df.loc[data_row][1:]))
        if len(data_props) < 1:
            warnings.warn("data %s have no props!" % data_name)
            break
        if len(data_props) != len(set(data_props)):
            warnings.warn("data %s have repeat prop name" % data_name)
            break
        # 如果没有配置数据表的第一个属性，视为不合法
        # 配置表
        cfg_row = data_row + 1
        cfg_name = sync_df.loc[cfg_row, 0]
        if cfg_name == '':
            warnings.warn("can't find cfg for data [%s]" % data_name)
            break
        cfg_props = list(filter(check_empty_filter, sync_df.loc[cfg_row][1:]))
        if len(cfg_props) < 1:
            warnings.warn("cfg %s have no props!" % data_name)
            break
        if len(cfg_props) != len(set(cfg_props)):
            warnings.warn("cfg %s have repeat prop name" % data_name)
            break
        # 检查配置表的属性名和类型
        prop_name_row = cfg_row + 1
        prop_names = list(sync_df.loc[prop_name_row][1:len(cfg_props) + 1])
        if len(prop_names) != len(cfg_props):
            warnings.warn("cfg %s prop and prop name is not same number" % cfg_name)
            break
        if len(prop_names) != len(set(prop_names)):
            warnings.warn("cfg %s prop name have repeat" % cfg_name)
            break
        prop_type_row = prop_name_row + 1
        prop_types = list(sync_df.loc[prop_type_row][1:len(cfg_props) + 1])
        sync_list.append(
            {'data_name': data_name, 'data_props': data_props, 'cfg_name': cfg_name, 'cfg_props': cfg_props,
             'prop_types': prop_types, 'prop_names': prop_names})
        print("找到同步数据[%s] - > 配置[%s]" % (data_name, cfg_name))
    # 每4行算一个文件
    return sync_list


if __name__ == '__main__':
    start_time = time.perf_counter()
    input_path = args.input
    output_path = args.output
    if input_path is None:
        # input_path = "./数据表.xlsm"
        warnings.warn("没有传入数据表路径")
        exit()
    if output_path is None:
        # output_path = "./config"
        warnings.warn("没有传入输出文件夹路径")
        exit()
    # 检测是否有文件夹，如果没有就创建
    if not os.path.exists(output_path):
        print("没有输出目录，进行创建...")
        os.makedirs(output_path)
    # 拿到同步配置表
    sync_list = load_sync_list(input_path)
    # 遍历同步表拿到数据和配置
    for info in sync_list:
        print("进行数据[%s] -> 配置[%s]的同步" % (info['data_name'], info['cfg_name']), "--------------")
        data_df = pandas.read_excel(input_path, sheet_name=info['data_name']).replace(
            np.nan, '')
        # 针对数据表进行检查
        prop_in_data = True
        for p_name in info['data_props']:
            d_props = data_df.columns.tolist()
            # 先检查所有属性名是否存在
            if p_name not in d_props:
                warnings.warn('data %s don\'t have prop named %s' % (info['data_name'], p_name))
                not_in_data = False
                break
        if not prop_in_data:
            continue
        # 重设索引
        # data_df.set_index(info['data_props'][0], inplace=True)
        # 拿数据进行配置表的组织
        # cfg_df.columns = info['cfg_props']
        cfg_df = pandas.DataFrame(columns=info['cfg_props'])
        for idx in range(0, len(info['data_props'])):
            d_prop = info['data_props'][idx]
            c_prop = info['cfg_props'][idx]
            p_type = info['prop_types'][idx]
            p_name = info['prop_names'][idx]
            d_values = data_df[d_prop]
            c_values = [p_name, p_type]
            c_values.extend(d_values)
            cfg_df[c_prop] = c_values
            print("(%d/%d)同步属性[%s][%s] -> 配置[%s][%s]" % (
            idx + 1, len(info['data_props']), info['data_name'], d_prop, info['cfg_name'], c_prop))
        cfg_df.set_index(info['cfg_props'][0], inplace=True)
        cfg_df.to_excel(output_path + "/" + info['cfg_name'] + ".xlsx")
    print("完成!用时%ds" % (time.perf_counter() - start_time))
    # cfg_df.set_index(info['cfg_props'][0])
# pd = pandas.read_excel("./aaa.xlsx")
# pd = pandas.read_excel("./数据表.xlsm", sheet_name="怪物列表", header=0, index_col=0)
# print(pd)
# df = load_sync("./数据表.xlsm")
# a = df.loc(0)
# print(a[0][0])
# a[0][0] = 111111
# print(a[0][0])
# for v in df.loc(0)[0]:
#     if v != v:
#         print(v)
#     else:
#         pass
print("done!")
