# 本地大模型考试助手

基于本地 LLM 的考试复习工具——**无需联网，数据不上传，U盘即插即用**。

只需把课件（PDF/Word/PPT）放入对应目录，一键转换为题库，然后像聊天一样向 AI 提问复习。

## 系统要求

| 项目 | 最低 | 推荐 |
|------|------|------|
| 操作系统 | Windows 10 | Windows 10/11 |
| 内存 | 2GB | 4GB+ |
| 显卡 | 无需 | 无需 |
| Python | 3.7+（仅转换工具需要） | 3.7+ |

纯 CPU 推理，无显卡也能用。

## 快速开始

### 1. 下载模型

**方式一（推荐）：** 双击 `scripts/download-model.bat`，自动下载（需联网）。

**方式二：** 手动下载放入 `models/` 目录：

| 模型 | 大小 | 说明 | 链接 |
|------|------|------|------|
| Qwen2.5-1.5B | ~1GB | 响应快，够用 | [下载](https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-q4_k_m.gguf) |
| Qwen2.5-3B | ~2.1GB | 更大，效果更好 | [下载](https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-q4_k_m.gguf) |

### 2. 准备复习资料

```
subjects/<你的科目>/materials/    ← 把课件 PDF/Word/PPT 放这里
```

双击 `tools/convert.bat`，自动将所有课件转为 TXT。

### 3. 启动

双击 `scripts/` 下的启动脚本，浏览器自动打开聊天界面：

- `start-1.5b.bat` — 小模型（1.5GB 内存）
- `start-3b.bat` — 大模型（3GB 内存）

### 4. 开始提问

在聊天框中输入问题。推荐粘贴资料原文 + 提问，回答更准确：

```
[从 docs/ 中复制相关段落]
---
请帮我总结这部分的核心概念，并出几道选择题
```

## 目录结构

```
exam-assistant/
├── engine/                  # 推理引擎（无需修改）
├── models/                  # 模型文件（自行下载）
├── scripts/                 # 启动脚本 + 下载工具
│   ├── download-model.bat    # 一键下载模型
│   ├── start-1.5b.bat        # 小模型启动
│   └── start-3b.bat          # 大模型启动
├── tools/                   # 文档转换工具
│   └── convert.bat          # 一键 PDF/Word/PPT → TXT
├── subjects/                # 科目内容（按需添加）
│   ├── _template/           # 科目模板（复制这个新建科目）
│   ├── math/                # 示例：高数
│   └── english/             # 示例：英语
├── setup.bat                # 首次使用向导
└── README.md
```

## 添加新科目

1. 复制 `subjects/_template/`，重命名为你的科目名，如 `subjects/计算机网络/`
2. 把课件 PDF/Word/PPT 放入 `materials/`
3. 双击 `tools/convert.bat` 自动转 TXT
4. 启动模型，开始复习

**不需要修改任何代码或脚本。**

## 常见问题

| 问题 | 解决 |
|------|------|
| 浏览器没打开？ | 手动访问 http://127.0.0.1:8080 |
| 提示缺少 DLL？ | 确保 `engine/` 下所有文件完整 |
| 回复很慢？ | CPU 推理正常现象，约 5-10 字/秒 |
| 转换报错？ | 确认电脑已安装 Python 3.7+ |
| 如何退出？ | 命令行窗口按 Ctrl+C |

## License

MIT
