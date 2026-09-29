# Histórico de versões

## [1.0.0-beta] — 2026-09-29

Primeira beta publicada sob o novo versionamento. A API continua sendo a da LuaInterface; esta mudança renomeia a linha de versão e deixa os guias centrados no uso real da biblioteca.

- README e guias reescritos em português com exemplos de janela, tabs, controles, ícones e configuração.
- Exemplo HitboxExpander: aba Reach com transparência 0–1 e contorno Box opcional; aba Helper com plataforma soldada, tamanho, cor e visibilidade.
- Sem mudança intencional nos nomes dos métodos públicos nesta beta.

## Histórico anterior à beta

### 5.4.8 — 2026-09-28

- `SetScale()` passou a escalar a janela, não o `ScreenGui` inteiro; centralização usa posição relativa.
- O atalho global do menu não dispara um segundo keybind de componente.
- Arraste disponível no cabeçalho e no título, por mouse ou toque.

### 5.4.7 — 2026-09-28

- O primeiro layout aguarda o `ViewportSize` válido da câmera e preserva uma posição definida pelo script.

### 5.4.6 — 2026-09-28

- O layout ignora widgets da Home removida e o retorno assíncrono do avatar verifica se a página ainda existe.

### 5.4.5 — 2026-09-28

- O chunk retorna a tabela da API ao ser carregado com `loadstring`.

### 5.4.4 — 2026-09-28

- Abas e exemplos de uso, registro de SVG, tema Obsidian, seleção da primeira aba própria e conveniência `Window:AddKeybind`.
