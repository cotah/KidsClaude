-- Migration 026: Insere conteudo da Stage 9 "Missao 09 - IA, robos e humanoides"
--
-- Foco: diferenca entre IA e robotica - software vs hardware, visao
-- computacional + sensores + fusao de sensores, humanoides (Atlas/Optimus/
-- Figure), robos no dia a dia (Roomba/cirurgicos/Amazon/agricultura), e
-- impacto em empregos e como se preparar.
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=9, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 9
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's9-robo-nao-e-ia',
  'Robô não é IA — entendendo a diferença',
  'Robot is not AI — understanding the difference',
  'Entender a diferença fundamental entre IA e robótica',
  'Understand the fundamental difference between AI and robotics',
  '6-18', 9, 1,
  $$[
    {"type":"text","content":"Existe uma confusão enorme que a maioria das pessoas tem: achar que robô e IA são a mesma coisa. Não são. IA é software — um programa que processa informações e aprende padrões. Pode existir em um servidor, no seu celular, num computador. Não tem corpo físico. Robô é hardware — uma máquina física com motores, sensores e estrutura mecânica."},
    {"type":"text","content":"Um robô industrial que solda carros na fábrica é um robô. Mas pode ser completamente burro — seguindo apenas instruções fixas sem aprender nada. A frase que define tudo: IA é o cérebro. Robô é o corpo. Você pode ter IA sem robô — como o ChatGPT no seu celular. Você pode ter robô sem IA — como um aspirador antigo que segue caminho fixo."},
    {"type":"text","content":"E você pode ter robô com IA — como um aspirador moderno que mapeia a casa, aprende os obstáculos e otimiza o trajeto. Quando você combina IA com robótica, você cria algo muito mais poderoso: uma máquina que age fisicamente no mundo e aprende com cada ação."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"There is a huge confusion that most people have: thinking that robot and AI are the same thing. They are not. AI is software — a program that processes information and learns patterns. It can exist on a server, on your phone, on a computer. It has no physical body. Robot is hardware — a physical machine with motors, sensors and mechanical structure."},
    {"type":"text","content":"An industrial robot that welds cars in a factory is a robot. But it can be completely dumb — following only fixed instructions without learning anything. The phrase that defines it all: AI is the brain. Robot is the body. You can have AI without a robot — like ChatGPT on your phone. You can have a robot without AI — like an old vacuum that follows a fixed path."},
    {"type":"text","content":"And you can have a robot with AI — like a modern vacuum that maps the house, learns the obstacles and optimizes its route. When you combine AI with robotics, you create something much more powerful: a machine that acts physically in the world and learns from each action."}
  ]$$::jsonb,
  'A criança dá exemplos de tecnologias do dia a dia e a Atena classifica cada uma — IA sem robô, robô sem IA, ou robô com IA.',
  'The child gives examples of everyday technologies and Atena classifies each one — AI without robot, robot without AI, or robot with AI.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's9-como-robos-enxergam',
  'Como robôs enxergam e entendem o mundo',
  'How robots see and understand the world',
  'Descobrir visão computacional, sensores e como robôs percebem o ambiente',
  'Discover computer vision, sensors and how robots perceive the environment',
  '6-18', 9, 2,
  $$[
    {"type":"text","content":"Para um robô agir no mundo físico, ele precisa primeiro entender o que está ao seu redor. Visão computacional é a capacidade da IA de entender imagens e vídeos. Câmeras capturam o que está na frente. A IA analisa os pixels e reconhece: isso é uma pessoa, isso é uma cadeira, isso é uma porta aberta. Parece simples para humanos — é extremamente complexo para máquinas."},
    {"type":"text","content":"Sensores complementam as câmeras. LiDAR cria mapas 3D usando laser. Sensores de toque detectam pressão. Giroscópios medem equilíbrio. Sensores de temperatura e microfones para som. Fusão de sensores é quando a IA combina todas essas informações para criar uma compreensão completa do ambiente."},
    {"type":"text","content":"Carros autônomos usam exatamente isso: câmeras vendo pedestres, LiDAR medindo distâncias, GPS localizando, IA processando tudo em milissegundos para decidir frear, acelerar ou virar. É como ter vários sentidos funcionando ao mesmo tempo e um cérebro que os integra instantaneamente."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"For a robot to act in the physical world, it first needs to understand what is around it. Computer vision is the ability of AI to understand images and videos. Cameras capture what is in front. AI analyzes the pixels and recognizes: this is a person, this is a chair, this is an open door. Seems simple for humans — it is extremely complex for machines."},
    {"type":"text","content":"Sensors complement cameras. LiDAR creates 3D maps using lasers. Touch sensors detect pressure. Gyroscopes measure balance. Temperature sensors and microphones for sound. Sensor fusion is when AI combines all this information to create a complete understanding of the environment."},
    {"type":"text","content":"Self-driving cars use exactly this: cameras seeing pedestrians, LiDAR measuring distances, GPS locating, AI processing everything in milliseconds to decide to brake, accelerate or turn. It is like having multiple senses working simultaneously and a brain that integrates them instantly."}
  ]$$::jsonb,
  'A criança descreve um robô imaginário para uma tarefa e a Atena explica quais sensores esse robô precisaria e por quê.',
  'The child describes an imaginary robot for a task and Atena explains which sensors that robot would need and why.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's9-humanoides',
  'Humanoides — robôs que parecem pessoas',
  'Humanoids — robots that look like people',
  'Conhecer os humanoides mais avançados e entender seus desafios',
  'Meet the most advanced humanoids and understand their challenges',
  '6-18', 9, 3,
  $$[
    {"type":"text","content":"Os humanoides são robôs projetados para parecer e se mover como humanos. Por que forma humana? Porque o mundo foi construído para humanos. Escadas, portas, ferramentas, carros — tudo foi projetado para um corpo com duas pernas e duas mãos. Um robô humanoide pode usar esse mundo sem precisar redesenhá-lo. Boston Dynamics Atlas é considerado o mais avançado em movimento — consegue correr, pular, fazer parkour e girar no ar."},
    {"type":"text","content":"Tesla Optimus foi criado com foco em trabalho em fábricas, projetado para ser produzido em massa. Figure AI, Agility Robotics e outras startups estão criando humanoides para armazéns e tarefas domésticas. A competição está avançando muito rápido — o que era impossível há 3 anos é realidade hoje."},
    {"type":"text","content":"O maior desafio não é mais o hardware — é a IA que controla o movimento. Ensinar um robô a pegar um objeto de forma diferente que nunca viu antes, num ambiente desordenado, ainda é extremamente difícil. Humanos fazem isso automaticamente desde bebês — para robôs é um problema de engenharia complexíssimo."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Humanoids are robots designed to look and move like humans. Why human form? Because the world was built for humans. Stairs, doors, tools, cars — everything was designed for a body with two legs and two hands. A humanoid robot can use that world without needing to redesign it. Boston Dynamics Atlas is considered the most advanced in physical movement — it can run, jump, do parkour and spin in the air."},
    {"type":"text","content":"Tesla Optimus was created with a focus on factory work, designed to be mass produced. Figure AI, Agility Robotics and other startups are creating humanoids for warehouses and domestic tasks. The competition is advancing very fast — what was impossible 3 years ago is reality today."},
    {"type":"text","content":"The biggest challenge is no longer the hardware — it is the AI that controls movement. Teaching a robot to pick up an object it has never seen before, in a messy environment, is still extremely difficult. Humans do this automatically since infancy — for robots it is an incredibly complex engineering problem."}
  ]$$::jsonb,
  'A criança imagina um humanoide para uma tarefa do dia a dia e a Atena ajuda a pensar nos desafios técnicos que esse robô enfrentaria.',
  'The child imagines a humanoid for an everyday task and Atena helps think through the technical challenges that robot would face.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's9-robos-dia-a-dia',
  'Robôs no dia a dia — onde eles já estão',
  'Robots in daily life — where they already are',
  'Descobrir os robôs que já existem ao nosso redor em diferentes áreas',
  'Discover the robots that already exist around us in different areas',
  '6-18', 9, 4,
  $$[
    {"type":"text","content":"Robôs não são ficção científica. Eles já estão em todo lugar ao seu redor. Na sua casa: aspiradores robô como Roomba mapeiam o ambiente e limpam sozinhos. No hospital: robôs cirúrgicos como o Da Vinci permitem cirurgias com precisão milimétrica. Robôs de logística entregam medicamentos nos andares sem intervenção humana."},
    {"type":"text","content":"Na fábrica: braços robóticos soldam, pintam e montam carros. No armazém: robôs da Amazon movem prateleiras inteiras até o trabalhador humano, que pega os produtos sem precisar caminhar quilômetros por dia. Na agricultura: drones identificam plantas doentes, robôs colhem frutas frágeis com toque preciso, máquinas autônomas plantam em fileiras perfeitas."},
    {"type":"text","content":"No oceano e espaço: submarinos robóticos exploram profundezas inacessíveis, rovers em Marte coletam amostras há anos sem intervenção humana. A tendência é clara: robôs estão assumindo tarefas repetitivas, perigosas ou que exigem precisão extrema. O que sobra para humanos são tarefas que exigem criatividade, empatia e conexão humana."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Robots are not science fiction. They are already everywhere around you. In your home: robot vacuums like Roomba map the environment and clean on their own. In hospitals: surgical robots like Da Vinci enable surgeries with millimeter precision. Logistics robots deliver medications to floors without human intervention."},
    {"type":"text","content":"In factories: robotic arms weld, paint and assemble cars. In warehouses: Amazon robots move entire shelves to the human worker, who picks products without needing to walk kilometers per day. In agriculture: drones identify sick plants, robots harvest fragile fruits with precise touch, autonomous machines plant in perfect rows."},
    {"type":"text","content":"In the ocean and space: robotic submarines explore inaccessible depths, Mars rovers collect samples for years without human intervention. The trend is clear: robots are taking over repetitive, dangerous or precision-demanding tasks. What remains for humans are tasks requiring creativity, empathy and human connection."}
  ]$$::jsonb,
  'A criança tenta identificar 5 robôs que existem na vida real ao seu redor. A Atena confirma, corrige e adiciona exemplos surpresa.',
  'The child tries to identify 5 real robots that exist around them. Atena confirms, corrects and adds surprise examples.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's9-robos-empregos-futuro',
  'Robôs, empregos e o futuro que vem aí',
  'Robots, jobs and the future ahead',
  'Entender como robôs vão transformar o trabalho e como se preparar',
  'Understand how robots will transform work and how to prepare',
  '6-18', 9, 5,
  $$[
    {"type":"text","content":"Os robôs vão roubar empregos? A resposta honesta é: sim, alguns empregos vão desaparecer. E não, outros serão criados. E a história mostra que isso sempre aconteceu. Quando a máquina de costura foi inventada, muitos costureiros perderam emprego — mas criou-se uma indústria de moda global com muito mais empregos. Quando os caixas eletrônicos chegaram, previu-se o fim dos bancários — mas o número de bancários aumentou."},
    {"type":"text","content":"O padrão histórico: tecnologia elimina tarefas repetitivas e cria demanda por novas habilidades. O que vai diminuir: motoristas de caminhão, operadores de caixa, trabalhadores de linha de montagem repetitiva. O que vai crescer: engenheiros de robótica, treinadores de IA, técnicos de manutenção de robôs, designers de experiência humana, profissionais de cuidado e saúde."},
    {"type":"text","content":"O que não vai sumir: empatia, criatividade, liderança, conexão humana e pensamento crítico. A melhor preparação não é se preocupar com quais empregos vão desaparecer. É desenvolver habilidades que robôs não conseguem replicar — e aprender a trabalhar com eles."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Will robots steal jobs? The honest answer is: yes, some jobs will disappear. And no, others will be created. And history shows this has always happened. When the sewing machine was invented, many seamstresses lost jobs — but a global fashion industry with many more jobs was created. When ATMs arrived, the end of bank tellers was predicted — but the number of bank tellers actually increased."},
    {"type":"text","content":"The historical pattern: technology eliminates repetitive tasks and creates demand for new skills. What will decrease: truck drivers, cashiers, repetitive assembly line workers. What will grow: robotics engineers, AI trainers, robot maintenance technicians, human experience designers, care and health professionals."},
    {"type":"text","content":"What will not disappear: empathy, creativity, leadership, human connection and critical thinking. The best preparation is not to worry about which jobs will disappear. It is to develop skills that robots cannot replicate — and learn to work alongside them."}
  ]$$::jsonb,
  'A criança escolhe uma profissão que sonha ter e a Atena analisa como robôs vão transformar essa profissão e como se preparar.',
  'The child picks a dream profession and Atena analyzes how robots will transform that profession and how to prepare.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's9-teste-missao-09',
  'Teste — Missão 09',
  'Test — Mission 09',
  'Quiz para fechar a Missão 09',
  'Quiz to complete Mission 09',
  '6-18', 9, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 09! Responda as 2 perguntas e avance para a próxima missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 09! Answer the 2 questions and advance to the next mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s9-robo-nao-e-ia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a principal diferença entre IA e robô?","options":["IA é mais cara que robôs","IA é software que processa informações; robô é hardware com estrutura física — podem existir separados ou combinados","Robôs são mais inteligentes que IA","IA só funciona dentro de robôs"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the main difference between AI and a robot?',
  $$["AI is more expensive than robots","AI is software that processes information; robot is hardware with physical structure — they can exist separately or combined","Robots are smarter than AI","AI only works inside robots"]$$::jsonb
FROM lessons WHERE slug = 's9-robo-nao-e-ia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que acontece quando você combina IA com robótica?","options":["O robô fica mais pesado e lento","Cria uma máquina que age fisicamente no mundo e aprende com cada ação","A IA perde parte de sua inteligência ao entrar num corpo físico","O robô precisa de mais eletricidade para funcionar"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What happens when you combine AI with robotics?',
  $$["The robot becomes heavier and slower","Creates a machine that acts physically in the world and learns from each action","AI loses part of its intelligence by entering a physical body","The robot needs more electricity to work"]$$::jsonb
FROM lessons WHERE slug = 's9-robo-nao-e-ia';

-- s9-como-robos-enxergam
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é visão computacional?","options":["Um tipo de câmera especial usada em robôs","A capacidade da IA de entender e interpretar imagens e vídeos reconhecendo objetos e situações","Um software para editar fotos automaticamente","Um sistema de vigilância por câmeras"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is computer vision?',
  $$["A special type of camera used in robots","The AI capability to understand and interpret images and videos recognizing objects and situations","A software to edit photos automatically","A surveillance system using cameras"]$$::jsonb
FROM lessons WHERE slug = 's9-como-robos-enxergam';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que carros autônomos usam múltiplos tipos de sensores em vez de apenas câmeras?","options":["Porque câmeras são muito caras para usar sozinhas","Porque cada sensor capta informações diferentes e a combinação cria uma compreensão mais completa e segura do ambiente","Porque câmeras não funcionam à noite","Porque a lei exige múltiplos sensores em veículos autônomos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why do self-driving cars use multiple types of sensors instead of just cameras?',
  $$["Because cameras are too expensive to use alone","Because each sensor captures different information and the combination creates a more complete and safer understanding of the environment","Because cameras do not work at night","Because the law requires multiple sensors in autonomous vehicles"]$$::jsonb
FROM lessons WHERE slug = 's9-como-robos-enxergam';

-- s9-humanoides
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que faz sentido criar robôs com forma humana?","options":["Porque humanos preferem interagir com máquinas que parecem pessoas","Porque o mundo foi construído para humanos e um robô humanoide pode usar esse mundo sem redesenhá-lo","Porque robôs humanoides são mais baratos de produzir","Porque a forma humana é a mais eficiente para qualquer tarefa"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why does it make sense to create robots with human form?',
  $$["Because humans prefer to interact with machines that look like people","Because the world was built for humans and a humanoid robot can use that world without redesigning it","Because humanoid robots are cheaper to produce","Because human form is the most efficient for any task"]$$::jsonb
FROM lessons WHERE slug = 's9-humanoides';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é o maior desafio atual no desenvolvimento de humanoides?","options":["O custo dos materiais para construir o corpo físico","A IA que controla o movimento — especialmente lidar com situações e objetos novos em ambientes desordenados","A bateria que não dura tempo suficiente","O tamanho — humanoides ainda são muito grandes"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the biggest current challenge in humanoid development?',
  $$["The cost of materials to build the physical body","The AI controlling movement — especially handling new situations and objects in messy environments","The battery that does not last long enough","The size — humanoids are still too big"]$$::jsonb
FROM lessons WHERE slug = 's9-humanoides';

-- s9-robos-dia-a-dia
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a tendência principal de quais tarefas os robôs estão assumindo?","options":["Tarefas criativas e artísticas","Tarefas repetitivas perigosas ou que exigem precisão extrema","Tarefas que envolvem interação humana e empatia","Tarefas simples que qualquer criança poderia fazer"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is the main trend in which tasks robots are taking over?',
  $$["Creative and artistic tasks","Repetitive dangerous tasks or those requiring extreme precision","Tasks involving human interaction and empathy","Simple tasks any child could do"]$$::jsonb
FROM lessons WHERE slug = 's9-robos-dia-a-dia';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que os robôs da Amazon fazem nos armazéns?","options":["Embalam os produtos automaticamente","Movem prateleiras inteiras até o trabalhador humano para que ele pegue os produtos","Entregam os pacotes nas casas dos clientes","Verificam a qualidade de cada produto antes do envio"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What do Amazon robots do in warehouses?',
  $$["Pack products automatically","Move entire shelves to the human worker so they can pick the products","Deliver packages to customers homes","Check the quality of each product before shipping"]$$::jsonb
FROM lessons WHERE slug = 's9-robos-dia-a-dia';

-- s9-robos-empregos-futuro
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que a história mostra sobre tecnologia e empregos?","options":["Tecnologia sempre elimina mais empregos do que cria","Tecnologia elimina tarefas repetitivas mas geralmente cria demanda por novas habilidades e tipos de trabalho","Tecnologia não afeta o mercado de trabalho de forma significativa","Tecnologia só cria empregos para pessoas com formação universitária"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does history show about technology and jobs?',
  $$["Technology always eliminates more jobs than it creates","Technology eliminates repetitive tasks but generally creates demand for new skills and types of work","Technology does not significantly affect the job market","Technology only creates jobs for people with university degrees"]$$::jsonb
FROM lessons WHERE slug = 's9-robos-empregos-futuro';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual habilidade humana os robôs têm mais dificuldade de replicar?","options":["Cálculos matemáticos complexos","Memorização de grandes volumes de informação","Empatia criatividade conexão humana e tomada de decisão em situações complexas e ambíguas","Movimentos físicos precisos e repetitivos"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'Which human skill do robots have the most difficulty replicating?',
  $$["Complex mathematical calculations","Memorization of large volumes of information","Empathy creativity human connection and decision making in complex and ambiguous situations","Precise and repetitive physical movements"]$$::jsonb
FROM lessons WHERE slug = 's9-robos-empregos-futuro';

-- s9-teste-missao-09 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Um aspirador moderno mapeia a casa, aprende onde estão os móveis e otimiza seu trajeto a cada limpeza. Como classificar essa tecnologia?","options":["Robô sem IA — segue instruções fixas","IA sem robô — só software sem corpo físico","Robô com IA — tem corpo físico e aprende com o ambiente","Nem robô nem IA — é apenas um eletrodoméstico"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'A modern vacuum maps the house, learns where the furniture is and optimizes its route with each cleaning. How to classify this technology?',
  $$["Robot without AI — follows fixed instructions","AI without robot — just software without physical body","Robot with AI — has physical body and learns from the environment","Neither robot nor AI — it is just a home appliance"]$$::jsonb
FROM lessons WHERE slug = 's9-teste-missao-09';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a melhor forma de se preparar para um futuro com muitos robôs e IA?","options":["Aprender a programar robôs para garantir emprego","Evitar tecnologia para não depender dela","Desenvolver habilidades que robôs não conseguem replicar e aprender a trabalhar com eles","Escolher profissões que nunca serão afetadas por tecnologia"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is the best way to prepare for a future with many robots and AI?',
  $$["Learn to program robots to guarantee employment","Avoid technology to not depend on it","Develop skills that robots cannot replicate and learn to work alongside them","Choose professions that will never be affected by technology"]$$::jsonb
FROM lessons WHERE slug = 's9-teste-missao-09';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s9-robo-nao-e-ia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Classifica essa tecnologia', 'Me ajuda a classificar essas tecnologias: [lista]. Cada uma é IA sem robô, robô sem IA, ou robô com IA?', '6-18', 1
FROM lessons WHERE slug = 's9-robo-nao-e-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA é o cérebro', 'Me explica com mais exemplos a diferença entre IA e robô usando a analogia de cérebro e corpo.', '6-18', 2
FROM lessons WHERE slug = 's9-robo-nao-e-ia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Robô com IA na prática', 'Me dá 3 exemplos de robôs com IA que já existem e explica como a IA melhora cada um.', '6-18', 3
FROM lessons WHERE slug = 's9-robo-nao-e-ia';

-- s9-como-robos-enxergam
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Projeta sensores', 'Quero criar um robô para [tarefa]. Quais sensores ele precisaria? Me explica cada um e por quê.', '6-18', 1
FROM lessons WHERE slug = 's9-como-robos-enxergam';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Como carros autônomos veem?', 'Me explica detalhadamente como um carro autônomo enxerga e entende o mundo ao seu redor.', '6-18', 2
FROM lessons WHERE slug = 's9-como-robos-enxergam';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Visão computacional na prática', 'Me dá exemplos do dia a dia onde a visão computacional está sendo usada agora.', '6-18', 3
FROM lessons WHERE slug = 's9-como-robos-enxergam';

-- s9-humanoides
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Desafios do humanoide', 'Quero criar um humanoide para [tarefa]. Quais seriam os 3 maiores desafios técnicos para esse robô funcionar bem?', '6-18', 1
FROM lessons WHERE slug = 's9-humanoides';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Atlas vs Optimus', 'Me explica as diferenças entre o Boston Dynamics Atlas e o Tesla Optimus. Qual é o objetivo de cada um?', '6-18', 2
FROM lessons WHERE slug = 's9-humanoides';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Futuro dos humanoides', 'Como você acha que os humanoides vão mudar a vida das pessoas nos próximos 10 anos?', '6-18', 3
FROM lessons WHERE slug = 's9-humanoides';

-- s9-robos-dia-a-dia
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Robôs que eu não conheço', 'Me surpreende com 5 robôs que já existem e que a maioria das pessoas não sabe que existem.', '6-18', 1
FROM lessons WHERE slug = 's9-robos-dia-a-dia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Robô para área específica', 'Quais robôs já estão sendo usados na área de [área]? Me conta como cada um funciona.', '6-18', 2
FROM lessons WHERE slug = 's9-robos-dia-a-dia';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Próximo robô do dia a dia', 'Qual você acha que será o próximo robô que vai entrar na vida das pessoas comuns nos próximos 5 anos?', '6-18', 3
FROM lessons WHERE slug = 's9-robos-dia-a-dia';

-- s9-robos-empregos-futuro
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Futuro da minha profissão', 'Quero ser [profissão]. Como robôs e IA vão transformar essa área? O que vai mudar e o que vai continuar importante?', '6-18', 1
FROM lessons WHERE slug = 's9-robos-empregos-futuro';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Habilidades do futuro', 'Quais são as habilidades mais importantes para desenvolver agora pensando no mercado de trabalho com muitos robôs e IA?', '6-18', 2
FROM lessons WHERE slug = 's9-robos-empregos-futuro';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Empregos do futuro', 'Me lista 5 profissões que vão crescer muito por causa da robótica e IA nos próximos 20 anos.', '6-18', 3
FROM lessons WHERE slug = 's9-robos-empregos-futuro';

COMMIT;
