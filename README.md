# 🐧 Samba no WSL2 - Compartilhamento de Arquivos no Windows 11

## 💡 A Ideia do Projeto

O Windows 11 utiliza a porta **445 (SMB)** nativamente para seus próprios serviços de compartilhamento, o que impede que um servidor Samba rodando no WSL2 assuma o controle dessa porta. Isso cria um conflito clássico: você quer usar o Samba do Linux por sua flexibilidade, mas o Windows "rouba" a porta antes.

**A solução proposta:** Desativamos permanentemente os serviços SMB nativos do Windows (`LanmanServer`, `srvnet`, `srv2`) e liberamos a porta 445 para o Samba rodar dentro do WSL2. Tudo isso mantendo as regras de firewall adequadas e uma tarefa agendada para iniciar o serviço automaticamente no boot.

Com esta configuração, você tem:
- ✅ Compartilhamento nativo via Samba (com lixeira, permissões, etc.)
- ✅ Acesso de qualquer dispositivo na rede local
- ✅ Inicialização automática ao ligar o computador
- ✅ Total compatibilidade com Windows, Linux e macOS

## 📚 Documentação Completa

Para instruções detalhadas de instalação, configuração e solução de problemas, acesse:

👉 **[Clique aqui para abrir a documentação completa](./index.html)**

A documentação inclui:
- Guia passo a passo de instalação
- Comandos úteis do dia a dia
- Solução de problemas comuns
- Configuração de segurança
- Como liberar permissão de scripts no PowerShell
- Validação do ambiente

## 🚀 Resumo Rápido

```bash
# 1. Libere execução de scripts no PowerShell (como Admin)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. Execute a configuração do Windows
.\1-Setup-WSL-Samba.ps1

# 3. Reinicie o Windows

# 4. Configure o Samba no WSL
./2-setup-samba.sh seu_usuario

# 5. Crie a tarefa de boot
.\Criar-Tarefa-Boot.ps1

# 6. Valide a instalação
./valida-deploy.sh
