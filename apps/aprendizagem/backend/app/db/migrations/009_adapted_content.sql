-- 009_adapted_content.sql
-- Substitui content_blocks das 16 licoes regulares por versao com texto
-- adaptado por faixa etaria (mais ricos, com mais analogias do dia a dia
-- e referencias culturais por idade).
--
-- NAO toca em challenges, prompt_templates, slugs, xp_reward, age_band
-- ou ordem - apenas o conteudo dos blocos de texto exibidos no Lesson
-- Player.
--
-- Idempotente via gate no run_migrations.sh (sentinel: frase exclusiva
-- do novo conteudo "brinquedo que parecia pensar sozinho").
--
-- Slugs corrigidos pra bater com 005 (alguns que vieram no pedido eram
-- versoes encurtadas: s1-como-conversar -> s1-como-conversar-claude,
-- s2-json -> s2-json-lingua-apis, etc).

BEGIN;

-- ============================================================
-- STAGE 1 (age_band 6-8) - tom infantil, analogias com brinquedos/desenhos
-- ============================================================

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Você já brincou com um brinquedo que parecia pensar sozinho? Como um carrinho que desvia de paredes ou um boneco que fala quando você aperta a barriga? A Inteligência Artificial, que chamamos de IA, é parecida com isso — mas muito, muito mais esperta! É um computador que aprendeu a pensar lendo bilhões de palavras, histórias e conversas. Imagina ler todos os livros da biblioteca da sua escola ao mesmo tempo. A IA fez isso, só que com livros do mundo inteiro!"},
  {"type":"text","content":"Você já reparou que quando assiste um desenho no YouTube, ele vai sugerindo outros desenhos que você adora? Isso é IA trabalhando! Ou quando você digita uma palavra no celular e ele já sugere a próxima? IA de novo! Ela aprende do jeito que você aprende a montar um Lego: tentando, errando, tentando de novo, até ficar perfeito."},
  {"type":"text","content":"A IA não é um monstro nem um robô malvado de filme. Ela não tem corpo nem emoções. É mais como um livro gigante super inteligente que aprendeu a responder perguntas. A palavra Inteligência Artificial existe desde 1956, muito antes de existir internet, tablet ou YouTube!"}
]
$blocks$::jsonb
WHERE slug = 's1-o-que-e-ia';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"A Claude é uma amiga computador superinteligente! Ela foi criada por uma turma de cientistas chamada Anthropic — pessoas que trabalham todos os dias para fazer a IA mais segura e bonzinha do mundo. É como se eles fossem os criadores de um personagem de desenho animado, só que esse personagem conversa de verdade!"},
  {"type":"text","content":"A Claude tem três superpoderes incríveis. Primeiro: ela entende qualquer pergunta, até as mais difíceis! Segundo: ela escreve histórias, poemas, adivinhações e muito mais. Terceiro: ela explica as coisas de um jeito que você consegue entender, como um professor superlegal. Parece a Hermione Granger, mas em formato de computador!"},
  {"type":"text","content":"Uma coisa muito especial sobre a Claude: ela nunca inventa respostas. Se ela não souber algo, ela fala eu não sei com sinceridade. Isso é raro e muito importante! Você pode confiar no que ela diz, porque ela é honesta como um bom amigo de verdade."}
]
$blocks$::jsonb
WHERE slug = 's1-quem-e-claude';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Conversar com a Claude é fácil como mandar uma mensagem para um amigo! Você escreve o que quer e ela responde. Mas existe um segredo mágico para receber respostas ainda mais incríveis. Esse segredo tem um nome especial: Prompt. Prompt é tudo que você escreve para a Claude — é o seu pedido mágico!"},
  {"type":"text","content":"Pensa assim: imagina que você quer pedir para alguém desenhar seu personagem favorito. Se você só fala desenha um personagem, a pessoa não sabe se é de cabeça grande, pequeno, com capa ou com espada. Mas se você fala desenha o Naruto com o uniforme laranja, fazendo o jutsu de clonagem, com fundo de folhas caindo — aí sim! Com a Claude é igual: quanto mais você explica, mais incrível fica a resposta."},
  {"type":"text","content":"As regras de ouro são simples: seja CLARO sobre o que quer, conta um pouquinho da situação, e diz como quer a resposta. E se não entender a resposta, pode pedir de novo de um jeito diferente. A Claude nunca fica brava com perguntas! É como pedir para a Alexa tocar uma música: quanto mais específico, mais certo ela acerta."}
]
$blocks$::jsonb
WHERE slug = 's1-como-conversar-claude';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"A Claude é tipo aquele livro de história interativo onde você escolhe o caminho — só que ainda melhor! Você inventa os personagens, o lugar onde acontece e o tipo de aventura, e a Claude escreve a história inteirinha na hora. É como ter um autor de livros da Disney disponível só para você!"},
  {"type":"text","content":"Para a melhor história possível, você precisa caprichar no pedido. Diga o nome do personagem principal (pode ser você mesmo!), se é aventura, mistério ou comédia, onde acontece tudo — floresta mágica? espaço sideral? escola de feitiçaria? — e se quer final feliz ou surpresa. A Claude consegue escrever como um livro de criança, um conto de fadas ou até como as histórias do Diário de um Banana!"},
  {"type":"text","content":"O mais legal: você pode pedir para a Claude CONTINUAR uma história que você mesmo começou. Escreve o começo e ela termina para você! Ou se chegou num final que você não gostou, é só pedir um final diferente. Você é o diretor da sua própria história!"}
]
$blocks$::jsonb
WHERE slug = 's1-claude-conta-historias';

