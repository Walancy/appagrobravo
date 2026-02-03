# Padrões de Desenvolvimento e Arquitetura - AgroBravo

Este documento define as regras e diretrizes que devem ser seguidas em todo o desenvolvimento deste projeto Flutter. **O assistente de IA TEM A OBRIGAÇÃO de consultar este arquivo a cada nova interação, antes de qualquer resposta.**

## 1. Stack Tecnológica e Bibliotecas Principais

*   **Backend & Auth:** `supabase_flutter`
*   **Gerenciamento de Dependências:** `get_it` + `injectable`
*   **Rotas e Navegação:** `go_router`
*   **Imutabilidade e Geração de Código:** `freezed` + `json_serializable`
*   **Estado:** `flutter_bloc`
*   **Assets:** `flutter_gen`
*   **Estilos:** `google_fonts` (Poppins), `flutter_svg`

## 2. Arquitetura e Estrutura de Pastas

O projeto segue uma arquitetura **Clean Architecture** baseada em **features** (módulos).

### Estrutura de Diretórios
```
lib/
├── core/
│   ├── di/                 # Injeção de dependência (configure_injection.dart)
│   ├── router/             # Configuração de rotas (app_router.dart)
│   ├── tokens/             # Design Tokens (Cores, Tipografia, Espaçamentos)
│   ├── components/         # Micro-componentes reutilizáveis
│   └── utils/              # Funcionalidades utilitárias
├── features/               # Módulos do aplicativo
│   ├── [feature_name]/
│   │   ├── presentation/
│   │   │   ├── pages/      # Pages (Scaffold)
│   │   │   ├── widgets/    # Widgets específicos da feature
│   │   │   └── cubit/      # Gerenciamento de estado (Cubits)
│   │   ├── domain/         # Entidades, usecases e interfaces de repositório
│   │   └── data/           # Implementação de repositórios, DTOs e datasources
└── main.dart
```

## 3. Design System e Tokens

*   **Fonte:** Poppins (via `google_fonts`).
*   **Tipografia:** Estilos de texto definidos em `core/tokens/app_text_styles.dart`.
    *   **REGRA DE OURO:** NUNCA use `FontWeight.bold` (ou 700+). O peso máximo permitido é `FontWeight.w600` (SemiBold).
*   **Cores:** Utilize `AppColors` (`core/tokens/`). Não use HexCodes soltos.
*   **Assets:** Utilize estritamente `Assets.images.xyz` (gerado pelo `flutter_gen`).
    *   **REGRA DE OURO:** NUNCA utilize Strings manuais para caminhos de arquivos (ex: `'assets/images/logo.png'`). Se a classe `Assets` não possui o item, rode o `build_runner`.
    *   **Processo de Adição:** 
        1. Adicione o arquivo físico em `assets/images/`.
        2. Verifique se a pasta está mapeada no `pubspec.yaml`.
        3. Execute: `flutter pub run build_runner build --delete-conflicting-outputs`.
    *   **Erro de Carregamento:** Se o asset existe no `.gen.dart` mas falha ao carregar no App, realize um **FULL RESTART** (parar e rodar novamente), pois o Hot Restart não reconstrói o bundle de assets em todos os casos.
*   **Micro-componentes:** Sempre verifique `core/components/` antes de criar algo novo. Priorize criar componentes pequenos e reutilizáveis.

## 4. Integração com Supabase (Backend)

*   **Inicialização:** Inicialize o Supabase no `main.dart` antes do `runApp`.
*   **Tipagem:** Crie DTOs tipados usando `freezed` para representar as tabelas do Supabase. Evite usar `Map<String, dynamic>` cru na camada de domínio.
*   **Repositórios:** Todo acesso a dados deve passar por um **Repository** (interface no Domain, implementação no Data). Nunca chame o Supabase diretamente na UI.
*   **Segurança (RLS):** Assuma que as regras de segurança (RLS) estão configuradas no banco. Trate erros de permissão adequadamente.

