-- Migration 023: Insere conteudo da Stage 6 "Missao 06 - IA para criar"
--
-- Foco: criar com IA - prompts visuais (sujeito/estilo/iluminacao/perspectiva/
-- emocao), estilos visuais (anime/cyberpunk/aquarela/etc), criacao de
-- personagens, worldbuilding/storytelling, e o limite da IA criativa
-- vs experiencia humana.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=6, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 6
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's6-criar-imagens-ia',
  'Como criar imagens incríveis com IA',
  'How to create amazing images with AI',
  'Aprender os elementos de um prompt visual profissional',
  'Learn the elements of a professional visual prompt',
  '6-18', 6, 1,
  $$[
    {"type":"text","content":"A chave para criar imagens incríveis com IA está no prompt visual. Um prompt de imagem tem elementos diferentes de um prompt de texto. SUJEITO: o que é a imagem? Um dragão, uma cidade futurista, uma criança explorando uma floresta. ESTILO ARTÍSTICO: como deve parecer? Foto realista, anime, aquarela, pixel art, cyberpunk. ILUMINAÇÃO: luz do sol ao entardecer, luz neon roxa, iluminação dramática."},
    {"type":"text","content":"PERSPECTIVA: vista de cima, close no rosto, plano geral, ângulo cinematográfico. EMOÇÃO: épico e grandioso, calmo e sereno, misterioso, alegre e colorido. Compare: FRACO: Um cachorro na floresta. PROFISSIONAL: Um lobo dourado na floresta encantada ao entardecer, luz laranja penetrando entre as árvores, estilo pintura digital fantasia, perspectiva cinematográfica, atmosfera épica e misteriosa."},
    {"type":"text","content":"Quanto mais você especifica cada elemento, mais a IA consegue criar exatamente o que você imaginou. Um prompt de imagem profissional pode ter 3 ou 4 linhas — cada linha adicionando uma camada de detalhe que transforma o resultado."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"The key to creating amazing images with AI is the visual prompt. An image prompt has different elements from a text prompt. SUBJECT: what is the image? A dragon, a futuristic city, a child exploring a forest. ARTISTIC STYLE: how should it look? Photorealistic, anime, watercolor, pixel art, cyberpunk. LIGHTING: sunset sunlight, purple neon light, dramatic lighting."},
    {"type":"text","content":"PERSPECTIVE: top view, face close-up, wide shot, cinematic angle. EMOTION: epic and grand, calm and serene, mysterious, happy and colorful. Compare: WEAK: A dog in the forest. PROFESSIONAL: A golden wolf in an enchanted forest at sunset, orange light piercing through giant trees, digital fantasy painting style, cinematic perspective, epic and mysterious atmosphere."},
    {"type":"text","content":"The more you specify each element, the better AI can create exactly what you imagined. A professional image prompt can have 3 or 4 lines — each line adding a layer of detail that transforms the result."}
  ]$$::jsonb,
  'A criança escolhe um personagem favorito e cria um prompt de imagem com os 5 elementos. A Atena avalia e ajuda a melhorar cada elemento.',
  'The child picks a favorite character and creates an image prompt with the 5 elements. Atena evaluates and helps improve each element.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-estilos-visuais',
  'Estilos visuais — o vocabulário do criador',
  'Visual styles — the creator vocabulary',
  'Conhecer os principais estilos visuais e quando usar cada um',
  'Know the main visual styles and when to use each one',
  '6-18', 6, 2,
  $$[
    {"type":"text","content":"Estilos visuais são como idiomas da arte. Quanto mais você conhece, mais preciso e poderoso fica seu prompt. Anime e Mangá: estilo japonês com olhos grandes e traços expressivos — ideal para personagens jovens e histórias de aventura. Pixel Art: arte em blocos quadrados, estilo games retrô — perfeito para projetos de games. Cyberpunk: neon colorido, chuva, tecnologia futurista em cidade sombria."},
    {"type":"text","content":"Aquarela: pinceladas suaves, cores que se misturam — sensação artística e poética. Fotorrealismo: parece uma fotografia real — ideal para visualizar produtos e arquitetura. Cartoon: linhas grossas, cores vibrantes, expressões exageradas — divertido e ideal para crianças. Dark Fantasy: ambientes sombrios, criaturas fantásticas, atmosfera épica e misteriosa. Minimalista: poucos elementos, muito espaço em branco, elegante e limpo."},
    {"type":"text","content":"Misturar estilos também funciona: estilo aquarela com elementos cyberpunk cria algo completamente único. Não existe regra — existe o que serve melhor para a história que você quer contar."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Visual styles are like languages of art. The more you know, the more precise and powerful your prompt becomes. Anime and Manga: Japanese style with big eyes and expressive lines — ideal for young characters and adventure stories. Pixel Art: block art, retro game style — perfect for game projects. Cyberpunk: colored neon, rain, futuristic technology in a dark city."},
    {"type":"text","content":"Watercolor: soft brushstrokes, blending colors — artistic and poetic feeling. Photorealism: looks like a real photo — ideal for visualizing products and architecture. Cartoon: thick lines, vibrant colors, exaggerated expressions — fun and ideal for children. Dark Fantasy: dark environments, fantastic creatures, epic and mysterious atmosphere. Minimalist: few elements, lots of white space, elegant and clean."},
    {"type":"text","content":"Mixing styles also works: watercolor style with cyberpunk elements creates something completely unique. There are no rules — there is only what serves best for the story you want to tell."}
  ]$$::jsonb,
  'A criança cria o mesmo cenário em 3 estilos diferentes e compara como o estilo muda completamente a sensação da imagem.',
  'The child creates the same scene in 3 different styles and compares how style completely changes the feeling of the image.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-criando-personagens-ia',
  'Criando personagens com IA',
  'Creating characters with AI',
  'Aprender a criar personagens completos com aparência, personalidade e história',
  'Learn to create complete characters with appearance, personality and story',
  '6-18', 6, 3,
  $$[
    {"type":"text","content":"Uma das formas mais poderosas de usar IA criativa é criar personagens. Um personagem completo tem muito mais do que aparência — tem personalidade, história, poderes, fraquezas. IA pode ajudar em cada camada: APARÊNCIA: a IA de imagem cria o visual com características físicas e estilo artístico. PERSONALIDADE: a IA de texto cria traços de personalidade, forma de falar, medos e sonhos."},
    {"type":"text","content":"HISTÓRIA: de onde veio, o que aconteceu, por que é assim. PODERES E HABILIDADES: para personagens de fantasia, a IA ajuda a criar habilidades balanceadas. NOME: a IA pode gerar dezenas de opções com significados, origens e sonoridades diferentes."},
    {"type":"text","content":"O processo criativo ideal: você descreve a ideia geral. A IA expande. Você reage e melhora. A IA ajusta. É uma conversa criativa onde você é o diretor e a IA é o estúdio de animação. Quanto mais você participar ativamente, mais único e pessoal fica o resultado."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"One of the most powerful ways to use creative AI is to create characters. A complete character has much more than appearance — it has personality, history, powers, weaknesses. AI can help at each layer: APPEARANCE: image AI creates the visual with physical characteristics and artistic style. PERSONALITY: text AI creates personality traits, way of speaking, fears and dreams."},
    {"type":"text","content":"HISTORY: where they came from, what happened, why they are the way they are. POWERS AND SKILLS: for fantasy characters, AI helps create balanced abilities. NAME: AI can generate dozens of options with different meanings, origins and sounds."},
    {"type":"text","content":"The ideal creative process: you describe the general idea. AI expands. You react and improve. AI adjusts. It is a creative conversation where you are the director and AI is the animation studio. The more actively you participate, the more unique and personal the result becomes."}
  ]$$::jsonb,
  'A criança cria um personagem completo com a Atena — aparência, personalidade, história e poderes. A Atena guia cada etapa.',
  'The child creates a complete character with Atena — appearance, personality, history and powers. Atena guides each step.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-storytelling-universos',
  'Storytelling com IA — criando universos',
  'Storytelling with AI — creating universes',
  'Aprender a construir universos narrativos completos com IA',
  'Learn to build complete narrative universes with AI',
  '6-18', 6, 4,
  $$[
    {"type":"text","content":"Storytelling é a arte de contar histórias. Com IA, qualquer pessoa pode construir um universo narrativo completo. Todo universo tem camadas: MUNDO: onde se passa? Qual é a física, a magia, as regras? CONFLITO CENTRAL: qual é o grande problema do universo? Uma ameaça, uma injustiça, um mistério, uma guerra?"},
    {"type":"text","content":"PERSONAGENS: quem é o protagonista? Qual é o antagonista? Quais são os aliados? REGRAS: todo universo bom tem regras consistentes — magia tem limite, tecnologia tem falhas, personagens têm fraquezas. TOM: é épico e sério? Aventura e humor? Terror? O tom define como a história vai ser sentida."},
    {"type":"text","content":"A IA é uma parceira de worldbuilding fantástica. Você dá os conceitos principais e ela expande, adiciona detalhes, sugere conexões que você não tinha pensado, e mantém consistência ao longo de conversas longas. Você é o arquiteto — a IA é a construtora."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Storytelling is the art of telling stories. With AI, anyone can build a complete narrative universe. Every universe has layers: WORLD: where does it take place? What are the physics, magic, rules? CENTRAL CONFLICT: what is the big problem of the universe? A threat, an injustice, a mystery, a war?"},
    {"type":"text","content":"CHARACTERS: who is the protagonist? Who is the antagonist? Who are the allies? RULES: every good universe has consistent rules — magic has limits, technology has flaws, characters have weaknesses. TONE: is it epic and serious? Adventure and humor? Horror? Tone defines how the story will be felt."},
    {"type":"text","content":"AI is a fantastic worldbuilding partner. You give the main concepts and it expands, adds details, suggests connections you had not thought of, and maintains consistency across long conversations. You are the architect — AI is the builder."}
  ]$$::jsonb,
  'A criança começa a construir um universo fictício com a Atena — escolhe o mundo, o conflito central e o protagonista.',
  'The child starts building a fictional universe with Atena — chooses the world, the central conflict and the protagonist.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-ia-nao-substitui-criatividade',
  'IA não substitui sua criatividade',
  'AI does not replace your creativity',
  'Entender por que a perspectiva humana é o ingrediente insubstituível',
  'Understand why human perspective is the irreplaceable ingredient',
  '6-18', 6, 5,
  $$[
    {"type":"text","content":"Depois de tudo que você aprendeu sobre IA criativa, é fundamental entender algo: a IA não é criativa do jeito que humanos são. A IA é excelente em executar ideias, combinar elementos que já existem de formas novas, expandir conceitos que você deu, e produzir variações rapidamente. Mas a IA não tem experiências pessoais."},
    {"type":"text","content":"Ela nunca sentiu saudade de alguém. Nunca ficou animada antes de uma viagem. Nunca teve medo de uma apresentação importante. E é exatamente das experiências humanas que nasce a arte mais poderosa. As histórias que tocam as pessoas são sobre experiências reais — amor, perda, coragem, crescimento."},
    {"type":"text","content":"A frase que define tudo: a IA pode desenhar. Mas a imaginação ainda é humana. Use IA como amplificador da sua criatividade, não como substituto. Sua perspectiva única, suas experiências e sua visão de mundo são o ingrediente que transforma produção em arte."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"After everything you learned about creative AI, it is fundamental to understand something: AI is not creative the way humans are. AI excels at executing ideas, combining existing elements in new ways, expanding concepts you gave it, and producing variations quickly. But AI has no personal experiences."},
    {"type":"text","content":"It has never felt homesick for someone. Never got excited before a trip. Never feared an important presentation. And it is exactly from human experiences that the most powerful art is born. Stories that touch people are about real experiences — love, loss, courage, growth."},
    {"type":"text","content":"The phrase that defines it all: AI can draw. But imagination is still human. Use AI as an amplifier of your creativity, not a substitute. Your unique perspective, your experiences and your worldview are the ingredient that transforms production into art."}
  ]$$::jsonb,
  'A criança conta uma experiência pessoal marcante e a Atena ajuda a transformá-la em uma ideia criativa. Objetivo: entender como experiência pessoal potencializa criação com IA.',
  'The child shares a memorable personal experience and Atena helps transform it into a creative idea. Goal: understand how personal experience enhances creation with AI.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's6-teste-missao-06',
  'Teste — Missão 06',
  'Test — Mission 06',
  'Quiz para fechar a Missão 06',
  'Quiz to complete Mission 06',
  '6-18', 6, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 06! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 06! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s6-criar-imagens-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual elemento do prompt visual define como a imagem deve parecer esteticamente?","options":["Sujeito","Perspectiva","Estilo artístico","Emoção"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which element of the visual prompt defines how the image should look aesthetically?',
  $$["Subject","Perspective","Artistic style","Emotion"]$$::jsonb
FROM lessons WHERE slug = 's6-criar-imagens-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que a PERSPECTIVA define num prompt de imagem?","options":["As cores predominantes da imagem","O ângulo e ponto de vista da cena — vista de cima, close, plano geral","O nível de detalhes do fundo","O tamanho final da imagem gerada"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does PERSPECTIVE define in an image prompt?',
  $$["The dominant colors of the image","The angle and point of view of the scene — top view, close-up, wide shot","The level of background detail","The final size of the generated image"]$$::jsonb
FROM lessons WHERE slug = 's6-criar-imagens-ia';

-- s6-estilos-visuais
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual estilo visual seria mais adequado para criar a capa de um livro de fantasia épica com dragões?","options":["Minimalista","Aquarela suave","Dark Fantasy","Pixel Art retrô"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which visual style would be most suitable for creating the cover of an epic fantasy book with dragons?',
  $$["Minimalist","Soft watercolor","Dark Fantasy","Retro Pixel Art"]$$::jsonb
FROM lessons WHERE slug = 's6-estilos-visuais';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que acontece quando você mistura dois estilos visuais num prompt de imagem?","options":["A IA não consegue processar e gera imagem em branco","Cria algo único que combina características dos dois estilos","A IA escolhe automaticamente um dos dois e ignora o outro","O resultado sempre fica pior do que usar um estilo só"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What happens when you mix two visual styles in an image prompt?',
  $$["AI cannot process and generates a blank image","Creates something unique that combines characteristics of both styles","AI automatically chooses one of the two and ignores the other","The result always turns out worse than using just one style"]$$::jsonb
FROM lessons WHERE slug = 's6-estilos-visuais';

-- s6-criando-personagens-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o processo criativo ideal para criar um personagem com IA?","options":["Deixar a IA inventar tudo do zero sem dar nenhuma ideia","Descrever a ideia, a IA expande, você reage e melhora em conversa colaborativa","Copiar personagens existentes e pedir para a IA mudar o nome","Criar apenas a aparência e ignorar personalidade e história"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the ideal creative process for creating a character with AI?',
  $$["Let AI invent everything from scratch without giving any ideas","Describe the idea, AI expands, you react and improve in a collaborative conversation","Copy existing characters and ask AI to change the name","Create only the appearance and ignore personality and history"]$$::jsonb
FROM lessons WHERE slug = 's6-criando-personagens-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa dizer que você é o diretor na criação com IA?","options":["Que você escreve todo o código da IA","Que você controla a direção criativa as decisões e o resultado final","Que você precisa ter formação em cinema para usar IA","Que a IA trabalha sozinha enquanto você só aprova ou reprova"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does it mean to say you are the director when creating with AI?',
  $$["That you write all the AI code","That you control the creative direction the decisions and the final result","That you need a film background to use AI","That AI works alone while you just approve or reject"]$$::jsonb
FROM lessons WHERE slug = 's6-criando-personagens-ia';

-- s6-storytelling-universos
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é worldbuilding?","options":["Um jogo de construção como Minecraft","A arte de criar e desenvolver um universo fictício com regras personagens e história consistentes","Um software para criar mapas digitais","O processo de pesquisar locais reais para usar em histórias"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is worldbuilding?',
  $$["A construction game like Minecraft","The art of creating and developing a fictional universe with consistent rules characters and history","A software to create digital maps","The process of researching real locations to use in stories"]$$::jsonb
FROM lessons WHERE slug = 's6-storytelling-universos';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que definir REGRAS é importante na criação de um universo fictício?","options":["Para tornar o universo mais difícil e desafiador","Porque universos com regras consistentes são mais críveis e satisfatórios","Porque a IA só consegue criar universos com regras pré-definidas","Para facilitar a criação de sequências e spin-offs"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is defining RULES important when creating a fictional universe?',
  $$["To make the universe harder and more challenging","Because universes with consistent rules are more believable and satisfying","Because AI can only create universes with predefined rules","To make it easier to create sequels and spin-offs"]$$::jsonb
FROM lessons WHERE slug = 's6-storytelling-universos';

-- s6-ia-nao-substitui-criatividade
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que a IA faz muito bem no processo criativo?","options":["Ter experiências emocionais que inspiram criações únicas","Executar combinar e expandir ideias rapidamente","Criar arte com significado pessoal profundo","Substituir completamente a perspectiva do criador humano"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does AI do very well in the creative process?',
  $$["Have emotional experiences that inspire unique creations","Execute combine and expand ideas quickly","Create art with deep personal meaning","Completely replace the human creator perspective"]$$::jsonb
FROM lessons WHERE slug = 's6-ia-nao-substitui-criatividade';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que experiências humanas são importantes para criar arte que toca as pessoas?","options":["Porque a IA não consegue processar emoções nos prompts","Porque experiências reais criam conexão emocional genuína que nenhuma IA pode replicar","Porque leis de direitos autorais exigem experiências pessoais","Porque a IA só entende linguagem técnica não emocional"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why are human experiences important to create art that touches people?',
  $$["Because AI cannot process emotions in prompts","Because real experiences create genuine emotional connection that no AI can replicate","Because copyright laws require personal experiences","Because AI only understands technical not emotional language"]$$::jsonb
FROM lessons WHERE slug = 's6-ia-nao-substitui-criatividade';

-- s6-teste-missao-06 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você quer criar a capa de um livro de aventura com herói em floresta mágica. Qual prompt é mais eficaz?","options":["Herói na floresta","Um guerreiro jovem numa floresta encantada ao amanhecer luz dourada entre árvores gigantes estilo pintura digital fantasia épica perspectiva cinematográfica atmosfera de aventura e esperança","Floresta com pessoa parece livro","FLORESTA MÁGICA HERÓI AVENTURA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You want to create the cover of an adventure book with hero in magical forest. Which prompt is more effective?',
  $$["Hero in the forest","A young warrior in an enchanted forest at dawn golden light between giant trees epic digital fantasy painting style cinematic perspective atmosphere of adventure and hope","Forest with person looks book","MAGICAL FOREST HERO ADVENTURE"]$$::jsonb
FROM lessons WHERE slug = 's6-teste-missao-06';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Seu amigo diz que não precisa mais de criatividade porque a IA cria tudo. O que você responderia?","options":["Você tem razão a IA já é mais criativa que humanos","A IA executa e combina muito bem mas sua perspectiva única experiências e visão de mundo são o que transforma produção em arte de verdade","Depende do tipo de arte — para algumas a IA já substituiu totalmente","A IA só é criativa com supervisão constante"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Your friend says they do not need creativity anymore because AI creates everything. What would you reply?',
  $$["You are right AI is already more creative than humans","AI executes and combines very well but your unique perspective experiences and worldview are what transforms production into real art","Depends on the type of art — for some AI has already replaced totally","AI is only creative with constant supervision"]$$::jsonb
FROM lessons WHERE slug = 's6-teste-missao-06';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s6-criar-imagens-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria prompt de imagem', 'Me ajuda a criar um prompt profissional de imagem para: [descreve o que quer]. Inclui sujeito, estilo, iluminação, perspectiva e emoção.', '6-18', 1
FROM lessons WHERE slug = 's6-criar-imagens-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Melhora meu prompt visual', 'Meu prompt de imagem é: [escreve aqui]. Me ajuda a adicionar os 5 elementos para melhorar o resultado.', '6-18', 2
FROM lessons WHERE slug = 's6-criar-imagens-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Qual estilo usar?', 'Quero criar uma imagem de [tema]. Qual estilo artístico ficaria mais impressionante? Me dá 3 opções.', '6-18', 3
FROM lessons WHERE slug = 's6-criar-imagens-ia';

-- s6-estilos-visuais
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Mesmo cenário, estilos diferentes', 'Cria descrições de prompt para a mesma cena — uma floresta com um castelo — em 3 estilos: Dark Fantasy, Pixel Art e Aquarela.', '6-18', 1
FROM lessons WHERE slug = 's6-estilos-visuais';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Qual estilo combina?', 'Estou criando [projeto]. Qual estilo visual combinaria melhor? Me dá 3 opções com explicação.', '6-18', 2
FROM lessons WHERE slug = 's6-estilos-visuais';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Mistura de estilos', 'Me sugere 3 combinações criativas de estilos visuais que dariam resultados únicos e interessantes.', '6-18', 3
FROM lessons WHERE slug = 's6-estilos-visuais';

-- s6-criando-personagens-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria meu personagem', 'Quero criar um personagem para minha história. Me ajuda a desenvolver: aparência, personalidade, história de origem e 3 habilidades especiais. Tema: [descreve]', '6-18', 1
FROM lessons WHERE slug = 's6-criando-personagens-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Nome para personagem', 'Preciso de um nome para um personagem que é [descrição]. Me dá 5 opções com significados diferentes.', '6-18', 2
FROM lessons WHERE slug = 's6-criando-personagens-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Fraqueza do personagem', 'Meu personagem tem os poderes [lista]. Me ajuda a criar fraquezas interessantes que deixem a história mais equilibrada.', '6-18', 3
FROM lessons WHERE slug = 's6-criando-personagens-ia';

-- s6-storytelling-universos
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Começa meu universo', 'Quero criar um universo de fantasia. Me ajuda a desenvolver: o mundo, as regras de magia, o conflito central e o protagonista.', '6-18', 1
FROM lessons WHERE slug = 's6-storytelling-universos';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Expande minha ideia', 'Tenho essa ideia para uma história: [descreve]. Me ajuda a expandir e adicionar mais camadas interessantes.', '6-18', 2
FROM lessons WHERE slug = 's6-storytelling-universos';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Mantém consistência', 'No meu universo [descreve regras]. Verifique se essa nova ideia [descreve] é consistente com as regras que já definimos.', '6-18', 3
FROM lessons WHERE slug = 's6-storytelling-universos';

-- s6-ia-nao-substitui-criatividade
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Transforma minha experiência', 'Tive essa experiência: [descreve]. Me ajuda a transformá-la em uma ideia para história, música ou personagem.', '6-18', 1
FROM lessons WHERE slug = 's6-ia-nao-substitui-criatividade';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA vs criatividade humana', 'Em que a criatividade humana ainda é melhor que a IA? Me dá exemplos concretos.', '6-18', 2
FROM lessons WHERE slug = 's6-ia-nao-substitui-criatividade';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Amplifica minha ideia', 'Tenho essa ideia criativa: [descreve]. Me ajuda a expandi-la sem perder minha voz e perspectiva original.', '6-18', 3
FROM lessons WHERE slug = 's6-ia-nao-substitui-criatividade';

COMMIT;
