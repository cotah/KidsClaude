-- Migration 021: Insere conteudo da Stage 4 "Missao 04 - Alucinacoes e perigos"
--
-- Foco: alucinacoes, fake news/deepfakes, privacidade/seguranca/vies,
-- dependencia e uso saudavel, e sistema de verificacao em 3 passos.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=4, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 4
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's4-o-que-sao-alucinacoes',
  'O que são alucinações?',
  'What are hallucinations?',
  'Entender o que são alucinações de IA e como identificá-las',
  'Understand what AI hallucinations are and how to identify them',
  '6-18', 4, 1,
  $$[
    {"type":"text","content":"A IA pode inventar coisas. Não de propósito — mas pode. Quando a IA gera uma informação falsa com total confiança, chamamos de alucinação. O nome é estranho mas faz sentido: é como ver algo que não existe. Por que isso acontece? Lembra que a IA não sabe coisas — ela prevê padrões? Às vezes ela não tem informação suficiente sobre algo, mas tenta preencher o espaço mesmo assim."},
    {"type":"text","content":"Exemplos reais de alucinação: pedir para a IA citar fontes de uma pesquisa — ela pode inventar títulos de livros, autores e páginas que não existem mas soam reais. Perguntar sobre alguém específico — ela pode misturar informações de pessoas diferentes. Perguntar sobre um evento recente — ela pode inventar detalhes que nunca aconteceram."},
    {"type":"text","content":"O mais perigoso: a IA não avisa quando está inventando. Ela fala com a mesma confiança quando está certa e quando está errada. Por isso verificar informações importantes é sempre essencial — a IA é um ponto de partida, não a resposta final."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI can make things up. Not on purpose — but it can. When AI generates false information with total confidence, we call it a hallucination. The name is strange but makes sense: it is like seeing something that does not exist. Why does this happen? Remember that AI does not know things — it predicts patterns? Sometimes it does not have enough information about something, but tries to fill the space anyway."},
    {"type":"text","content":"Real examples of hallucination: asking AI to cite sources for research — it can invent book titles, authors and pages that do not exist but sound real. Asking about a specific person — it can mix up information from different people. Asking about a recent event — it can invent details that never happened."},
    {"type":"text","content":"The most dangerous part: AI does not warn you when it is making things up. It speaks with the same confidence when it is right and when it is wrong. That is why verifying important information is always essential — AI is a starting point, not the final answer."}
  ]$$::jsonb,
  'A criança pede para a Atena citar 3 livros famosos sobre um tema. Depois pesquisa se existem de verdade. Objetivo: ver alucinação na prática.',
  'The child asks Atena to cite 3 famous books on a topic. Then researches if they really exist. Goal: see hallucination in practice.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-fake-news-deepfakes',
  'Fake news, deepfakes e IA',
  'Fake news, deepfakes and AI',
  'Entender como a IA pode ser usada para criar desinformação',
  'Understand how AI can be used to create disinformation',
  '6-18', 4, 2,
  $$[
    {"type":"text","content":"A IA não só pode errar por acidente — ela também pode ser usada de propósito para criar mentiras que parecem verdade. Fake news com IA são notícias falsas criadas por IA que parecem jornalismo real. Com poucos segundos, uma IA consegue criar um artigo completo e profissional sobre um evento que nunca aconteceu."},
    {"type":"text","content":"Deepfakes são vídeos, imagens ou áudios falsos criados por IA que parecem reais. Uma IA pode criar um vídeo de alguém famoso dizendo algo que nunca disse. Pode criar uma foto realista de um evento que nunca aconteceu. Pode imitar a voz de alguém para aplicar golpes."},
    {"type":"text","content":"Como se proteger? Três regras de ouro: 1) Desconfie do que é surpreendente demais — se uma notícia parece incrível ou escandalosa demais, verifique antes de acreditar. 2) Verifique a fonte — quem publicou? É um site reconhecido? 3) Busque a mesma notícia em outros lugares — se só um lugar fala sobre aquilo, desconfie."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI cannot only make mistakes by accident — it can also be used on purpose to create lies that look like truth. AI fake news are false stories created by AI that look like real journalism. In seconds, an AI can create a complete professional article about an event that never happened."},
    {"type":"text","content":"Deepfakes are fake videos, images or audio created by AI that look real. An AI can create a video of a famous person saying something they never said. Can create a realistic photo of an event that never happened. Can imitate someone voice to run scams."},
    {"type":"text","content":"How to protect yourself? Three golden rules: 1) Be suspicious of what is too surprising — if a story seems too incredible or scandalous, verify before believing. 2) Check the source — who published it? Is it a recognized site? 3) Search for the same story elsewhere — if only one place talks about it, be suspicious."}
  ]$$::jsonb,
  'A criança descreve uma notícia estranha que viu. A Atena ensina como verificar usando as 3 regras de ouro.',
  'The child describes a strange news they saw. Atena teaches how to verify using the 3 golden rules.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-privacidade-seguranca',
  'Privacidade e segurança com IA',
  'Privacy and security with AI',
  'Aprender o que nunca compartilhar com IA e entender viés',
  'Learn what to never share with AI and understand bias',
  '6-18', 4, 3,
  $$[
    {"type":"text","content":"A IA pode ser incrivelmente útil. Mas compartilhar informações erradas com ela pode ser perigoso. Regra absoluta: nunca compartilhe com uma IA informações pessoais sensíveis. Isso inclui seu endereço completo, nome completo da sua escola, senha de qualquer conta, número de documentos seus ou da família, fotos privadas e informações sobre sua rotina detalhada."},
    {"type":"text","content":"Por que isso é importante? Primeiro: algumas IAs guardam as conversas e podem usá-las para treinamento futuro. Segundo: se você usa uma IA em um site ou app desconhecido, as conversas podem ser lidas por outras pessoas. Terceiro: criminosos podem criar IAs falsas para coletar informações de crianças."},
    {"type":"text","content":"Existe também o risco de viés. A IA aprendeu com dados humanos — e humanos têm preconceitos. Isso significa que a IA pode reproduzir estereótipos sobre gênero, raça ou religião. Não porque foi programada para isso, mas porque aprendeu esses padrões dos dados. Quando você perceber que uma IA está sendo preconceituosa, isso é um erro que precisa ser corrigido, não a IA sendo honesta."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI can be incredibly useful. But sharing the wrong information with it can be dangerous. Absolute rule: never share sensitive personal information with an AI. This includes your full address, your school full name, any account password, document numbers from you or your family, private photos and detailed information about your routine."},
    {"type":"text","content":"Why does this matter? First: some AIs store conversations and may use them for future training. Second: if you use an AI on an unknown site or app, conversations can be read by others. Third: criminals can create fake AIs to collect information from children."},
    {"type":"text","content":"There is also the risk of bias. AI learned from human data — and humans have prejudices. This means AI can reproduce stereotypes about gender, race or religion. Not because it was programmed to, but because it learned those patterns from data. When you notice an AI being prejudiced, that is an error that needs to be corrected, not the AI being honest."}
  ]$$::jsonb,
  'A criança e a Atena criam juntas uma lista do que pode e não pode compartilhar com IA. Objetivo: construir hábitos de segurança digital.',
  'The child and Atena create together a list of what can and cannot be shared with AI. Goal: build digital safety habits.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-dependencia-uso-saudavel',
  'Dependência e uso saudável de IA',
  'Dependency and healthy AI use',
  'Aprender a usar IA para crescer, não para parar de pensar',
  'Learn to use AI to grow, not to stop thinking',
  '6-18', 4, 4,
  $$[
    {"type":"text","content":"A IA é uma ferramenta poderosa. Como toda ferramenta poderosa, pode ser mal usada — não só por pessoas ruins, mas por pessoas bem-intencionadas que usam da forma errada. O maior risco não é a IA maliciosa. É a dependência. Usar a IA para fazer tarefas que você deveria aprender a fazer sozinho é como usar uma calculadora para tudo sem nunca aprender matemática."},
    {"type":"text","content":"A IA deve ser usada para ampliar o que você já sabe, não para substituir o pensar. Para pesquisar mais rápido, não para não pesquisar. Para escrever melhor, não para não escrever. A frase que resume tudo: Use IA para crescer. Não para parar de pensar."},
    {"type":"text","content":"A IA também não substitui conexões humanas. Conversar com IA não é a mesma coisa que conversar com um amigo, um professor ou um familiar. IA não tem empatia real, não te conhece de verdade, não vai estar do seu lado quando você precisar de verdade. Use IA como ferramenta, não como substituto de pessoas."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"AI is a powerful tool. Like all powerful tools, it can be misused — not just by bad people, but by well-meaning people who use it the wrong way. The biggest risk is not malicious AI. It is dependency. Using AI to do tasks you should learn to do yourself is like using a calculator for everything without ever learning math."},
    {"type":"text","content":"AI should be used to amplify what you already know, not to replace thinking. To research faster, not to avoid researching. To write better, not to avoid writing. The phrase that sums it all up: Use AI to grow. Not to stop thinking."},
    {"type":"text","content":"AI also does not replace human connections. Talking to AI is not the same as talking to a friend, a teacher or a family member. AI has no real empathy, does not truly know you, will not be by your side when you really need it. Use AI as a tool, not as a substitute for people."}
  ]$$::jsonb,
  'A criança descreve uma tarefa escolar e a Atena ajuda a planejar o que a IA pode ajudar e o que ela deve fazer sozinha para aprender de verdade.',
  'The child describes a school task and Atena helps plan what AI can help with and what they should do alone to truly learn.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-como-verificar-resposta',
  'Como verificar se uma resposta é confiável',
  'How to verify if a response is reliable',
  'Aprender o sistema de verificação em 3 passos',
  'Learn the 3-step verification system',
  '6-18', 4, 5,
  $$[
    {"type":"text","content":"Você agora sabe que a IA pode errar, inventar coisas e ser usada para criar desinformação. Então como usar IA de forma inteligente e segura? A resposta é verificação. Sempre que a informação for importante, verifique. Sistema de verificação em 3 passos:"},
    {"type":"text","content":"Passo 1 — Classifique a informação: é um fato estável como matemática, ciência básica ou história antiga? Pode confiar mais na IA. É um fato recente, específico ou sobre pessoas? Verifique sempre. Passo 2 — Busque uma segunda fonte: se a IA disse algo importante, pesquise em um site confiável. Enciclopédias online, sites de universidades, jornais reconhecidos. Se a mesma informação aparece em múltiplas fontes confiáveis, você pode confiar mais."},
    {"type":"text","content":"Passo 3 — Observe o tom da IA: a IA honesta diz não tenho certeza ou isso pode ter mudado quando não tem confiança. Se ela afirma algo muito específico com total certeza, desconfie um pouco mais. Lembra: a IA é um ponto de partida incrível, não a resposta final para coisas importantes."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"You now know that AI can make mistakes, make things up and be used to create disinformation. So how do you use AI intelligently and safely? The answer is verification. Whenever information is important, verify it. 3-step verification system:"},
    {"type":"text","content":"Step 1 — Classify the information: is it a stable fact like math, basic science or ancient history? You can trust AI more. Is it a recent, specific fact or about people? Always verify. Step 2 — Find a second source: if AI said something important, search on a reliable site. Online encyclopedias, university sites, recognized newspapers. If the same information appears in multiple reliable sources, you can trust it more."},
    {"type":"text","content":"Step 3 — Observe the AI tone: honest AI says I am not sure or this may have changed when it lacks confidence. If it states something very specific with total certainty, be a little more suspicious. Remember: AI is an amazing starting point, not the final answer for important things."}
  ]$$::jsonb,
  'A criança escolhe um fato que a Atena disse e pratica o sistema de verificação em 3 passos. Objetivo: desenvolver pensamento crítico sobre informações de IA.',
  'The child picks a fact Atena said and practices the 3-step verification system. Goal: develop critical thinking about AI information.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's4-teste-missao-04',
  'Teste — Missão 04',
  'Test — Mission 04',
  'Quiz para fechar a Missão 04',
  'Quiz to complete Mission 04',
  '6-18', 4, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 04! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 04! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s4-o-que-sao-alucinacoes
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é uma alucinação de IA?","options":["Quando a IA fica sobrecarregada e para de funcionar","Quando a IA gera informações falsas com confiança sem perceber que está errada","Quando a IA recusa responder uma pergunta difícil","Quando a IA demora muito para responder"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is an AI hallucination?',
  $$["When AI gets overloaded and stops working","When AI generates false information with confidence without realizing it is wrong","When AI refuses to answer a difficult question","When AI takes too long to respond"]$$::jsonb
FROM lessons WHERE slug = 's4-o-que-sao-alucinacoes';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a IA não avisa quando está inventando informações?","options":["Porque é programada para parecer sempre confiante","Porque ela não tem consciência de si mesma — ela só gera o padrão mais provável sem saber se é verdade","Porque avisar gastaria mais energia computacional","Porque os criadores da IA não quiseram adicionar esse recurso"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does AI not warn you when it is making up information?',
  $$["Because it is programmed to always seem confident","Because it has no self-awareness — it just generates the most likely pattern without knowing if it is true","Because warning would use more computational energy","Because the AI creators did not want to add this feature"]$$::jsonb
FROM lessons WHERE slug = 's4-o-que-sao-alucinacoes';

-- s4-fake-news-deepfakes
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que são deepfakes?","options":["Vídeos editados para ficarem mais bonitos","Vídeos, imagens ou áudios falsos criados por IA que parecem reais","Fotos tiradas com câmeras de alta resolução","Filtros de redes sociais que mudam a aparência"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What are deepfakes?',
  $$["Videos edited to look more beautiful","Fake videos, images or audio created by AI that look real","Photos taken with high-resolution cameras","Social media filters that change appearance"]$$::jsonb
FROM lessons WHERE slug = 's4-fake-news-deepfakes';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual das regras de ouro ajuda a identificar fake news?","options":["Compartilhar a notícia para que mais pessoas a vejam","Acreditar se o texto estiver bem escrito e profissional","Buscar a mesma notícia em outras fontes confiáveis antes de acreditar","Verificar quantas curtidas a publicação recebeu"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which golden rule helps identify fake news?',
  $$["Sharing the story so more people see it","Believing if the text is well written and professional","Searching for the same story in other reliable sources before believing","Checking how many likes the post received"]$$::jsonb
FROM lessons WHERE slug = 's4-fake-news-deepfakes';

-- s4-privacidade-seguranca
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que NUNCA deve ser compartilhado com uma IA?","options":["Sua cor preferida ou música favorita","Um projeto escolar que você está desenvolvendo","Seu endereço completo, senha ou documentos pessoais","Sua opinião sobre um filme que assistiu"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What should NEVER be shared with an AI?',
  $$["Your favorite color or favorite song","A school project you are developing","Your full address, password or personal documents","Your opinion about a movie you watched"]$$::jsonb
FROM lessons WHERE slug = 's4-privacidade-seguranca';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a IA pode reproduzir preconceitos?","options":["Porque foi programada para ser preconceituosa","Porque aprendeu com dados humanos que já tinham preconceitos","Porque preconceito gera respostas mais rápidas","Porque os criadores não se importam com esse problema"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why can AI reproduce prejudices?',
  $$["Because it was programmed to be prejudiced","Because it learned from human data that already had prejudices","Because prejudice generates faster responses","Because the creators do not care about this problem"]$$::jsonb
FROM lessons WHERE slug = 's4-privacidade-seguranca';

-- s4-dependencia-uso-saudavel
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o maior risco do uso errado de IA para estudantes?","options":["A IA dar informações muito avançadas para a idade","Usar IA para substituir o pensar criando dependência e parando o desenvolvimento do raciocínio","A IA ser muito lenta para tarefas escolares","A IA não entender o idioma português"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the biggest risk of wrong AI use for students?',
  $$["AI giving information too advanced for the age","Using AI to replace thinking creating dependency and stopping reasoning development","AI being too slow for school tasks","AI not understanding Portuguese"]$$::jsonb
FROM lessons WHERE slug = 's4-dependencia-uso-saudavel';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Como usar IA de forma saudável?","options":["Usar para que ela faça todo o trabalho economizando tempo","Evitar completamente para não criar dependência","Usar para ampliar o que você já sabe não para substituir o pensar","Usar apenas para tarefas simples e repetitivas"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'How to use AI healthily?',
  $$["Use it to do all the work saving time","Avoid completely to not create dependency","Use it to amplify what you already know not to replace thinking","Use only for simple repetitive tasks"]$$::jsonb
FROM lessons WHERE slug = 's4-dependencia-uso-saudavel';

-- s4-como-verificar-resposta
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Para qual tipo de informação você pode confiar mais na IA sem verificar?","options":["Resultados de eleições recentes","Notícias da semana passada","Fórmulas matemáticas e conceitos científicos bem estabelecidos","Informações sobre pessoas famosas vivas"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'For what type of information can you trust AI more without verifying?',
  $$["Recent election results","Last week news","Math formulas and well-established scientific concepts","Information about living famous people"]$$::jsonb
FROM lessons WHERE slug = 's4-como-verificar-resposta';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é o Passo 2 do sistema de verificação?","options":["Perguntar a mesma coisa para outra IA","Buscar a informação em um site confiável como universidades ou jornais reconhecidos","Pedir para a IA repetir a resposta com mais detalhes","Copiar e colar a resposta em um verificador automático"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is Step 2 of the verification system?',
  $$["Asking the same thing to another AI","Searching the information in a reliable site like universities or recognized newspapers","Asking AI to repeat the response with more details","Copying and pasting the response into an automatic checker"]$$::jsonb
FROM lessons WHERE slug = 's4-como-verificar-resposta';

-- s4-teste-missao-04 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você usou IA para pesquisar sobre um cientista famoso e ela deu informações detalhadas. O que fazer antes de usar numa redação?","options":["Usar direto porque a IA sabe tudo sobre ciência","Verificar as informações em outras fontes confiáveis porque a IA pode ter alucinado detalhes","Perguntar a mesma coisa mais duas vezes para confirmar","Usar apenas as partes que soaram mais confiantes"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'You used AI to research a famous scientist and it gave detailed information. What to do before using it in an essay?',
  $$["Use directly because AI knows everything about science","Verify the information in other reliable sources because AI may have hallucinated details","Ask the same thing two more times to confirm","Use only the parts that sounded more confident"]$$::jsonb
FROM lessons WHERE slug = 's4-teste-missao-04';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você viu um vídeo de um jogador famoso anunciando aposentadoria. Parece muito real. O que você faz?","options":["Acredita e compartilha para os amigos verem","Acredita porque o vídeo parece profissional","Verifica em sites de notícias esportivas confiáveis antes de acreditar — pode ser um deepfake","Pergunta para a IA se o vídeo é verdadeiro"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'You saw a video of a famous athlete announcing retirement. It looks very real. What do you do?',
  $$["Believe and share with friends so they can see","Believe because the video looks professional","Verify on reliable sports news sites before believing — could be a deepfake","Ask AI if the video is real"]$$::jsonb
FROM lessons WHERE slug = 's4-teste-missao-04';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.
--    Teste (s4-teste-missao-04) nao tem templates - e' quiz puro.

-- s4-o-que-sao-alucinacoes
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa alucinação', 'Cita 3 livros famosos sobre dinossauros com título, autor e ano. Vou verificar se existem.', '6-18', 1
FROM lessons WHERE slug = 's4-o-que-sao-alucinacoes';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Por que você alucina?', 'Me explica por que às vezes você inventa informações sem perceber', '6-18', 2
FROM lessons WHERE slug = 's4-o-que-sao-alucinacoes';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como verificar?', 'Me ensina como verificar se uma informação que você me deu é verdadeira', '6-18', 3
FROM lessons WHERE slug = 's4-o-que-sao-alucinacoes';

-- s4-fake-news-deepfakes
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que é deepfake?', 'Me explica o que é deepfake com um exemplo prático de como alguém poderia usar isso para o mal', '6-18', 1
FROM lessons WHERE slug = 's4-fake-news-deepfakes';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como identificar fake news?', 'Me ensina passo a passo como identificar se uma notícia é falsa ou verdadeira', '6-18', 2
FROM lessons WHERE slug = 's4-fake-news-deepfakes';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa fake news', 'Me dá uma notícia real e uma falsa sobre tecnologia. Vou tentar descobrir qual é qual.', '6-18', 3
FROM lessons WHERE slug = 's4-fake-news-deepfakes';

-- s4-privacidade-seguranca
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'O que posso compartilhar?', 'Me ajuda a criar uma lista do que é seguro e do que não é seguro compartilhar com uma IA', '6-18', 1
FROM lessons WHERE slug = 's4-privacidade-seguranca';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Viés na IA', 'Me dá um exemplo de como o viés nos dados de treinamento pode fazer uma IA reproduzir preconceitos', '6-18', 2
FROM lessons WHERE slug = 's4-privacidade-seguranca';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA segura', 'Quais cuidados devo ter ao usar IA em sites ou apps que não conheço?', '6-18', 3
FROM lessons WHERE slug = 's4-privacidade-seguranca';

-- s4-dependencia-uso-saudavel
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA me ajuda a aprender', 'Tenho que aprender sobre [tema]. Me ajuda a entender o assunto sem fazer o trabalho por mim', '6-18', 1
FROM lessons WHERE slug = 's4-dependencia-uso-saudavel';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Uso saudável', 'Me dá exemplos de como usar IA de forma saudável para estudar sem criar dependência', '6-18', 2
FROM lessons WHERE slug = 's4-dependencia-uso-saudavel';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA vs humanos', 'Em quais situações é melhor falar com uma pessoa do que com uma IA?', '6-18', 3
FROM lessons WHERE slug = 's4-dependencia-uso-saudavel';

-- s4-como-verificar-resposta
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Verifica esse fato', 'Me conta um fato interessante sobre [tema]. Depois me ajuda a verificar se é verdade.', '6-18', 1
FROM lessons WHERE slug = 's4-como-verificar-resposta';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Sistema de verificação', 'Me ensina passo a passo como verificar se uma informação da IA é confiável', '6-18', 2
FROM lessons WHERE slug = 's4-como-verificar-resposta';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quando confiar na IA?', 'Me dá exemplos de situações onde posso confiar na IA e situações onde devo sempre verificar', '6-18', 3
FROM lessons WHERE slug = 's4-como-verificar-resposta';

COMMIT;