-- ============================================================
-- STAGE 2 (age_band 9-10) - APIs e dados, analogias com jogos
-- ============================================================

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Sabe quando você está jogando Fortnite ou Roblox e o servidor sabe exatamente onde está cada jogador, quantas vidas tem, o que está carregando — tudo em tempo real? Isso funciona através de APIs! API significa Application Programming Interface, e é basicamente o jeito que dois programas se comunicam pela internet sem você ver o que acontece por baixo."},
  {"type":"text","content":"Pensa assim: no Minecraft, quando você abre o inventário, o jogo busca na memória o que você tem guardado e exibe na tela. API funciona igual, mas entre programas diferentes: um app no seu celular pede dados para um servidor na internet, o servidor processa e responde com as informações. É como mandar uma mensagem no WhatsApp e receber a resposta — só que entre programas!"},
  {"type":"text","content":"Tem uma API divertidíssima chamada PokéAPI que tem dados completos de todos os Pokémons, completamente grátis! Quando você acessa pokeapi.co/api/v2/pokemon/pikachu no navegador, em segundos aparecem todos os dados do Pikachu: tipo, altura, peso, habilidades, movimentos. É como um Pokédex digital funcionando ao vivo! O mundo tem mais de 24.000 APIs públicas e gratuitas — jogos, filmes, músicas, países, clima, tudo."}
]
$blocks$::jsonb
WHERE slug = 's2-o-que-e-api';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Quando uma API responde, ela manda os dados num formato chamado JSON. Parece um código estranho na primeira vez, mas depois de entender a lógica, você vai ler qualquer JSON fácil! Pensa como os dados de um personagem de RPG: ele tem nome, nível, vida, ataque — cada atributo tem um nome e um valor. JSON é exatamente isso, organizado com chaves e valores."},
  {"type":"text","content":"Por exemplo, os dados do Pikachu em JSON ficam assim: o campo name vale pikachu, o campo height vale 4, o campo weight vale 60. Igual às stats de um personagem no Pokémon GO! Cada informação tem um lugarzinho específico com uma etiqueta. Quer saber o tipo? Olha o campo types. Quer saber as habilidades? Olha o campo abilities. É como a tela de status de um RPG, mas em texto."},
  {"type":"text","content":"Em JSON você vai encontrar 4 tipos de coisas. Texto sempre fica entre aspas, como pikachu. Números ficam sem aspas, como 4 ou 60. Listas ficam entre colchetes [], perfeitas para guardar vários itens como os tipos de um Pokémon. E objetos ficam entre chaves {}, como a ficha completa de um personagem. Com esse mapa, você consegue ler qualquer JSON de qualquer API!"}
]
$blocks$::jsonb
WHERE slug = 's2-json-lingua-apis';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Você sabia que existe uma API gratuita para quase qualquer coisa que você curte? Sem cadastro, sem cartão de crédito, só abrir o navegador e usar. É tipo mods gratuitos para a internet — qualquer um pode acessar! Aqui vão as melhores para explorar agora mesmo."},
  {"type":"text","content":"A PokéAPI tem dados completos de todos os Pokémons, incluindo imagens, movimentos, evoluções e stats. O catfact.ninja/fact retorna um fato aleatório sobre gatos toda vez que você acessa. O REST Countries tem tudo sobre qualquer país: bandeira, capital, população, idiomas. O JokeAPI tem piadas em vários idiomas com modo safe. E o Open-Meteo tem dados de clima em tempo real de qualquer cidade do mundo, sem criar conta."},
  {"type":"text","content":"O mais legal: você pode acessar essas URLs diretamente no navegador, igual abre um site normal! Tenta abrir agora uma aba nova e digita: pokeapi.co/api/v2/pokemon/charizard. Você vai ver o JSON completo do Charizard aparecendo na tela. Depois, é só copiar e colar esse JSON para a Claude — e ela explica tudo!"}
]
$blocks$::jsonb
WHERE slug = 's2-apis-gratuitas';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Você já imaginou combinar dados reais de uma API com a inteligência da Claude? É o equivalente de colocar um mod de IA no seu jogo favorito — tudo fica mais poderoso! A ideia é simples: você pega os dados crus da API, que parecem confusos em JSON, e pede para a Claude transformar em algo incrível."},
  {"type":"text","content":"Por exemplo: você acessa a PokéAPI, pega os dados do Charizard e do Blastoise, cola para a Claude e pede com esses dados reais, quem ganharia uma batalha e por quê? Ela analisa os stats verdadeiros e cria um comentário de batalha épico! Você tem os dados — a Claude tem a criatividade!"},
  {"type":"text","content":"Esse combo é o que apps famosos que você usa fazem o tempo todo. O YouTube busca dados das suas visualizações via API e usa IA para recomendar o próximo vídeo. O Spotify busca dados das suas músicas e usa IA para criar o Descobertas da Semana. Você está aprendendo a base do que as maiores empresas de tecnologia do mundo usam. E com 9 ou 10 anos!"}
]
$blocks$::jsonb
WHERE slug = 's2-claude-apis-superpoder';

