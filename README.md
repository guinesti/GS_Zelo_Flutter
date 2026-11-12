# Zelo — Zeladoria Colaborativa

Aplicativo mobile em **Flutter/Dart** desenvolvido para a **Global Solution 2026.2 da FIAP** — disciplina de Cross-Platform Application Development.

## Desenvolvedores

| Gabriel Borges Medeiros | RM556142 |
| Guilherme de Nicola Nesti | RM555044 |
| Matheus Lion Muzzi Theodoro Nogueira | RM555764 |

## Tema da Global Solution

**Desafio FIAP: CitizenTech** — tecnologias criadas a partir das necessidades reais das pessoas, colocando o cidadão no centro da inovação. Entre as sugestões do briefing está a de _plataformas de zeladoria colaborativa para identificar, priorizar e acompanhar problemas dos espaços públicos_, que é a proposta do Zelo.

**ODS relacionados:** 11 (Cidades e comunidades sustentáveis), 9 (Indústria, inovação e infraestrutura) e 10 (Redução das desigualdades).

## Descrição da solução

O Zelo é uma plataforma em que moradores registram problemas dos espaços públicos do bairro — buracos, iluminação apagada, lixo acumulado e calçadas quebradas. Outros moradores confirmam as ocorrências, o sistema calcula uma prioridade e o painel público mostra os indicadores de cada bairro.

No app, o morador pode:

- Registrar uma ocorrência com categoria, descrição e endereço (preenchido automaticamente pelo CEP).
- Ver as ocorrências ordenadas por prioridade, com busca e filtros.
- Confirmar ocorrências de outros moradores, o que aumenta a prioridade delas.
- Acompanhar ocorrências e ver cada etapa do atendimento (registrada, em análise, em execução, resolvida).
- Avaliar a solução depois que a ocorrência é resolvida.
- Consultar o painel público com indicadores por bairro.

**Cálculo de prioridade** (`PrioridadeService`): gravidade da categoria + número de confirmações + dias em aberto + bônus para locais próximos a escolas, hospitais e pontos de ônibus.

**Agrupamento automático:** ao registrar uma ocorrência da mesma categoria no mesmo CEP ou endereço de uma ocorrência aberta, o app não cria duplicidade — o registro vira uma confirmação da ocorrência existente.

**Funcionamento offline:** as ocorrências ficam salvas no aparelho com `SharedPreferences`.

## APIs utilizadas

| API                | Endpoint                                                                               | Uso no app                                                  |
| ------------------ | -------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| IBGE — Localidades | `GET https://servicodados.ibge.gov.br/api/v1/localidades/municipios/3550308/distritos` | Lista os bairros (distritos) de São Paulo no painel público |
| ViaCEP             | `GET https://viacep.com.br/ws/{cep}/json/`                                             | Preenche rua e bairro ao registrar uma ocorrência           |

As duas são públicas e não exigem chave. As respostas JSON são convertidas nos models `Bairro` e `Endereco`.

Os estados **inicial, carregando, sucesso e erro** são tratados com o enum `ViewState`:

- **Tela Bairros:** carregamento com indicador, lista com busca em caso de sucesso e tela de erro com mensagem e botão **Tentar novamente**.
- **Consulta de CEP:** mensagem de orientação no estado inicial, indicador durante a consulta, endereço encontrado no sucesso e mensagem com **Tentar novamente** no erro (sem internet, tempo esgotado, CEP inexistente ou inválido).

## Fluxo de telas

```
Splash ──(SharedPreferences: introdução já vista?)──┬── não ──► Introdução (4 páginas) ──► Início
                                                    └── sim ──► Início

Início (navegação inferior)
├── Ocorrências ──► Detalhes da ocorrência
│        └──────► Registrar ocorrência (ViaCEP)
├── Bairros (API IBGE) ──► Detalhes do bairro (indicadores) ──► Detalhes da ocorrência
├── Acompanhando ──► Detalhes da ocorrência
└── Sobre ──► Rever introdução
```

| Tela                   | Descrição                                                                                               |
| ---------------------- | ------------------------------------------------------------------------------------------------------- |
| Splash                 | Logo, verificação da introdução no `SharedPreferences` e redirecionamento automático                    |
| Introdução             | 4 páginas com ícone, título e descrição; botões Voltar/Avançar, Pular e "Não mostrar novamente"         |
| Ocorrências            | Lista ordenada por prioridade, busca, filtro por categoria, filtro "só abertas", acompanhar e atualizar |
| Detalhes da ocorrência | Informações, confirmações, linha do tempo do status, confirmar, acompanhar e avaliar                    |
| Registrar ocorrência   | Formulário validado com busca de endereço pelo CEP                                                      |
| Bairros                | Lista de bairros vinda da API do IBGE, com busca                                                        |
| Detalhes do bairro     | Indicadores (abertas, % resolvidas, tempo médio de resolução, satisfação) e ocorrências do bairro       |
| Acompanhando           | Ocorrências acompanhadas pelo morador, com remover e desfazer                                           |
| Sobre                  | Proposta, ODS, fontes de dados, rever introdução e restaurar dados de exemplo                           |

