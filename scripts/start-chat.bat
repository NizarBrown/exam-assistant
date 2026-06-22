@echo off
cd /d %~dp0..\engine
echo ============================================
echo   RAG 考试助手 - 智能问答模式
echo ============================================
echo.
echo 正在启动本地模型...
echo.

REM 启动 llama-server
start /b "" llama-server.exe -m ..\models\qwen2.5-1.5b-q4_k_m.gguf --host 127.0.0.1 --port 8080 -c 4096 -ngl 0
echo 等待模型加载...

REM 等 llama-server 就绪
:wait_llama
timeout /t 2 /nobreak >nul
curl -s http://127.0.0.1:8080 >nul 2>&1
if %errorlevel% neq 0 goto :wait_llama
echo 模型已就绪
echo.

REM 启动 RAG 服务
cd /d %~dp0..\tools
echo 正在启动 RAG 检索服务...
start /b "" python chat_server.py 8081

REM 等 chat_server 就绪
:wait_chat
timeout /t 1 /nobreak >nul
curl -s http://127.0.0.1:8081/api/subjects >nul 2>&1
if %errorlevel% neq 0 goto :wait_chat

echo.
echo ============================================
echo   全部就绪，正在打开浏览器...
echo ============================================
start http://127.0.0.1:8081
echo.
echo 按 Ctrl+C 可停止所有服务
pause
