@echo off
title Iniciando Servidor Samba - WSL
color 0A

echo ========================================================
echo        INICIANDO SERVIDOR SAMBA (WSL2)
echo ========================================================
echo.

echo [1/3] Acordando o subsistema Linux e iniciando o smbd/nmbd...
wsl -u root -e bash -c "service smbd start && service nmbd start"

echo [2/3] Aguardando a rede estabilizar...
timeout /t 3 >nul

echo [3/3] Abrindo a pasta compartilhada...
explorer \\127.0.0.1\compartilhado

timeout /t 5 >nul