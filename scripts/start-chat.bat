@echo off
cd /d %~dp0..\engine
echo ============================================
echo   RAG 考试助手 - 智能问答模式
echo ============================================
echo.
echo 选择模型：
echo   1. 小模型 1.5B （推荐，加载快）
echo   2. 大模型 3B   （效果好，加载慢）
echo.
set /p choice=请输入数字 (1/2):

if "%choice%"=="2" (
    set MODEL=..\models\qwen2.5-3b-q4_k_m.gguf
    set NAME=Qwen2.5-3B
) else (
    set MODEL=..\models\qwen2.5-1.5b-q4_k_m.gguf
    set NAME=Qwen2.5-1.5B
)

echo.
echo 正在启动 %NAME% ...
start /b "" llama-server.exe -m %MODEL% --host 127.0.0.1 --port 8080 -c 8192 -ngl 0
echo 等待模型加载...

:wait_llama
timeout /t 2 /nobreak >nul
curl -s http://127.0.0.1:8080 >nul 2>&1
if %errorlevel% neq 0 goto :wait_llama
echo 模型已就绪

echo.
echo 正在启动 RAG 检索服务...
cd /d %~dp0..\tools
start /b "" python chat_server.py 8081

:wait_chat
timeout /t 1 /nobreak >nul
curl -s http://127.0.0.1:8081/api/subjects >nul 2>&1
if %errorlevel% neq 0 goto :wait_chat

echo ============================================
echo   全部就绪，正在打开浏览器...
echo ============================================
start http://127.0.0.1:8081
echo.
echo 按 Ctrl+C 可停止所有服务
pause
