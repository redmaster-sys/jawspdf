@echo off
chcp 65001 >nul
title JawsPDF - 30-Aracli PDF Studyosu
cd /d "%~dp0"
echo JawsPDF 30-Aracli PDF Motoru baslatiliyor...
start "" "http://127.0.0.1:4290"
node server.cjs
pause
