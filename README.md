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

### Splash 
<img width="1917" height="1018" alt="Splash" src="https://github.com/user-attachments/assets/5370417a-e16b-4049-b521-3296e30d3556" />

### Introdução
<img width="1917" height="1017" alt="Introdução" src="https://github.com/user-attachments/assets/6c9dd677-1020-48bd-a93e-116aa3519287" />

### Ocorrências
<img width="1917" height="1017" alt="Ocorrências" src="https://github.com/user-attachments/assets/5223a575-5ed3-4f16-a94f-53fbae09a31d" />

### Detalhes da ocorrência
<img width="1917" height="1020" alt="Detalhes da ocorrência" src="https://github.com/user-attachments/assets/3cecffc4-3f98-45f3-977c-6616c4c2f0b3" />

<img width="1917" height="1018" alt="Detalhes da ocorrência em execução" src="https://github.com/user-attachments/assets/a6aec55c-8544-4efe-895b-09b1e1b14cd4" />

### Registrar ocorrência
<img width="1917" height="1020" alt="Registrar ocorrência" src="https://github.com/user-attachments/assets/4905d6e4-29fd-4c5c-a65e-34c244c348f5" />

### Bairros
<img width="1917" height="1022" alt="Bairros" src="https://github.com/user-attachments/assets/83d27c1f-e9de-4c9a-8350-6040dc1344a8" />

### Acompanhando
<img width="1917" height="1017" alt="Acompanhando" src="https://github.com/user-attachments/assets/9da6e008-19a0-4bad-bccc-8bde11d13821" />

### Sobre
<img width="1917" height="1020" alt="Sobre" src="https://github.com/user-attachments/assets/4624b916-03f2-4c94-ae0b-cbd205c7dcfa" />

<img width="1917" height="1018" alt="Sobre — configurações" src="https://github.com/user-attachments/assets/645839f0-03de-4c13-93b1-d41095255bd0" />

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


