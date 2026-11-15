@echo off
setlocal enabledelayedexpansion

rem ==========================================
rem CONFIGURATION
rem ==========================================
set "FAMISTUDIO=C:\Program Files\FamiStudio\FamiStudio.exe"
set "FFMPEG=C:\Program Files\FFMPEG\ffmpeg.exe"
set "OUTDIR=.\SFXOut"

set "TRACKS=Start;Pause;"
rem ==========================================

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

set "idx=0"
for %%a in (%TRACKS%) do (
    echo ----------------------------------------------------
    echo [1/2] FamiStudio: Exporting index !idx! as "%%a.wav"...
    
    rem 1. Export standard file from FamiStudio
    "%FAMISTUDIO%" "NES_Jam_SFX.fms" wav-export "%OUTDIR%\%%a.wav" -export-songs:!idx! -wav-export-mode:duration
    
    echo [2/2] FFmpeg: Trimming trailing silence from "%%a.wav"...
    
    rem 2. Micro-SFX Optimized FFmpeg Filter:
    rem    - Sets window=0 and detection=peak to read ultra-short files sample-by-sample
    rem    - Sets an ultra-sensitive threshold of -80dB to preserve faint tails
    "%FFMPEG%" -y -i "%OUTDIR%\%%a.wav" -af "areverse,silenceremove=start_periods=1:start_threshold=-80dB:window=0:detection=peak,areverse" -c:a pcm_s16le "%OUTDIR%\%%a_trimmed.wav" >nul 2>&1
    
    move /y "%OUTDIR%\%%a_trimmed.wav" "%OUTDIR%\%%a.wav" >nul
    
    set /a idx+=1
)

echo.
echo ==========================================
echo Bulk Export and Perfect Silence Trim Complete!
echo ==========================================
pause