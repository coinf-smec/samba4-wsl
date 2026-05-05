# ============================================================
# 1-Setup-WSL-Samba.ps1
# ============================================================
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERRO: Execute este script como Administrador." -ForegroundColor Red
    exit 1
}

Write-Host "==> Configurando .wslconfig (modo mirrored)..." -ForegroundColor Cyan
$wslConfigPath = "$env:USERPROFILE\.wslconfig"
@"
[wsl2]
networkingMode=mirrored
firewall=true
[experimental]
hostAddressLoopback=true
"@ | Set-Content $wslConfigPath -Encoding UTF8

Write-Host "==> Desativando permanentemente o SMB Nativo do Windows..." -ForegroundColor Cyan
# Para e desabilita o serviço principal
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
Set-Service LanmanServer -StartupType Disabled

# Desabilita os drivers de Kernel que seguram a porta 445 (PID 4)
sc.exe config srvnet start= disabled
sc.exe config srv2 start= disabled
sc.exe stop srvnet
sc.exe stop srv2

Write-Host "==> Removendo regras antigas..." -ForegroundColor Cyan
$nomes = @("WSL Samba SMB TCP 445", "WSL Samba NetBIOS TCP 139", "WSL Samba UDP 137", "WSL Samba UDP 138", "WSL Samba TCP 445", "WSL Samba TCP 139")
foreach ($nome in $nomes) {
    Remove-NetFirewallRule -DisplayName $nome -ErrorAction SilentlyContinue
}

Write-Host "==> Criando Regras Definitivas para a Rede Local..." -ForegroundColor Cyan
$regras = @(
    @{ Name="WSL Samba TCP 445"; Port=445; Protocol="TCP" },
    @{ Name="WSL Samba TCP 139"; Port=139; Protocol="TCP" },
    @{ Name="WSL Samba UDP 137"; Port=137; Protocol="UDP" },
    @{ Name="WSL Samba UDP 138"; Port=138; Protocol="UDP" }
)

foreach ($r in $regras) {
    New-NetFirewallRule -DisplayName $r.Name `
                        -Direction Inbound `
                        -LocalPort $r.Port `
                        -Protocol $r.Protocol `
                        -Action Allow `
                        -Profile Any `
                        -RemoteAddress LocalSubnet | Out-Null
    Write-Host "Regra adicionada: $($r.Name)" -ForegroundColor Green
}
Write-Host "Pronto! O tráfego externo da rede local agora é permitido." -ForegroundColor Green

Write-Host "==> Reiniciando o WSL..." -ForegroundColor Cyan
wsl --shutdown

Write-Host "Concluido! Agora o Windows NUNCA MAIS usara a porta 445." -ForegroundColor Green