## 5. Diretrizes RÍGIDAS para o Assistente (IA)

Estas regras devem ser seguidas **sem exceção**:

1.  **Leitura Obrigatória:** Antes de sugerir qualquer código, leia este arquivo (`CODING_STANDARDS.md`) para se re-contextualizar.
2. **Verificação de Componentes e UI (Rigidez Máxima):**
    *   **Proibido Styles Hardcoded:** Nunca aplique cores ou tamanhos fixos diretamente na Page.
    *   **Fluxo Obrigatório:**
        1.  Liste o diretório `core/components`.
        2.  Se o componente existir, reuse-o.
        3.  Se não existir e for reutilizável, crie-o em `core/components` *antes* de continuar a tela.
        4.  Se for específico da feature, crie em `features/[feature]/presentation/widgets`.
    *   **Design System:** Use estritamente os Tokens de `AppColors` e `AppTextStyles`.

3.  **Clean Code:**
    *   Não coloque lógica de negócio em arquivos de UI (`presentation`). Use Cubits/Blocs.
    *   Nomeie arquivos em `snake_case` e classes em `PascalCase`.
    *   Comente apenas decisões complexas de arquitetura, evite comentários óbvios.

4.  **Supabase e Modelagem de Dados:**
    *   **SQL Completo:** Sempre que sua solução envolver novas tabelas ou colunas, forneça o bloco SQL DDL para criar a tabela E, obrigatoriamente, as **RLS Policies** (Row Level Security) para garantir a segurança dos dados.
    *   **Tipagem Espelhada:** Os modelos Dart (`@freezed`) devem ter campos correspondentes exatos às colunas do banco (usando `@JsonKey(name: 'coluna_sql')` se necessário).
    *   **Isolamento:** Erros do Supabase (`PostgrestException`) devem ser capturados no Repository e convertidos para Erros de Domínio amigáveis antes de chegar à UI.
5.  **Geração de Código:** Ao finalizar uma alteração que envolva `@injectable`, `@freezed` ou assets, execute (ou instrua a executar) o comando: `flutter pub run build_runner build --delete-conflicting-outputs`.
## 6. Padronização de Geração de Código (Freezed & Injectable)

*   **Freezed:** 
    *   **OBRIGATÓRIO:** Todas as classes anotadas com `@freezed` devem ser declaradas como `abstract class` (ex: `abstract class UserEntity with _$UserEntity`). Isso evita erros de "missing implementation" quando utilizamos mixins ou métodos customizados.
    *   **Métodos Customizados:** Ao adicionar getters ou métodos em uma entidade ou model, adicione o construtor privado obrigatório: `const MyClass._();`.
*   **Injectable:** Sempre use `@injectable` ou `@lazySingleton` e lembre-se de rodar o `build_runner`.
    *   **ERRO "Bad state: GetIt...":** Esse erro acontece quando você cria uma classe `@injectable` mas esquece de rodar o `build_runner` para registrá-la. SEMPRE rode o comando após criar ou renomear arquivos injetáveis.

## 7. Diretrizes RÍGIDAS Finais

1.  **Imports Absolutos OBRIGATÓRIOS:**
    *   **NUNCA** use imports relativos que "subam" níveis (ex: `../../core`). Use `package:agrobravo/...`.
2.  **Manutenção de Estado:** Utilize `flutter_bloc` (Cubits são preferíveis para lógicas simples).
3.  **UI Consistency:** Siga os tokens de design (Poppins, SemiBold max, AppColors).
4.  **Verificação de Sintaxe OBRIGATÓRIA:**
    *   **Construtores e Blocos:** Antes de finalizar uma edição em Widgets, verifique meticulosamente o fechamento de chaves `}` e parênteses `)`. Evite aninhar declarações de construtores (`const MyWidget({ ... const MyWidget({ ...`) por COPY/PASTE incorreto.
    *   **Combinação de Modificadores:** Não use `const` em construtores que não podem ser `const`.
    *   **Inicialização:** Garanta que todos fields `final` sejam inicializados no construtor.