-- ============================================================
-- STAGE 3 (age_band 11-12) - codigo e sites, analogias com Instagram/Spotify
-- ============================================================

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Sabe quando você abre o Instagram e a tela carrega as fotos, os stories aparecem no topo, o botão de curtir funciona com aquela animação de coração — tudo isso foi escrito por alguém em código. Código é um conjunto de instruções precisas que o computador executa linha por linha. É como uma receita que o computador segue à risca, sem improvisação."},
  {"type":"text","content":"Na web, existe uma tríade que você precisa conhecer. HTML define o que existe na página: esse botão existe aqui, esse texto vai aparecer ali, essa imagem fica nesse espaço. CSS define como tudo parece: a cor do botão, o tamanho da fonte, a animação do coração do Instagram. JavaScript define o que acontece quando você interage: clicou no botão? Abre um menu. Deslizou a tela? Carrega mais posts."},
  {"type":"text","content":"A melhor notícia de todas: com a Claude, você não precisa decorar sintaxe nem passar meses estudando. Você descreve o que quer em português e ela escreve o código. É como ter um dev sênior disponível 24 horas pronto para criar qualquer coisa que você imaginar. O que você precisa aprender é a descrever bem o que quer — e isso você já está praticando com os prompts!"}
]
$blocks$::jsonb
WHERE slug = 's3-o-que-e-codigo';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Imagina ter um desenvolvedor full stack que não cobra nada, não reclama de pedidos difíceis e explica cada linha do código que escreve. É exatamente isso que a Claude faz! Ela escreve em HTML, CSS, JavaScript, Python, SQL e dezenas de outras linguagens. E diferente de tutoriais no YouTube, ela cria especificamente o que você pediu — não um projeto genérico qualquer."},
  {"type":"text","content":"O segredo para resultados profissionais está no nível de detalhe do pedido. Em vez de cria um site sobre música, tente: tema, seções que quer, estilo visual, funcionalidades específicas, se precisa funcionar no celular. Quanto mais você parece um cliente explicando para um dev o que quer, melhor fica o resultado."},
  {"type":"text","content":"Para testar tudo sem instalar nada, existe o CodePen.io — um editor online gratuito onde você cola o HTML/CSS/JS da Claude e vê o resultado ao vivo em segundos. E se algo não ficou do jeito que imaginou? É só pedir ajuste: torna o fundo mais escuro, faz o botão animado, adiciona uma seção de contato. A Claude itera quantas vezes você quiser, sem reclamar."}
]
$blocks$::jsonb
WHERE slug = 's3-claude-escreve-codigo';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Você já reparou como alguns sites têm aquele visual profissional — fontes certas, cores que combinam, animações suaves — enquanto outros parecem feitos sem cuidado? A diferença não é só o programador, é o nível de detalhe do projeto. Com a Claude, você consegue o mesmo nível de qualidade — só precisa saber pedir com precisão."},
  {"type":"text","content":"A receita tem 6 ingredientes obrigatórios. TEMA: sobre o que é o site? PÚBLICO: para quem é? SEÇÕES: quais partes você quer? CORES: qual paleta visual? EXTRAS: animações, efeitos hover, cards interativos? DISPOSITIVO: precisa funcionar bem no celular, porque a maioria das pessoas acessa pelo celular hoje."},
  {"type":"text","content":"Compare: o pedido fraco seria faz um site sobre k-pop. O pedido profissional seria crie um site HTML/CSS/JS completo para fãs de k-pop da geração Z. Seções: hero com animação de texto, top 5 grupos com cards interativos, playlist embed. Dark mode com gradiente rosa-roxo neon, fonte moderna. Totalmente responsivo para mobile. Veja a diferença de resultado que isso faz!"}
]
$blocks$::jsonb
WHERE slug = 's3-receita-site-perfeito';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Sabe a diferença entre um site estático — tipo um panfleto digital que sempre mostra as mesmas informações — e um app como o TikTok, Instagram ou Spotify? O app busca dados novos da internet em tempo real através de APIs. Cada vez que você abre o TikTok, ele chama uma API que retorna os vídeos mais relevantes para você naquele momento."},
  {"type":"text","content":"No código, isso acontece com JavaScript usando uma função chamada fetch. Você coloca a URL de uma API, o código bate na porta do servidor, o servidor responde com JSON, e você usa esses dados para atualizar o que aparece na tela — tudo sem recarregar a página. É a tecnologia por trás de toda experiência moderna de internet que você usa."},
  {"type":"text","content":"Para aplicar agora: peça para a Claude criar um app de busca de Pokémons onde o usuário digita o nome, clica em buscar, e o JavaScript usa fetch para chamar a PokéAPI e mostrar imagem, tipo, altura e peso. A Claude escreve todo o código. Você entende a lógica. Você testa no CodePen. É um app real, com dados reais, que você construiu!"}
]
$blocks$::jsonb
WHERE slug = 's3-site-api-app-real';

