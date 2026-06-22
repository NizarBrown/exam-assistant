@echo off
echo ============================================
echo   本地大模型考试助手 - 首次设置
echo ============================================
echo.

REM 检查模型文件
if not exist "models\qwen2.5-1.5b-q4_k_m.gguf" (
    if not exist "models\qwen2.5-3b-q4_k_m.gguf" (
        echo [提示] 未找到模型文件！
        echo.
        echo 一键下载：双击 scripts\download-model.bat
        echo.
        echo 或手动下载放入 models\ 目录：
        echo   小模型 ^(1.5B, ~1GB^):
        echo     https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-q4_k_m.gguf
        echo   大模型 ^(3B, ~2.1GB^):
        echo     https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-q4_k_m.gguf
        echo.
    )
)

REM 列出可用科目
echo 已安装的科目：
echo.
set count=0
for /d %%d in (subjects\*) do (
    set /a count+=1
    set "name=%%~nxd"
    if not "!name!"=="_template" (
        echo   !count!. !name!
    )
)
if !count!==0 (
    echo   （暂无科目）
    echo.
    echo 添加方法：
    echo   1. 复制 subjects\_template\ 并重命名
    echo   2. 把课件 PDF/Word/PPT 放入 materials\
    echo   3. 双击 tools\convert.bat
)
echo.
echo 启动方式：
echo   小模型: scripts\start-1.5b.bat
echo   大模型: scripts\start-3b.bat
echo.
pause
