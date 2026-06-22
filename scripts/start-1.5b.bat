@echo off
cd /d %~dp0engine
echo ============================================
echo   本地大模型 - 小模型模式 (Qwen2.5-1.5B)
echo   需要约 1.5GB 可用内存
echo ============================================
echo.
echo 正在加载模型（约 10-20 秒），请稍候...
echo.
echo 按 Ctrl+C 可停止服务
echo ============================================
echo.

start /b "" llama-server.exe -m ..\models\qwen2.5-1.5b-q4_k_m.gguf --host 127.0.0.1 --port 8080 -c 4096 -ngl 0

:wait_loop
timeout /t 2 /nobreak >nul
curl -s http://127.0.0.1:8080 >nul 2>&1
if %errorlevel% equ 0 goto :ready
echo 模型加载中，请稍候...
goto :wait_loop

:ready
echo.
echo 服务器就绪，正在打开浏览器...
start http://127.0.0.1:8080
echo 如果浏览器没打开，手动访问 http://127.0.0.1:8080
pause