**Passagem de parâmetros:** a tela de detalhes da ocorrência recebe o `id` (String) e a tela de detalhes do bairro recebe o objeto `Bairro` vindo da API. A tela de registro devolve uma mensagem para a lista com `Navigator.pop(resultado)`.

## Prints das telas

## Arquitetura

O projeto separa interface, modelos, serviços e acesso aos dados. As telas não contêm regras de negócio: elas chamam os serviços e atualizam a interface com `setState`.

```
lib/
├── main.dart                 # Ponto de entrada
├── app.dart                  # MaterialApp, tema e rotas
├── core/                     # Rotas nomeadas, tema, estados de tela e utilitários
├── models/                   # Ocorrencia, Bairro, Endereco, Categoria, StatusOcorrencia, Prioridade...
├── services/                 # Regras de negócio e acesso a dados
│   ├── bairro_service.dart          # API do IBGE (http)
│   ├── cep_service.dart             # API ViaCEP (http)
│   ├── ocorrencia_repository.dart   # Persistência local, confirmação, agrupamento, indicadores
│   ├── prioridade_service.dart      # Cálculo de prioridade
│   └── preferences_service.dart     # Preferência da introdução
├── screens/                  # Telas (StatefulWidget/StatelessWidget), uma pasta por funcionalidade
└── widgets/                  # Widgets personalizados reutilizáveis
```

| Camada       | Responsabilidade                                                                                                                                                                                                                                                                                     |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **screens**  | Montar a interface e reagir às ações do usuário                                                                                                                                                                                                                                                      |
| **widgets**  | Componentes reutilizados: `OcorrenciaCard`, `Etiqueta`, `CategoriaAvatar`, `CampoBusca`, `SeletorCategoria`, `EstadoErro`, `EstadoCarregando`, `EstadoMensagem`, `IndicadorCard`, `Secao`, `LinhaInfo`, `LinhaDoTempoStatus`, `AvaliacaoEstrelas`, `ConsultaCepCard`, `OnboardingPagina`, `ZeloLogo` |
| **services** | Consumo das APIs, persistência e regras de negócio                                                                                                                                                                                                                                                   |
| **models**   | Estruturas de dados e conversão de/para JSON                                                                                                                                                                                                                                                         |
| **core**     | Rotas, tema, estados de tela e utilitários                                                                                                                                                                                                                                                           |

**Gerenciamento de estado:** `setState` em `StatefulWidget`. Widgets que só exibem dados são `StatelessWidget`.

**Pacotes:** `http` (requisições REST) e `shared_preferences` (introdução, ocorrências, itens acompanhados e confirmações).

## Atendimento aos requisitos

| Requisito                                                                                               | Onde está                                                                                                                            |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Splash com logo, transição e verificação no SharedPreferences                                           | `screens/splash/splash_screen.dart`                                                                                                  |
| Introdução com 3+ páginas, Voltar/Avançar e "Não mostrar novamente"                                     | `screens/onboarding/onboarding_screen.dart`                                                                                          |
| 4+ telas principais, navegação, parâmetros e retorno                                                    | `core/app_routes.dart`, `screens/shell/home_shell.dart`                                                                              |
| WebService com `http`, models e 4 estados com nova tentativa                                            | `services/bairro_service.dart`, `services/cep_service.dart`, `screens/bairros/bairros_screen.dart`, `widgets/consulta_cep_card.dart` |
| Widgets Column, Row, Card, ListView, GridView, Scaffold, AppBar, botões, Icon, IconButton e Image.asset | Todas as telas; `Image.asset` em `widgets/zelo_logo.dart`, `GridView` em `detalhe_bairro_screen.dart`                                |
| Interações: item da lista → detalhes, busca, filtros, acompanhar, confirmar, avaliar, atualizar         | `ocorrencias_screen.dart`, `detalhe_ocorrencia_screen.dart`, `acompanhando_screen.dart`                                              |
| Organização, separação de responsabilidades e widgets reutilizáveis                                     | Estrutura descrita em Arquitetura                                                                                                    |

## Como executar

Pré-requisito: Flutter 3.24 ou superior.

```bash
# 1. Gerar as pastas de plataforma (android, ios...) — mantém o código em lib/
flutter create . --project-name zelo --org br.com.fiap --platforms android,ios

# 2. Instalar as dependências
flutter pub get

# 3. Rodar
flutter run
```

Testes unitários (prioridade, models e utilitários):

```bash
flutter test
```

> O arquivo `android/app/src/main/AndroidManifest.xml` já inclui a permissão de internet, necessária para o build de release consumir as APIs.

## Vídeo pitch

Link (YouTube, público): **ADICIONAR LINK**
