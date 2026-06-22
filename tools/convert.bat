@echo off
chcp 65001 >nul
cd /d %~dp0

echo ============================================
echo   文档转换工具 - 资料转 TXT
echo ============================================
echo.

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Python，请先安装：
    echo   https://www.python.org/downloads/
    echo   安装时请勾选 "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

echo Python 已就绪
echo.

REM 检查并安装依赖
echo 检查依赖库...
pip install -q -r requirements.txt 2>&1
if errorlevel 1 (
    echo [警告] 依赖安装可能失败，尝试继续...
)

echo.
echo 开始转换...
echo ============================================
python convert.py
