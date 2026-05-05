# ============================================================
# Criar-Tarefa-Boot.ps1
# Cria uma tarefa para rodar o .bat de inicialização do Samba
# ao fazer logon, com 20 segundos de atraso.
# ============================================================

$NomeDaTarefa = "WSL_Samba_Startup"
$CaminhoDoBat = "C:\TI\scripts\Iniciar-Servidor.bat"

Write-Host "==> Verificando arquivo .bat..." -ForegroundColor Cyan
if (-not (Test-Path $CaminhoDoBat)) {
    Write-Host "ERRO: Arquivo $CaminhoDoBat nao encontrado!" -ForegroundColor Red
    Write-Host "Crie o arquivo .bat no local indicado antes de rodar este script." -ForegroundColor Yellow
    exit
}

Write-Host "==> Removendo tarefa antiga (se existir)..." -ForegroundColor Cyan
Unregister-ScheduledTask -TaskName $NomeDaTarefa -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "==> Configurando a Acao..." -ForegroundColor Cyan
# Configura o cmd.exe para chamar o arquivo .bat
$Acao = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$CaminhoDoBat`""

Write-Host "==> Configurando o Gatilho (Logon + Atraso de 20s)..." -ForegroundColor Cyan
# PT20S é o padrão ISO 8601 para "Period Time 20 Seconds"
$Gatilho = New-ScheduledTaskTrigger -AtLogOn
$Gatilho.Delay = "PT20S"

Write-Host "==> Registrando a Tarefa Agendada..." -ForegroundColor Cyan
# RunLevel Highest garante que o .bat terá os privilégios necessários
Register-ScheduledTask -TaskName $NomeDaTarefa `
                       -Action $Acao `
                       -Trigger $Gatilho `
                       -RunLevel Highest `
                       -Force | Out-Null

Write-Host "Sucesso! A tarefa '$NomeDaTarefa' foi criada." -ForegroundColor Green
Write-Host "Sempre que voce fizer login no Windows, o sistema aguardara 20 segundos e executara o servidor." -ForegroundColor Green