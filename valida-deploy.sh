#!/bin/bash
# ============================================================
# valida-deploy.sh - Roda no WSL
# Verifica a saúde completa de toda a integração Windows/WSL
# ============================================================

echo "======================================================"
echo "  INICIANDO VALIDAÇÃO COMPLETA DO DEPLOY SAMBA/WSL"
echo "======================================================"

# 1. Verifica se a porta 445 está livre no Windows
echo -n "[Teste 1] Serviço nativo do Windows (LanmanServer) desativado? "
LMS_STATE=$(powershell.exe -c "(Get-Service LanmanServer).StartType" | tr -d '\r')
if [[ "$LMS_STATE" == *"Disabled"* ]]; then
    echo "✅ SIM (Disabled)"
else
    echo "❌ NÃO ($LMS_STATE) - Rode o 1-Setup-WSL-Samba.ps1 novamente."
fi

# 2. Verifica os Drivers Ocultos (PID 4)
echo -n "[Teste 2] Drivers srvnet (PID 4) desativados? "
SRV_STATE=$(powershell.exe -c "(Get-Service srvnet -ErrorAction SilentlyContinue).StartType" | tr -d '\r')
if [[ "$SRV_STATE" == *"Disabled"* ]] || [[ -z "$SRV_STATE" ]]; then
    echo "✅ SIM"
else
    echo "❌ NÃO - O Windows ainda vai roubar a porta 445 na reinicialização."
fi

# 3. Verifica Serviço Samba
echo -n "[Teste 3] Serviço Samba (smbd) está rodando no WSL? "
if service smbd status | grep -q "is running"; then
    echo "✅ SIM"
else
    echo "❌ NÃO - Rode: sudo service smbd start"
fi

# 4. Verifica Porta no Linux
echo -n "[Teste 4] Samba assumiu a porta 445 no WSL? "
if ss -tulpn 2>/dev/null | grep -q ":445 "; then
    echo "✅ SIM"
else
    echo "❌ NÃO - Há um conflito de porta ou o serviço caiu."
fi

# 5. Verifica Autostart (Tarefa Agendada) - NOME ATUALIZADO
echo -n "[Teste 5] Tarefa agendada para boot junto com Windows existe? "
TASK_STATE=$(powershell.exe -c "Get-ScheduledTask -TaskName 'WSL_Samba_Startup' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty State" | tr -d '\r')
if [[ "$TASK_STATE" == "Ready" ]] || [[ "$TASK_STATE" == "Running" ]]; then
    echo "✅ SIM ($TASK_STATE)"
else
    echo "❌ NÃO - Tarefa não encontrada. O Samba não iniciará no boot."
fi

# 6. Verifica Pasta Compartilhada
WIN_USER=$(powershell.exe -c "Write-Host -NoNewline \$env:USERNAME" | tr -d '\r')
SHARE_PATH="/mnt/c/Users/$WIN_USER/Documents/compartilhado"
echo -n "[Teste 6] A pasta $SHARE_PATH existe? "
if [ -d "$SHARE_PATH" ]; then
    echo "✅ SIM"
else
    echo "❌ NÃO"
fi

echo "======================================================"