@echo off
setlocal enabledelayedexpansion

:: 1. Ensure output folder exists
if not exist "AudioOut" mkdir "AudioOut"

:: 2. Define your track list in exact order (Index 0, Index 1, Index 2, etc.)
::    Separate each name with a semicolon (;). DO NOT use spaces around the semicolons!
set "TRACKS=Jump;Coin;Hurt;Powerup;Laser;Explosion;Pause;Blip;Select;Victory"

:: 3. Process the list and export
set "idx=0"
for %%a in (%TRACKS%) do (
    echo Exporting index !idx! as "%%a.wav"...
    
    "C:\Program Files\FamiStudio\FamiStudio.exe" NES_Jam_SFX.fms wav-export ".\AudioOut\%%a.wav" -export-songs:!idx! -wav-export-mode:duration
    
    set /a idx+=1
)

echo Done!
pause