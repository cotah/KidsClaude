-- Migration 022: Insere conteudo da Stage 5 "Missao 05 - Tipos de IA"
--
-- Foco: tipos de IA - texto (Claude/ChatGPT/Gemini), imagem (Midjourney/
-- DALL-E/Firefly), video/musica (Runway/Suno), programacao/automacao
-- (Copilot/Cursor/Zapier), e como escolher a IA certa pra cada tarefa.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=5, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 5
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's5-ia-de-texto',
  'IA de texto — os assistentes inteligentes',
  'Text AI — the intelligent assistants',
  'Conhecer os principais assistentes de IA de texto e seus pontos fortes',
  'Meet the main text AI assistants and their strengths',
  '6-18', 5, 1,
  $$[
    {"type":"text","content":"Existem vários tipos de IA, cada uma especializada em algo diferente. A IA de texto é aquela que lê e escreve. Você manda uma mensagem, ela responde. Você pede um texto, ela cria. Você faz uma pergunta, ela explica. É o tipo mais versátil e o mais usado no mundo hoje. Os três grandes: Claude da Anthropic, ChatGPT da OpenAI e Gemini do Google."},
    {"type":"text","content":"Claude é excelente para textos longos, raciocínio profundo, análise de documentos, código e explicações detalhadas. É considerado um dos mais cuidadosos e seguros. ChatGPT é o mais famoso e versátil — forte em criatividade, conversação e tem acesso a plugins e ferramentas extras, incluindo geração de imagens com o DALL-E integrado."},
    {"type":"text","content":"Gemini do Google tem forte integração com o ecossistema Google — Gmail, Docs, Drive. Tem acesso à internet em tempo real e é excelente para pesquisas atualizadas. Cada um tem pontos fortes. A escolha certa depende da tarefa. Um profissional de verdade não escolhe favorito — escolhe o certo para cada trabalho."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There are several types of AI, each specialized in something different. Text AI is the one that reads and writes. You send a message, it responds. You ask for a text, it creates. You ask a question, it explains. It is the most versatile type and the most used in the world today. The big three: Claude from Anthropic, ChatGPT from OpenAI and Gemini from Google."},
    {"type":"text","content":"Claude excels at long texts, deep reasoning, document analysis, code and detailed explanations. It is considered one of the most careful and safe. ChatGPT is the most famous and versatile — strong in creativity, conversation and has access to plugins and extra tools, including image generation with integrated DALL-E."},
    {"type":"text","content":"Google Gemini has strong integration with the Google ecosystem — Gmail, Docs, Drive. It has real-time internet access and is excellent for up-to-date research. Each has strengths. The right choice depends on the task. A real professional does not pick a favorite — they pick the right one for each job."}
  ]$$::jsonb,
  'A criança descreve uma tarefa e a Atena sugere qual IA seria melhor para aquele caso, explicando o raciocínio.',
  'The child describes a task and Atena suggests which AI would be best for that case, explaining the reasoning.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's5-ia-de-imagem',
  'IA de imagem — texto que vira arte',
  'Image AI — text that becomes art',
  'Descobrir como IAs criam imagens e quais são as principais',
  'Discover how AIs create images and which are the main ones',
  '6-18', 5, 2,
  $$[
    {"type":"text","content":"Você escreve uma descrição e a IA cria uma imagem. Isso parecia impossível há poucos anos. Hoje qualquer pessoa pode criar imagens profissionais sem saber desenhar. Como funciona? A IA de imagem foi treinada com milhões de imagens e suas descrições. Ela aprendeu a associar palavras a elementos visuais."},
    {"type":"text","content":"Os principais: Midjourney é considerado o mais artístico e bonito — cria imagens com qualidade profissional impressionante, muito usado por designers. DALL-E da OpenAI é integrado ao ChatGPT, fácil de usar e bom para imagens realistas. Adobe Firefly é focado em uso comercial seguro, treinado com imagens licenciadas."},
    {"type":"text","content":"O segredo para boas imagens é o mesmo dos bons prompts de texto: quanto mais detalhada for a descrição, melhor o resultado. Estilo artístico, cores, iluminação, perspectiva, emoção — tudo isso pode ser especificado. Um bom prompt de imagem pode ter 3 ou 4 linhas de descrição detalhada."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"You write a description and AI creates an image. That seemed impossible a few years ago. Today anyone can create professional images without knowing how to draw. How does it work? Image AI was trained with millions of images and their descriptions. It learned to associate words with visual elements."},
    {"type":"text","content":"The main ones: Midjourney is considered the most artistic and beautiful — creates impressive professional quality images, widely used by designers. OpenAI DALL-E is integrated into ChatGPT, easy to use and good for realistic images. Adobe Firefly focuses on safe commercial use, trained with licensed images."},
    {"type":"text","content":"The secret to good images is the same as good text prompts: the more detailed the description, the better the result. Artistic style, colors, lighting, perspective, emotion — all of this can be specified. A good image prompt can be 3 or 4 lines of detailed description."}
  ]$$::jsonb,
  'A criança cria uma descrição detalhada de uma imagem que gostaria de ver. A Atena avalia o prompt visual e sugere melhorias.',
  'The child creates a detailed description of an image they would like to see. Atena evaluates the visual prompt and suggests improvements.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's5-ia-video-musica',
  'IA de vídeo e música — criação multimídia',
  'Video and music AI — multimedia creation',
  'Descobrir como IA cria vídeos e músicas a partir de descrições',
  'Discover how AI creates videos and music from descriptions',
  '6-18', 5, 3,
  $$[
    {"type":"text","content":"Se IA de imagem já parecia incrível, IA de vídeo e música vão além. Você descreve uma cena e ela cria um vídeo. Você descreve uma emoção e ela cria uma música. IA de Vídeo: Runway é uma das mais avançadas para geração de vídeo, consegue criar cenas curtas realistas. Pika é especializada em animações. Sora da OpenAI cria vídeos de alta qualidade com física realista."},
    {"type":"text","content":"IA de Música: Suno permite que você descreva o estilo, a emoção e o tema, e ela cria uma música completa com voz, instrumentos e letra em minutos. Udio é similar ao Suno com foco em alta qualidade musical e mais controle sobre estilo e instrumentos."},
    {"type":"text","content":"Importante: mesmo com toda essa tecnologia, a criatividade humana continua sendo o ingrediente principal. A IA executa — mas a ideia, a emoção e o propósito ainda precisam vir de você. Tecnologia sem intenção humana não cria arte — cria apenas produto."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"If image AI already seemed incredible, video and music AI go further. You describe a scene and it creates a video. You describe an emotion and it creates music. Video AI: Runway is one of the most advanced for video generation, can create realistic short scenes. Pika specializes in animations. OpenAI Sora creates high-quality videos with realistic physics."},
    {"type":"text","content":"Music AI: Suno lets you describe the style, emotion and theme, and it creates a complete song with voice, instruments and lyrics in minutes. Udio is similar to Suno focusing on high musical quality with more control over style and instruments."},
    {"type":"text","content":"Important: even with all this technology, human creativity remains the main ingredient. AI executes — but the idea, emotion and purpose still need to come from you. Technology without human intention does not create art — it only creates product."}
  ]$$::jsonb,
  'A criança descreve o trailer de um filme imaginário. A Atena ajuda a montar o prompt de vídeo e a trilha sonora ideal.',
  'The child describes the trailer of an imaginary movie. Atena helps build the video prompt and ideal soundtrack.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's5-ia-programacao-automacao',
  'IA de programação e automação',
  'Programming and automation AI',
  'Descobrir como IA escreve código e automatiza tarefas',
  'Discover how AI writes code and automates tasks',
  '6-18', 5, 4,
  $$[
    {"type":"text","content":"IA também pode escrever código e automatizar tarefas. Isso está mudando completamente como pessoas criam tecnologia. IA de Programação: GitHub Copilot é o assistente de programação mais usado no mundo — integrado nos editores de código, sugere linhas e funções enquanto o programador digita. Cursor é um editor completo com IA, você descreve o que quer e ele escreve o código."},
    {"type":"text","content":"Lovable é focado em criar aplicativos web completos sem precisar saber programar — você descreve o app que quer e ele constrói. IA de Automação: Zapier e Make conectam aplicativos e criam fluxos automáticos sem programação. Quando receber um e-mail com anexo PDF, salva no Google Drive e me avisa no WhatsApp — isso é automação."},
    {"type":"text","content":"O mais importante: você não precisa ser programador para usar essas ferramentas. Mas entender a lógica — o que você quer que aconteça e em que ordem — continua sendo uma habilidade humana essencial. IA escreve o código, mas você precisa saber o que pedir."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI can also write code and automate tasks. This is completely changing how people create technology. Programming AI: GitHub Copilot is the most used programming assistant in the world — integrated in code editors, suggests lines and functions while the programmer types. Cursor is a complete editor with AI, you describe what you want and it writes the code."},
    {"type":"text","content":"Lovable focuses on creating complete web apps without needing to know how to program — you describe the app you want and it builds it. Automation AI: Zapier and Make connect apps and create automatic flows without programming. When I receive an email with a PDF attachment, save it to Google Drive and notify me on WhatsApp — that is automation."},
    {"type":"text","content":"The most important thing: you do not need to be a programmer to use these tools. But understanding the logic — what you want to happen and in what order — remains an essential human skill. AI writes the code, but you need to know what to ask for."}
  ]$$::jsonb,
  'A criança descreve uma tarefa repetitiva e a Atena explica como uma automação poderia fazer isso automaticamente.',
  'The child describes a repetitive task and Atena explains how automation could do it automatically.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's5-como-escolher-ia-certa',
  'Como escolher a IA certa para cada tarefa',
  'How to choose the right AI for each task',
  'Aprender a estratégia de escolha de IA para cada situação',
  'Learn the AI selection strategy for each situation',
  '6-18', 5, 5,
  $$[
    {"type":"text","content":"Você agora conhece vários tipos de IA. Mas como escolher a certa? Essa é a habilidade que separa usuários iniciantes de usuários avançados. A regra fundamental: a ferramenta certa para cada trabalho. Um carpinteiro não usa martelo para parafusar. Com IA é igual — cada ferramenta tem seu propósito."},
    {"type":"text","content":"Guia rápido de decisão: Precisa escrever, analisar, raciocinar ou programar? Use IA de texto como Claude, ChatGPT ou Gemini. Precisa criar uma imagem ou arte? Use IA de imagem como Midjourney ou DALL-E. Precisa criar vídeo? Runway ou Pika. Precisa criar música? Suno ou Udio. Precisa automatizar tarefas? Zapier ou Make. Precisa de ajuda para programar? Copilot ou Cursor."},
    {"type":"text","content":"E a dica mais importante: teste duas ou três opções antes de decidir. IAs diferentes dão resultados diferentes para a mesma tarefa. Comparar resultados é uma habilidade real de quem usa IA profissionalmente. Não existe resposta certa única — existe a melhor resposta para o seu contexto específico."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"You now know several types of AI. But how do you choose the right one? This is the skill that separates beginner users from advanced users. The fundamental rule: the right tool for each job. A carpenter does not use a hammer to screw. With AI it is the same — each tool has its purpose."},
    {"type":"text","content":"Quick decision guide: Need to write, analyze, reason or program? Use text AI like Claude, ChatGPT or Gemini. Need to create an image or art? Use image AI like Midjourney or DALL-E. Need to create video? Runway or Pika. Need to create music? Suno or Udio. Need to automate tasks? Zapier or Make. Need help programming? Copilot or Cursor."},
    {"type":"text","content":"And the most important tip: test two or three options before deciding. Different AIs give different results for the same task. Comparing results is a real skill of those who use AI professionally. There is no single right answer — there is the best answer for your specific context."}
  ]$$::jsonb,
  'A criança recebe 3 desafios diferentes e decide qual tipo de IA usaria para cada um. A Atena avalia as escolhas e explica o raciocínio profissional.',
  'The child receives 3 different challenges and decides which type of AI they would use for each. Atena evaluates the choices and explains the professional reasoning.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's5-teste-missao-05',
  'Teste — Missão 05',
  'Test — Mission 05',
  'Quiz para fechar a Missão 05',
  'Quiz to complete Mission 05',
  '6-18', 5, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 05! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 05! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s5-ia-de-texto
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual IA de texto é conhecida por sua forte integração com Gmail, Docs e Drive?","options":["Claude","ChatGPT","Gemini","Todas têm a mesma integração com Google"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which text AI is known for its strong integration with Gmail, Docs and Drive?',
  $$["Claude","ChatGPT","Gemini","They all have the same Google integration"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-de-texto';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Para qual tipo de tarefa o Claude é especialmente recomendado?","options":["Gerar imagens e ilustrações","Textos longos, raciocínio profundo e análise detalhada","Editar vídeos automaticamente","Criar músicas e trilhas sonoras"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'For which type of task is Claude especially recommended?',
  $$["Generating images and illustrations","Long texts, deep reasoning and detailed analysis","Editing videos automatically","Creating music and soundtracks"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-de-texto';

-- s5-ia-de-imagem
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Como uma IA de imagem cria imagens a partir de texto?","options":["Ela pesquisa imagens na internet e copia a mais parecida","Ela foi treinada com milhões de imagens e aprendeu a associar palavras a elementos visuais","Ela usa uma câmera especial para fotografar objetos reais","Ela combina partes de fotos já existentes sem criar nada novo"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'How does an image AI create images from text?',
  $$["It searches images on the internet and copies the most similar one","It was trained with millions of images and learned to associate words with visual elements","It uses a special camera to photograph real objects","It combines parts of existing photos without creating anything new"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-de-imagem';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual IA de imagem é especialmente conhecida pela qualidade artística profissional?","options":["DALL-E","Adobe Firefly","Midjourney","Gemini"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which image AI is especially known for professional artistic quality?',
  $$["DALL-E","Adobe Firefly","Midjourney","Gemini"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-de-imagem';

-- s5-ia-video-musica
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que uma IA de música como o Suno consegue criar?","options":["Apenas a melodia sem letra nem instrumentos","Apenas a letra da música sem som","Uma música completa com voz instrumentos e letra a partir de uma descrição","Apenas remixes de músicas já existentes"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What can a music AI like Suno create?',
  $$["Only the melody without lyrics or instruments","Only the lyrics without sound","A complete song with voice instruments and lyrics from a description","Only remixes of existing songs"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-video-musica';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a criatividade humana ainda é essencial mesmo com IA de vídeo e música?","options":["Porque a IA não consegue criar conteúdo de qualidade suficiente","Porque a IA executa mas a ideia emoção e propósito precisam vir do humano","Porque usar IA para criar é ilegal em muitos países","Porque a IA só funciona com supervisão humana constante"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is human creativity still essential even with video and music AI?',
  $$["Because AI cannot create content of sufficient quality","Because AI executes but the idea emotion and purpose need to come from humans","Because using AI to create is illegal in many countries","Because AI only works with constant human supervision"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-video-musica';

-- s5-ia-programacao-automacao
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que o GitHub Copilot faz?","options":["Gerencia projetos de equipe no GitHub","Sugere código enquanto o programador digita funcionando como assistente de programação","Cria repositórios de código automaticamente","Testa aplicativos antes de lançar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does GitHub Copilot do?',
  $$["Manages team projects on GitHub","Suggests code while the programmer types working as a programming assistant","Creates code repositories automatically","Tests apps before release"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-programacao-automacao';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que ferramentas de automação como Zapier fazem?","options":["Programam aplicativos do zero automaticamente","Conectam aplicativos e criam fluxos automáticos sem precisar programar","Substituem completamente os programadores","Apenas organizam arquivos no computador"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What do automation tools like Zapier do?',
  $$["Program apps from scratch automatically","Connect apps and create automatic flows without needing to program","Completely replace programmers","Only organize files on the computer"]$$::jsonb
FROM lessons WHERE slug = 's5-ia-programacao-automacao';

-- s5-como-escolher-ia-certa
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você precisa criar o logo de uma empresa fictícia para um projeto escolar. Qual tipo de IA usar?","options":["IA de texto como Claude ou ChatGPT","IA de imagem como Midjourney ou DALL-E","IA de automação como Zapier","IA de programação como GitHub Copilot"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You need to create a logo for a fictional company for a school project. Which type of AI to use?',
  $$["Text AI like Claude or ChatGPT","Image AI like Midjourney or DALL-E","Automation AI like Zapier","Programming AI like GitHub Copilot"]$$::jsonb
FROM lessons WHERE slug = 's5-como-escolher-ia-certa';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que é recomendado testar mais de uma IA para a mesma tarefa?","options":["Para gastar mais tempo e aprender mais sobre cada uma","Porque IAs diferentes dão resultados diferentes e comparar é uma habilidade profissional","Porque nenhuma IA funciona perfeitamente sozinha","Por exigência legal ao usar ferramentas de IA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is it recommended to test more than one AI for the same task?',
  $$["To spend more time and learn more about each one","Because different AIs give different results and comparing is a professional skill","Because no AI works perfectly alone","Due to legal requirement when using AI tools"]$$::jsonb
FROM lessons WHERE slug = 's5-como-escolher-ia-certa';

-- s5-teste-missao-05 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Seu amigo quer criar um personagem para uma história em quadrinhos mas não sabe desenhar. Qual ferramenta você recomendaria?","options":["Claude ou ChatGPT para descrever o personagem em texto","Midjourney ou DALL-E para criar a imagem do personagem","Suno para criar a música tema do personagem","GitHub Copilot para programar o personagem"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Your friend wants to create a character for a comic but does not know how to draw. Which tool would you recommend?',
  $$["Claude or ChatGPT to describe the character in text","Midjourney or DALL-E to create the character image","Suno to create the character theme music","GitHub Copilot to program the character"]$$::jsonb
FROM lessons WHERE slug = 's5-teste-missao-05';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você tem que pesquisar um tema complexo para uma apresentação e quer a análise mais profunda possível. Qual IA usar?","options":["Suno — para criar uma música sobre o tema","Runway — para criar um vídeo explicativo","Claude — para raciocínio profundo e análise detalhada","Midjourney — para criar imagens do tema"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'You have to research a complex topic for a presentation and want the deepest analysis possible. Which AI to use?',
  $$["Suno — to create a song about the topic","Runway — to create an explanatory video","Claude — for deep reasoning and detailed analysis","Midjourney — to create images of the topic"]$$::jsonb
FROM lessons WHERE slug = 's5-teste-missao-05';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.
--    Teste (s5-teste-missao-05) nao tem templates - e' quiz puro.

-- s5-ia-de-texto
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Qual IA usar?', 'Tenho que [descreve tarefa]. Qual IA de texto seria melhor: Claude, ChatGPT ou Gemini? Por quê?', '6-18', 1
FROM lessons WHERE slug = 's5-ia-de-texto';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Diferenças na prática', 'Me explica a diferença prática entre Claude, ChatGPT e Gemini com um exemplo do dia a dia', '6-18', 2
FROM lessons WHERE slug = 's5-ia-de-texto';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Mesma pergunta, IAs diferentes', 'Se eu fizesse a mesma pergunta para Claude, ChatGPT e Gemini, as respostas seriam diferentes? Por quê?', '6-18', 3
FROM lessons WHERE slug = 's5-ia-de-texto';

-- s5-ia-de-imagem
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria prompt de imagem', 'Me ajuda a criar um prompt detalhado para gerar uma imagem de [descreve o que quer]. Inclui estilo, cores e detalhes.', '6-18', 1
FROM lessons WHERE slug = 's5-ia-de-imagem';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Diferenças entre IAs de imagem', 'Qual é a diferença entre Midjourney, DALL-E e Adobe Firefly? Quando usar cada um?', '6-18', 2
FROM lessons WHERE slug = 's5-ia-de-imagem';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Melhora meu prompt visual', 'Meu prompt de imagem é: [escreve aqui]. Me ajuda a melhorá-lo para um resultado mais impressionante.', '6-18', 3
FROM lessons WHERE slug = 's5-ia-de-imagem';

-- s5-ia-video-musica
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria prompt de vídeo', 'Me ajuda a criar um prompt para um vídeo curto de [descreve a cena]. Inclui ambiente, personagens e emoção.', '6-18', 1
FROM lessons WHERE slug = 's5-ia-video-musica';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria prompt de música', 'Quero criar uma música sobre [tema]. Me ajuda a criar um prompt para o Suno com estilo, emoção e instrumentos.', '6-18', 2
FROM lessons WHERE slug = 's5-ia-video-musica';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA criativa na prática', 'Me dá exemplos de projetos criativos reais que pessoas fizeram usando IA de vídeo ou música', '6-18', 3
FROM lessons WHERE slug = 's5-ia-video-musica';

-- s5-ia-programacao-automacao
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Automatiza minha tarefa', 'Tenho essa tarefa repetitiva: [descreve]. Como uma automação poderia fazer isso por mim?', '6-18', 1
FROM lessons WHERE slug = 's5-ia-programacao-automacao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA e programação', 'Como a IA está mudando a programação? Ainda vale aprender a programar?', '6-18', 2
FROM lessons WHERE slug = 's5-ia-programacao-automacao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cria um app sem código', 'Quero criar um app simples que [função]. Como eu poderia fazer isso com IA sem saber programar?', '6-18', 3
FROM lessons WHERE slug = 's5-ia-programacao-automacao';

-- s5-como-escolher-ia-certa
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Qual ferramenta usar?', 'Quero [descreve projeto]. Qual tipo de IA seria melhor? Me explica por quê.', '6-18', 1
FROM lessons WHERE slug = 's5-como-escolher-ia-certa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Compara resultados', 'Me dá 3 exemplos de situações onde testar múltiplas IAs faria diferença no resultado final', '6-18', 2
FROM lessons WHERE slug = 's5-como-escolher-ia-certa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meu kit de IAs', 'Se eu pudesse usar apenas 3 tipos de IA para projetos escolares, quais você recomendaria e por quê?', '6-18', 3
FROM lessons WHERE slug = 's5-como-escolher-ia-certa';

COMMIT;
