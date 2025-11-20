# 参数配置文件详解

本文档详细解释了 `params_example.json` 文件中各个参数的作用和含义。

## 基础设置参数

| 参数名 | 类型 | 描述 |
|--------|------|------|
| NCores | 数字 | 设置并行计算使用的CPU核心数 |
| EEGLabPath | 字符串 | EEGLAB工具箱的安装路径 |
| FieldtripPath | 字符串 | FieldTrip工具箱的安装路径 |
| BrainConnectivityToolboxPath | 字符串 | Brain Connectivity Toolbox工具箱的安装路径 |

## 数据路径参数

| 参数名 | 类型 | 描述 |
|--------|------|------|
| StudyName | 字符串 | 研究名称标识符 |
| RawDataPath | 字符串 | 原始数据存储路径 |
| PreprocessedDataPath | 数组 | 预处理后数据存储路径（空数组表示未指定） |
| Session | 数组 | 实验会话列表（空数组表示未指定） |
| Run | 数组 | 运行次数列表（空数组表示未指定） |
| Task | 数组 | 任务类型列表（空数组表示未指定） |
| BidsChanloc | 字符串 | 是否使用BIDS通道位置格式("on"/"off") |
| NoseDir | 数组 | 鼻子方向设置（空数组表示未指定） |

## 参考电极坐标设置

```json
"RefCoord" : {
    "X": [],  // X坐标（空数组表示未指定）
    "Y": [],  // Y坐标（空数组表示未指定）
    "Z": []   // Z坐标（空数组表示未指定）
}
```

## 预处理参数

| 参数名 | 类型 | 描述 |
|--------|------|------|
| DownsamplingRate | 数字 | 降采样率(Hz) |
| FlatLineCriterion | 数字 | 平直线判定标准(微伏) |
| ChannelCriterion | 数字 | 通道噪声判定阈值 |
| LineNoiseCriterion | 数字 | 工频干扰判定阈值 |
| HighPass | 数组 | 高通滤波器设置[最小值, 最大值] |
| AddRefChannel | 字符串 | 是否添加参考通道("on"/"off") |
| NICARepetitions | 数字 | ICA算法重复次数 |
| ICLabel | 数组 | 独立成分标记阈值设置 |
| BurstCriterion | 数字 | 突发电流判定阈值 |
| WindowCriterion | 数字 | 时间窗口判定标准 |
| WindowCriterionTolerances | 字符串 | 时间窗口容忍度设置 |
| RejectBadTimeSegments | 字符串 | 是否拒绝不良时间片段("on"/"off") |
| EpochLength | 数字 | epoch长度(秒) |
| EpochOverlap | 数字 | epoch重叠比例 |

## 频谱分析参数

| 参数名 | 类型 | 描述 |
|--------|------|------|
| BrainFeatExtr | 布尔值 | 是否提取大脑特征 |
| FreqRes | 数字 | 频率分辨率(Hz) |
| Pad | 数组 | 数据填充方式（空数组表示未指定） |

## 频段设置

```json
"FreqBand" : {
    "theta": [],  // theta频段范围（空数组表示未指定）
    "alpha": [],  // alpha频段范围（空数组表示未指定）
    "beta": [],   // beta频段范围（空数组表示未指定）
    "gamma": []   // gamma频段范围（空数组表示未指定）
}
```

## 时频分析参数

| 参数名 | 类型 | 描述 |
|--------|------|------|
| Taper | 字符串 | 窗函数类型 |
| Tapsmofrq | 数字 | 窗函数频率平滑参数 |

## 源定位参数

| 参数名 | 类型 | 描述 |
|--------|------|------|
| HeadModelPath | 字符串 | 头部模型文件路径 |
| SurfaceModelPath | 字符串 | 表面模型文件路径 |
| AtlasPath | 字符串 | 脑区分割图谱文件路径 |

## 连接性分析参数

| 参数名 | 类型 | 描述 |
|--------|------|------|
| FreqResConnectivity | 数字 | 连接性分析频率分辨率 |
| ConnMatrixThreshold | 数字 | 连接矩阵阈值 |