-- ============================================================
-- STAGE 4 (age_band 12+) - prompt engineering profissional, mercado
-- ============================================================

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Prompt Engineering é a capacidade de se comunicar com sistemas de IA de forma estratégica e precisa para maximizar a qualidade dos resultados. Em um mercado onde IA está sendo integrada em praticamente todas as áreas — advocacia, medicina, marketing, engenharia, design — quem sabe direcionar IA com maestria tem uma vantagem competitiva real e mensurável."},
  {"type":"text","content":"Os 5 pilares que definem um Prompt Engineer competente: PERSONA (instruir a IA sobre o papel que deve assumir), CONTEXTO (fornecer todas as informações relevantes sem pressupor que a IA já sabe), OBJETIVO (ser hiper-específico sobre o entregável), FORMATO (especificar estrutura da resposta — tabela, JSON, markdown, bullet points), EXEMPLOS (mostrar exemplos do que é qualidade para aquele caso específico)."},
  {"type":"text","content":"Prompt Engineer é uma das profissões mais bem compensadas do mercado de tecnologia atual. Nos EUA, salários chegam a 175 mil dólares anuais em empresas como Anthropic, OpenAI e Google DeepMind. No Brasil e Europa, a demanda cresce rapidamente. Você está desenvolvendo esse skill agora, antes da maioria dos profissionais do mercado."}
]
$blocks$::jsonb
WHERE slug = 's4-prompt-engineering';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"No mercado profissional, a diferença entre quem usa IA de forma mediana e quem extrai resultados excepcionais está fundamentalmente na qualidade dos prompts. Não é sobre o modelo de IA, não é sobre qual plataforma — é sobre a qualidade da instrução. Empresas que perceberam isso estão criando prompt libraries internas e treinando equipes em técnicas avançadas de prompting."},
  {"type":"text","content":"Compare dois prompts para a mesma tarefa: o fraco seria cria um email de vendas. O profissional seria crie um email de vendas B2B para prospectar CMOs de startups de tecnologia com 50-200 funcionários. Produto: plataforma de analytics que reduz tempo de análise em 60%. Tom: direto, data-driven, sem buzzwords. Estrutura: hook com estatística, proposta de valor em 2 frases, social proof, CTA para demo de 20 minutos. Limite: 250 palavras. O resultado é incomparável."},
  {"type":"text","content":"O teste mental que separa prompts medianos de prompts excelentes: Se eu fosse um profissional sênior recebendo esse briefing, teria todas as informações necessárias para entregar o resultado sem precisar adivinhar nada? Se houver qualquer ambiguidade sobre público, formato, tom, objetivo ou restrições — o prompt ainda não está completo."}
]
$blocks$::jsonb
WHERE slug = 's4-prompts-poderosos-vs-fracos';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"System Prompt é a camada de instruções que define o comportamento base de um agente de IA antes de qualquer interação com o usuário. É invisível para o usuário final, mas determina completamente a personalidade, as restrições, o conhecimento de domínio e o formato de resposta do agente. Toda vez que você usa um chatbot de atendimento de uma empresa, existe um System Prompt bem estruturado por trás."},
  {"type":"text","content":"Um System Prompt profissional tem componentes claros: IDENTIDADE E PROPÓSITO (quem é o agente, para que foi criado), PERSONALIDADE E TOM (formal, técnico, empático, direto?), CONHECIMENTO DE DOMÍNIO (em que tópicos é especialista), REGRAS OPERACIONAIS (o que sempre faz, o que nunca faz), FORMATO DE OUTPUT (estrutura padrão das respostas, uso de markdown, comprimento esperado)."},
  {"type":"text","content":"Empresas como Duolingo, Notion, Intercom e GitHub Copilot investem significativamente em Prompt Engineering para System Prompts — é a diferença entre uma IA genérica e um produto de IA com identidade e utilidade real. Saber construir System Prompts eficazes abre portas em product management, engenharia de IA e fundação de startups."}
]
$blocks$::jsonb
WHERE slug = 's4-system-prompts';

