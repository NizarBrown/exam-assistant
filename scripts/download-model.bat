@echo off
chcp 65001 >nul
cd /d %~dp0..\models

echo ============================================
echo   模型下载工具
echo ============================================
echo.
echo 请选择要下载的模型：
echo   1. 小模型 Qwen2.5-1.5B （~1GB，推荐，响应快）
echo   2. 大模型 Qwen2.5-3B   （~2GB，效果更好）
echo   3. 两个都下载
echo.
set /p choice=请输入数字 (1/2/3):

if "%choice%"=="1" goto :download_15b
if "%choice%"=="2" goto :download_3b
if "%choice%"=="3" goto :download_both
echo 无效选择
pause
exit /b

:download_15b
call :do_download "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-q4_k_m.gguf" "qwen2.5-1.5b-q4_k_m.gguf"
goto :done

:download_3b
call :do_download "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-q4_k_m.gguf" "qwen2.5-3b-q4_k_m.gguf"
goto :done

:download_both
call :do_download "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-q4_k_m.gguf" "qwen2.5-1.5b-q4_k_m.gguf"
call :do_download "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-q4_k_m.gguf" "qwen2.5-3b-q4_k_m.gguf"
goto :done

:do_download
echo.
echo ============================================
echo 正在下载: %~2
echo ============================================
if exist "%~2" (
    echo [跳过] 文件已存在: %~2
    echo 如需重新下载，请先删除此文件。
    exit /b
)
powershell -Command "& { $url='%~1'; $out='%~2'; Write-Host '下载地址: ' $url; Write-Host '保存到: ' $out; Write-Host ''; $ProgressPreference='Continue'; Invoke-WebRequest -Uri $url -OutFile $out; Write-Host ''; Write-Host '下载完成!' }"
if exist "%~2" (
    echo 下载成功: %~2
) else (
    echo [失败] 下载失败，请检查网络连接后重试。
    echo 也可以手动从浏览器下载：
    echo   %~1
)
exit /b

:done
echo.
echo ============================================
echo 所有下载任务完成！
echo ============================================
pause
