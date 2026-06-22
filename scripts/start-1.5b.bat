@echo off
cd /d %~dp0..\engine
echo ============================================
echo   本地大模型 - 小模型模式 (Qwen2.5-1.5B)
echo   需要约 1.5GB 可用内存
echo ============================================
echo.
echo 正在启动，浏览器会自动打开...
echo 如果浏览器没打开，手动访问 http://127.0.0.1:8080
echo.
echo 按 Ctrl+C 可停止服务
echo ============================================
echo.
timeout /t 2 >nul
start http://127.0.0.1:8080
llama-server.exe -m ..\models\qwen2.5-1.5b-q4_k_m.gguf --host 127.0.0.1 --port 8080 -c 4096 -ngl 0
pause