UPDATE lessons SET content_blocks = $blocks$
[
  {"type":"text","content":"Claude Code é a interface da Claude que opera diretamente no sistema de arquivos local via terminal. Diferente da versão web — que só conversa — o Claude Code age: lê e escreve arquivos, executa comandos, instala dependências, roda testes, faz commits no Git, e constrói projetos completos de forma autônoma. Developers que adotaram Claude Code reportam aumentos de produtividade de 3x a 5x."},
  {"type":"text","content":"MCP — Model Context Protocol — é um padrão aberto lançado pela Anthropic em 2024 que resolve um problema fundamental: como conectar IA a ferramentas e contextos externos de forma padronizada e segura. Com MCP, a Claude pode ser conectada a qualquer serviço: navegador web, Google Drive, GitHub, Slack, Notion, banco de dados. Em vez de a IA ser um sistema isolado, ela passa a operar como parte integrada de um ecossistema de ferramentas."},
  {"type":"text","content":"A convergência de Claude Code + MCP + Prompt Engineering está criando uma nova categoria de profissional: o AI Engineer, alguém que orquestra sistemas de IA para construir produtos reais. Esse profissional é extremamente raro e extremamente valorizado. Empresas de todos os portes estão correndo para encontrar pessoas com esse perfil. Você está aprendendo a base disso agora — antes da maioria dos profissionais do mercado sequer entender o que é MCP."}
]
$blocks$::jsonb
WHERE slug = 's4-claude-code-mcp';

COMMIT;
