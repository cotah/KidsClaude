-- Migration 019: Insere conteudo da Stage 2 "Missao 02 - Como a IA funciona?"
--
-- 5 licoes de conteudo + 1 teste de stage (mesma estrutura da Missao 01).
-- Todas: stage=2, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes - colunas chat_objective + constraint stage 1..17 ja'
-- foram criadas em 018. Sem ALTER, so' INSERTs.
--
-- Tudo numa transacao (BEGIN/COMMIT). Gate em run_migrations.sh checa
-- (slug 's2-ia-aprende-como-crianca' existe) AND (count(lessons) = 13).

BEGIN;

-- 1) Insere as 6 licoes da Stage 2
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's2-ia-aprende-como-crianca',
  'IA aprende como uma criança',
  'AI learns like a child',
  'Entender Machine Learning e como a IA aprende por exemplos',
  'Understand Machine Learning and how AI learns from examples',
  '6-18', 2, 1,
  $$[
    {"type":"text","content":"Você já aprendeu a andar de bicicleta? No começo você caía. Depois foi melhorando. Depois ficou fácil. Ninguém te programou com todas as regras do equilíbrio — você aprendeu pela experiência. A IA aprende de um jeito parecido, só que muito mais rápido e com muito mais exemplos."},
    {"type":"text","content":"Em vez de cair de bicicleta algumas vezes, ela viu milhões de exemplos de texto, imagens e situações. A cada exemplo, ela foi ajustando como entende o mundo. Isso se chama Machine Learning — aprendizado de máquina. A IA não é programada com todas as respostas. Ela é treinada para reconhecer padrões."},
    {"type":"text","content":"É a diferença entre ensinar alguém todas as regras do xadrez versus fazer ela jogar milhões de partidas até entender sozinha. O resultado é uma IA que consegue responder perguntas que nunca foram programadas nela — porque ela aprendeu a pensar por padrões, não por regras fixas."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Have you ever learned to ride a bike? At first you fell. Then you got better. Then it became easy. Nobody programmed you with all the rules of balance — you learned through experience. AI learns in a similar way, just much faster and with many more examples."},
    {"type":"text","content":"Instead of falling off a bike a few times, it saw millions of examples of text, images and situations. With each example, it adjusted how it understands the world. This is called Machine Learning. AI is not programmed with all the answers. It is trained to recognize patterns."},
    {"type":"text","content":"It is the difference between teaching someone all the rules of chess versus having them play millions of games until they understand on their own. The result is an AI that can answer questions it was never programmed for — because it learned to think in patterns, not fixed rules."}
  ]$$::jsonb,
  'A criança compara como aprendeu algo difícil com como a IA aprende. A Atena explica as semelhanças e diferenças.',
  'The child compares how they learned something difficult with how AI learns. Atena explains the similarities and differences.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-o-que-sao-dados',
  'O que são dados?',
  'What is data?',
  'Descobrir o que são dados e por que a qualidade importa',
  'Discover what data is and why quality matters',
  '6-18', 2, 2,
  $$[
    {"type":"text","content":"Para a IA aprender, ela precisa de dados. Mas o que são dados? Dados são informações. Qualquer informação. Texto de livros, artigos e sites. Imagens de fotos e pinturas. Áudios de músicas e conversas. Vídeos. Números. Tabelas. Tudo isso são dados."},
    {"type":"text","content":"Pensa no seu cérebro: tudo que você sabe veio de alguma experiência. Você leu, viu, ouviu, sentiu. Essas experiências são os dados do seu aprendizado. A IA é igual — ela aprende com os dados que recebe. Mais dados geralmente significa uma IA mais inteligente — mas só se os dados forem de qualidade."},
    {"type":"text","content":"Uma IA treinada com informações erradas ou preconceituosas vai aprender coisas erradas e preconceituosas. É o princípio do entra lixo, sai lixo — se os dados de entrada são ruins, as respostas de saída também serão. Os modelos mais poderosos foram treinados com praticamente todo o texto disponível na internet."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"For AI to learn, it needs data. But what is data? Data is information. Any information. Text from books, articles and websites. Images from photos and paintings. Audio from music and conversations. Videos. Numbers. Tables. All of this is data."},
    {"type":"text","content":"Think about your brain: everything you know came from some experience. You read, saw, heard, felt. Those experiences are the data of your learning. AI is the same — it learns from the data it receives. More data generally means a smarter AI — but only if the data is quality."},
    {"type":"text","content":"An AI trained with wrong or biased information will learn wrong and biased things. It is the garbage in, garbage out principle — if the input data is bad, the output answers will be too. The most powerful models were trained on practically all text available on the internet."}
  ]$$::jsonb,
  'A criança pensa em exemplos de dados ruins que poderiam fazer uma IA aprender coisas erradas. A Atena explica o conceito de viés nos dados.',
  'The child thinks of examples of bad data that could make an AI learn wrong things. Atena explains the concept of data bias.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-como-funciona-treinamento',
  'Como funciona o treinamento?',
  'How does training work?',
  'Entender como a IA é treinada e o que são parâmetros',
  'Understand how AI is trained and what parameters are',
  '6-18', 2, 3,
  $$[
    {"type":"text","content":"Treinar uma IA é como ensinar um estudante muito dedicado — mas esse estudante nunca dorme, nunca reclama e consegue ler bilhões de páginas. O processo funciona assim: a IA recebe um exemplo e tenta fazer uma previsão. Se ela errou, o sistema ajusta os parâmetros internos dela para errar menos na próxima vez."},
    {"type":"text","content":"Isso acontece bilhões de vezes, com bilhões de exemplos. Cada ajuste é microscópico, mas a soma de todos esses ajustes cria uma IA poderosa. É como afinar um instrumento musical. Uma volta no parafuso não muda quase nada. Mas mil ajustes minúsculos na direção certa transformam um som desafinado em música perfeita."},
    {"type":"text","content":"Os modelos de IA modernos têm bilhões de parâmetros — são esses os parafusos que foram ajustados durante o treinamento. O treinamento desses modelos custa dezenas de milhões de dólares em computação. É por isso que apenas grandes empresas como Anthropic, OpenAI e Google conseguem treinar os modelos mais poderosos."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Training an AI is like teaching a very dedicated student — but this student never sleeps, never complains and can read billions of pages. The process works like this: the AI receives an example and tries to make a prediction. If it was wrong, the system adjusts its internal parameters to be less wrong next time."},
    {"type":"text","content":"This happens billions of times, with billions of examples. Each adjustment is microscopic, but the sum of all these adjustments creates a powerful AI. It is like tuning a musical instrument. One turn of the screw changes almost nothing. But a thousand tiny adjustments in the right direction transform an out-of-tune sound into perfect music."},
    {"type":"text","content":"Modern AI models have billions of parameters — these are the screws that were adjusted during training. Training these models costs tens of millions of dollars in computing. That is why only large companies like Anthropic, OpenAI and Google can train the most powerful models."}
  ]$$::jsonb,
  'A criança pede para a Atena explicar como ela mesma foi treinada. A Atena descreve o processo de forma honesta e adaptada à idade.',
  'The child asks Atena to explain how she was trained. Atena describes the process honestly adapted to the child age.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-redes-neurais',
  'Redes neurais — o cérebro digital',
  'Neural networks — the digital brain',
  'Descobrir como redes neurais funcionam e o que é Deep Learning',
  'Discover how neural networks work and what Deep Learning is',
  '6-18', 2, 4,
  $$[
    {"type":"text","content":"A IA moderna é inspirada no cérebro humano. Não é uma cópia — é uma inspiração. O cérebro tem neurônios — células que se conectam e passam informação entre si. Quando você aprende algo, novas conexões se formam. Quando você pratica, essas conexões ficam mais fortes."},
    {"type":"text","content":"Redes neurais artificiais funcionam de forma parecida. São camadas de nós matemáticos conectados entre si. A informação entra, passa pelas camadas, e sai como uma resposta. Quanto mais camadas, mais profundo é o aprendizado — por isso o termo Deep Learning."},
    {"type":"text","content":"Você não precisa entender a matemática por trás disso. O que importa saber é: a IA não funciona com regras fixas que alguém escreveu. Ela funciona com conexões que se formaram durante o treinamento — como seu cérebro funciona depois que você aprendeu algo."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Modern AI is inspired by the human brain. Not a copy — an inspiration. The brain has neurons — cells that connect and pass information to each other. When you learn something, new connections form. When you practice, those connections get stronger."},
    {"type":"text","content":"Artificial neural networks work similarly. They are layers of mathematical nodes connected to each other. Information enters, passes through the layers, and comes out as a response. The more layers, the deeper the learning — hence the term Deep Learning."},
    {"type":"text","content":"You do not need to understand the math behind this. What matters is: AI does not work with fixed rules someone wrote. It works with connections that formed during training — like your brain works after you learned something."}
  ]$$::jsonb,
  'A criança compara o cérebro humano com redes neurais. A Atena explica as semelhanças e diferenças de forma visual e divertida.',
  'The child compares the human brain with neural networks. Atena explains similarities and differences in a visual and fun way.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-ia-preve-nao-sabe',
  'IA prevê, não sabe',
  'AI predicts, it does not know',
  'Entender que a IA gera previsões, não certezas',
  'Understand that AI generates predictions, not certainties',
  '6-18', 2, 5,
  $$[
    {"type":"text","content":"Aqui está um dos conceitos mais importantes do curso inteiro — e que a maioria das pessoas não entende. A IA não sabe coisas. Ela prevê a resposta mais provável baseada em padrões que aprendeu. Quando você pergunta qual é a capital da França, a IA não consulta um banco de dados com a resposta certa."},
    {"type":"text","content":"Ela gera Paris porque em todo o texto que leu, a palavra Paris aparecia associada a capital da França com altíssima frequência. Na maioria dos casos a previsão está certa. Mas às vezes a IA prevê algo que parece certo mas está errado — especialmente em perguntas específicas, raras ou recentes onde não tinha muitos exemplos."},
    {"type":"text","content":"É por isso que a IA pode errar com tanta confiança. Ela não sabe que errou — ela apenas gerou a resposta que parecia mais provável. Isso é fundamental para usar IA com inteligência: entender que por baixo de cada resposta existe uma previsão estatística, não uma certeza absoluta."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Here is one of the most important concepts in the entire course — and one that most people do not understand. AI does not know things. It predicts the most likely response based on patterns it learned. When you ask what the capital of France is, AI does not consult a database with the right answer."},
    {"type":"text","content":"It generates Paris because in all the text it read, the word Paris appeared associated with capital of France at very high frequency. In most cases the prediction is correct. But sometimes AI predicts something that seems right but is wrong — especially in specific, rare or recent questions where it did not have many examples."},
    {"type":"text","content":"This is why AI can be wrong with such confidence. It does not know it was wrong — it just generated the response that seemed most likely. This is fundamental to using AI intelligently: understanding that behind every response is a statistical prediction, not an absolute certainty."}
  ]$$::jsonb,
  'A criança testa a Atena com perguntas específicas e raras para ver onde a previsão falha. A Atena explica em tempo real por que errou ou por que não tem certeza.',
  'The child tests Atena with specific and rare questions to see where the prediction fails. Atena explains in real time why it was wrong or uncertain.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's2-teste-missao-02',
  'Teste — Missão 02',
  'Test — Mission 02',
  'Quiz para fechar a Missão 02',
  'Quiz to complete Mission 02',
  '6-18', 2, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 02! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 02! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s2-ia-aprende-como-crianca
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é Machine Learning?","options":["Um robô que aprende a andar de bicicleta","Quando a IA é programada com todas as respostas possíveis","Quando a IA aprende reconhecendo padrões em milhões de exemplos","Um tipo de computador mais rápido"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is Machine Learning?',
  $$["A robot that learns to ride a bike","When AI is programmed with all possible answers","When AI learns by recognizing patterns in millions of examples","A type of faster computer"]$$::jsonb
FROM lessons WHERE slug = 's2-ia-aprende-como-crianca';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a diferença entre programar e treinar uma IA?","options":["Programar é mais moderno que treinar","Programar dá regras fixas; treinar faz a IA aprender padrões por exemplos","Treinar é mais simples que programar","Não há diferença, são a mesma coisa"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the difference between programming and training an AI?',
  $$["Programming is more modern than training","Programming gives fixed rules; training makes AI learn patterns from examples","Training is simpler than programming","There is no difference, they are the same thing"]$$::jsonb
FROM lessons WHERE slug = 's2-ia-aprende-como-crianca';

-- s2-o-que-sao-dados
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que são dados para a IA?","options":["Apenas números e estatísticas","Somente imagens e fotos","Qualquer informação — texto, imagem, áudio, vídeo, números","Apenas textos escritos em inglês"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is data for AI?',
  $$["Only numbers and statistics","Only images and photos","Any information — text, image, audio, video, numbers","Only texts written in English"]$$::jsonb
FROM lessons WHERE slug = 's2-o-que-sao-dados';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a qualidade dos dados importa?","options":["Dados de qualidade fazem a IA responder mais rápido","Uma IA treinada com dados ruins ou preconceituosos aprende coisas erradas","Dados de qualidade custam menos para processar","Qualidade não importa, só a quantidade"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does data quality matter?',
  $$["Quality data makes AI respond faster","AI trained with bad or biased data learns wrong things","Quality data costs less to process","Quality does not matter, only quantity"]$$::jsonb
FROM lessons WHERE slug = 's2-o-que-sao-dados';

-- s2-como-funciona-treinamento
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Como a IA melhora durante o treinamento?","options":["Um programador corrige cada erro manualmente","A IA memoriza todas as respostas certas de uma vez","O sistema ajusta parâmetros internos a cada erro, bilhões de vezes","A IA compra mais memória RAM automaticamente"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'How does AI improve during training?',
  $$["A programmer corrects each error manually","The AI memorizes all the right answers at once","The system adjusts internal parameters at each error, billions of times","The AI automatically buys more RAM"]$$::jsonb
FROM lessons WHERE slug = 's2-como-funciona-treinamento';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que são parâmetros de uma IA?","options":["As regras fixas programadas pelos engenheiros","Os valores internos ajustados durante o treinamento que definem como a IA pensa","A velocidade de processamento do computador","O tamanho do banco de dados da IA"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What are AI parameters?',
  $$["The fixed rules programmed by engineers","The internal values adjusted during training that define how the AI thinks","The processing speed of the computer","The size of the AI database"]$$::jsonb
FROM lessons WHERE slug = 's2-como-funciona-treinamento';

-- s2-redes-neurais
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Em que o cérebro humano inspirou a IA?","options":["Na forma como humanos dormem para processar informações","Na estrutura de neurônios conectados que passam informação entre si","Na capacidade humana de sentir emoções","No tamanho físico do cérebro humano"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'How did the human brain inspire AI?',
  $$["In how humans sleep to process information","In the structure of connected neurons that pass information to each other","In the human capacity to feel emotions","In the physical size of the human brain"]$$::jsonb
FROM lessons WHERE slug = 's2-redes-neurais';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa Deep Learning?","options":["IA que aprende apenas assuntos profundos e complexos","IA que usa redes neurais com muitas camadas para aprendizado mais sofisticado","IA que aprende mais devagar que o normal","IA que só funciona com internet de alta velocidade"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does Deep Learning mean?',
  $$["AI that learns only deep and complex subjects","AI that uses neural networks with many layers for more sophisticated learning","AI that learns slower than normal","AI that only works with high-speed internet"]$$::jsonb
FROM lessons WHERE slug = 's2-redes-neurais';

-- s2-ia-preve-nao-sabe
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Como a IA gera respostas?","options":["Consultando um banco de dados com todas as respostas corretas","Calculando a resposta mais provável baseada em padrões aprendidos","Conectando-se à internet para pesquisar em tempo real","Perguntando para outros computadores mais poderosos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'How does AI generate responses?',
  $$["By consulting a database with all correct answers","By calculating the most likely response based on learned patterns","By connecting to the internet to research in real time","By asking other more powerful computers"]$$::jsonb
FROM lessons WHERE slug = 's2-ia-preve-nao-sabe';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a IA pode errar com confiança?","options":["Porque ela mente de propósito às vezes","Porque ela gera a previsão mais provável sem saber se está certa ou errada","Porque os programadores a ensinaram respostas erradas","Porque a internet tem informações erradas"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why can AI be wrong with confidence?',
  $$["Because it lies on purpose sometimes","Because it generates the most likely prediction without knowing if it is right or wrong","Because programmers taught it wrong answers","Because the internet has wrong information"]$$::jsonb
FROM lessons WHERE slug = 's2-ia-preve-nao-sabe';

-- s2-teste-missao-02 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Seu amigo diz que a IA sabe tudo porque ela responde qualquer pergunta. O que você diria?","options":["Ele tem razão, a IA realmente sabe tudo","A IA não sabe — ela prevê respostas baseadas em padrões. Às vezes acerta, às vezes erra","A IA sabe tudo mas finge que não sabe às vezes","A IA só sabe coisas que estão na internet"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Your friend says AI knows everything because it answers any question. What would you say?',
  $$["He is right, AI really knows everything","AI does not know — it predicts responses based on patterns. Sometimes it is right, sometimes it is wrong","AI knows everything but sometimes pretends not to","AI only knows things that are on the internet"]$$::jsonb
FROM lessons WHERE slug = 's2-teste-missao-02';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Uma IA foi treinada com notícias de um país que tinha muito preconceito contra mulheres na política. O que provavelmente aconteceria?","options":["A IA aprenderia a ser justa automaticamente","A IA ficaria mais rápida por ter mais dados","A IA poderia reproduzir esses preconceitos nas respostas","A IA recusaria responder sobre política"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'An AI was trained with news from a country that had strong prejudice against women in politics. What would likely happen?',
  $$["The AI would learn to be fair automatically","The AI would get faster from having more data","The AI could reproduce those prejudices in responses","The AI would refuse to answer about politics"]$$::jsonb
FROM lessons WHERE slug = 's2-teste-missao-02';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.
--    Teste (s2-teste-missao-02) nao tem templates - e' quiz puro.
--    Templates em PT (schema sem label_en/template_en).

-- s2-ia-aprende-como-crianca
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como você aprendeu?', 'Como você aprendeu as coisas que sabe? Me explica seu treinamento', '6-18', 1
FROM lessons WHERE slug = 's2-ia-aprende-como-crianca';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'ML na prática', 'Me dá um exemplo do dia a dia que funciona igual ao Machine Learning', '6-18', 2
FROM lessons WHERE slug = 's2-ia-aprende-como-crianca';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA vs humano aprendendo', 'Qual é a maior diferença entre como você aprende e como eu aprendo?', '6-18', 3
FROM lessons WHERE slug = 's2-ia-aprende-como-crianca';

-- s2-o-que-sao-dados
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Dados ruins na prática', 'Me dá um exemplo real de IA que aprendeu algo errado por causa de dados ruins', '6-18', 1
FROM lessons WHERE slug = 's2-o-que-sao-dados';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quais dados te treinaram?', 'Que tipo de dados foram usados para te treinar?', '6-18', 2
FROM lessons WHERE slug = 's2-o-que-sao-dados';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Viés na IA', 'O que é viés em IA e como isso afeta as respostas?', '6-18', 3
FROM lessons WHERE slug = 's2-o-que-sao-dados';

-- s2-como-funciona-treinamento
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como você foi treinada?', 'Me explica como você foi treinada. O que a Anthropic fez para criar você?', '6-18', 1
FROM lessons WHERE slug = 's2-como-funciona-treinamento';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quanto custa treinar IA?', 'Quanto custa treinar uma IA poderosa como você? Por que é tão caro?', '6-18', 2
FROM lessons WHERE slug = 's2-como-funciona-treinamento';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Parâmetros em palavras simples', 'Me explica o que são parâmetros de IA usando uma analogia simples', '6-18', 3
FROM lessons WHERE slug = 's2-como-funciona-treinamento';

-- s2-redes-neurais
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Cérebro vs IA', 'Qual é a maior diferença entre meu cérebro e uma rede neural artificial?', '6-18', 1
FROM lessons WHERE slug = 's2-redes-neurais';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Deep Learning simples', 'Me explica Deep Learning usando uma analogia que uma criança entende', '6-18', 2
FROM lessons WHERE slug = 's2-redes-neurais';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como você processa?', 'Como você processa uma pergunta minha até chegar na resposta?', '6-18', 3
FROM lessons WHERE slug = 's2-redes-neurais';

-- s2-ia-preve-nao-sabe
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa você', 'Vou te fazer perguntas difíceis e específicas. Me diz quando você não tem certeza da resposta', '6-18', 1
FROM lessons WHERE slug = 's2-ia-preve-nao-sabe';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Previsão vs certeza', 'Me explica a diferença entre prever uma resposta e saber uma resposta', '6-18', 2
FROM lessons WHERE slug = 's2-ia-preve-nao-sabe';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quando você erra?', 'Em que tipo de perguntas você tem mais chance de errar? Por quê?', '6-18', 3
FROM lessons WHERE slug = 's2-ia-preve-nao-sabe';

COMMIT;
