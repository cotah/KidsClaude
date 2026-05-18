-- Migration 032: Insere conteudo da Stage 15 "Missao 15 - Etica e responsabilidade"
--
-- Foco: etica em IA - por que importa (discriminacao/vigilancia/desinformacao),
-- vies fairness representacao (casos Amazon/reconhecimento facial/saude),
-- transparencia explicabilidade consentimento (AI Act, LGPD), cadeia de
-- responsabilidade (criadores/empresas/usuarios/reguladores), e voce como
-- criador etico (checklist de 5 perguntas).
-- 5 licoes de conteudo + 1 teste de stage.
-- Todas: stage=15, age_band='6-18', xp_reward=75, claude_model haiku.
--
-- Sem schema changes. BEGIN/COMMIT garante atomicidade. Gate slug-only.

BEGIN;

-- 1) Insere as 6 licoes da Stage 15
INSERT INTO lessons
  (slug, title, title_en, description, description_en, age_band, stage,
   order_index, content_blocks, content_blocks_en,
   chat_objective, chat_objective_en,
   xp_reward, is_active, is_final_exam, claude_model)
VALUES
(
  's15-por-que-etica-ia-importa',
  'Por que ética em IA importa?',
  'Why does AI ethics matter?',
  'Entender por que ética em IA é urgente e prática, não apenas filosófica',
  'Understand why AI ethics is urgent and practical, not just philosophical',
  '6-18', 15, 1,
  $$[
    {"type":"text","content":"Tecnologia não é neutra. Ela amplifica o que os humanos colocam nela — tanto o bem quanto o mal. E IA é a tecnologia mais poderosa que a humanidade já criou. Por isso ética em IA não é assunto chato de filósofo — é uma questão urgente e prática. DISCRIMINAÇÃO EM ESCALA: um algoritmo de contratação treinado com dados históricos pode aprender que homens foram mais contratados e rejeitar automaticamente currículos de mulheres. Aconteceu de verdade na Amazon em 2018."},
    {"type":"text","content":"VIGILÂNCIA SEM CONSENTIMENTO: reconhecimento facial em câmeras públicas pode rastrear onde cada pessoa vai e com quem se encontra. DESINFORMAÇÃO EM ESCALA: com IA criar fake news convincentes ficou barato e rápido. EXCLUSÃO DE SERVIÇOS: um algoritmo de crédito pode negar empréstimo para pessoas de certos bairros perpetuando desigualdade histórica."},
    {"type":"text","content":"A boa notícia: os mesmos humanos que constroem IA podem construí-la de forma ética. Mas isso requer intenção, cuidado e responsabilidade ativa. Entender os riscos é o primeiro passo para evitá-los."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Technology is not neutral. It amplifies what humans put into it — both good and bad. And AI is the most powerful technology humanity has ever created. That is why AI ethics is not a boring philosopher topic — it is an urgent and practical matter. DISCRIMINATION AT SCALE: a hiring algorithm trained on historical data can learn that men were hired more often and automatically reject womens resumes. This really happened at Amazon in 2018."},
    {"type":"text","content":"SURVEILLANCE WITHOUT CONSENT: facial recognition on public cameras can track where each person goes and who they meet. DISINFORMATION AT SCALE: with AI creating convincing fake news became cheap and fast. SERVICE EXCLUSION: a credit algorithm can deny loans to people from certain neighborhoods perpetuating historical inequality."},
    {"type":"text","content":"The good news: the same humans who build AI can build it ethically. But that requires intention, care and active responsibility. Understanding the risks is the first step to preventing them."}
  ]$$::jsonb,
  'A criança e a Atena analisam um caso real de IA usada de forma antiética. Objetivo: desenvolver capacidade de identificar problemas éticos em sistemas de IA.',
  'The child and Atena analyze a real case of AI used unethically. Goal: develop the ability to identify ethical problems in AI systems.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's15-vies-fairness-representacao',
  'Viés, fairness e representação',
  'Bias, fairness and representation',
  'Entender como viés se manifesta em IA e o que significa fairness',
  'Understand how bias manifests in AI and what fairness means',
  '6-18', 15, 2,
  $$[
    {"type":"text","content":"Viés em IA não é acidente — é herança. A IA aprende dos dados que humanos criaram. E os dados humanos carregam séculos de preconceitos e exclusões. Exemplos reais: reconhecimento facial que funciona bem para pessoas brancas mas erra sistematicamente em pessoas negras — porque foi treinado com mais fotos de pessoas brancas. Tradutor automático que transforma ela é médica em ele é médico — porque no corpus médicos eram mais frequentemente masculinos."},
    {"type":"text","content":"Algoritmo de saúde que priorizava pacientes brancos para tratamentos — porque histórico de gastos (usado como proxy de necessidade) era menor em populações negras por falta de acesso histórico. Fairness em IA significa garantir que o sistema funcione igualmente bem para todos os grupos. Isso é mais difícil do que parece porque diferentes definições de justo podem ser matematicamente incompatíveis."},
    {"type":"text","content":"O que você pode fazer: quando usar IA questione para quem isso foi testado, quem está sendo excluído, e quem tomou as decisões sobre os dados de treinamento. Questionar é o primeiro ato de responsabilidade."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Bias in AI is not an accident — it is an inheritance. AI learns from data that humans created. And human data carries centuries of prejudices and exclusions. Real examples: facial recognition that works well for white people but systematically fails for Black people — because it was trained with more photos of white people. Automatic translator that turns she is a doctor into he is a doctor — because in the corpus doctors were more frequently male."},
    {"type":"text","content":"Health algorithm that prioritized white patients for treatments — because spending history (used as a proxy for need) was lower in Black populations due to historical lack of access. Fairness in AI means ensuring the system works equally well for all groups. This is harder than it seems because different definitions of fair can be mathematically incompatible."},
    {"type":"text","content":"What you can do: when using AI ask who this was tested for, who is being excluded, and who made decisions about the training data. Questioning is the first act of responsibility."}
  ]$$::jsonb,
  'A criança e a Atena investigam um sistema de IA do dia a dia e analisam possíveis vieses. Objetivo: desenvolver o hábito de questionar sistemas de IA criticamente.',
  'The child and Atena investigate an everyday AI system and analyze possible biases. Goal: develop the habit of questioning AI systems critically.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's15-transparencia-consentimento',
  'Transparência, explicabilidade e consentimento',
  'Transparency, explainability and consent',
  'Conhecer os três princípios fundamentais da IA ética',
  'Know the three fundamental principles of ethical AI',
  '6-18', 15, 3,
  $$[
    {"type":"text","content":"Três princípios fundamentais da IA ética que todo cidadão deveria conhecer. TRANSPARÊNCIA: você tem o direito de saber quando uma decisão sobre você foi tomada por uma IA. Seu currículo foi rejeitado por algoritmo? Você tem direito de saber. Um crédito foi negado por IA? Você tem direito de saber. Hoje muitas empresas escondem isso. EXPLICABILIDADE: você tem direito de saber por que a IA tomou aquela decisão. O algoritmo decidiu não é resposta aceitável para decisão que afeta sua vida."},
    {"type":"text","content":"CONSENTIMENTO: você tem direito de decidir se aceita que IA tome decisões sobre você. Seus dados pessoais podem ser usados para treinar IA? Você deveria poder dizer não. Empresas que usam dados sem consentimento violam um direito fundamental. Na prática: quando um app pede acesso a seus dados leia o que vai fazer. Quando um serviço usa IA para decisões sobre você questione."},
    {"type":"text","content":"O AI Act europeu e leis de proteção de dados como a LGPD no Brasil existem para proteger esses direitos. Conhecê-los é o primeiro passo para exigi-los. Seus dados valem dinheiro — e você tem o direito de decidir quem os usa e como."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Three fundamental principles of ethical AI that every citizen should know. TRANSPARENCY: you have the right to know when a decision about you was made by an AI. Was your resume rejected by an algorithm? You have the right to know. Was a loan denied by AI? You have the right to know. Today many companies hide this. EXPLAINABILITY: you have the right to know why AI made that decision. The algorithm decided is not an acceptable answer for a decision that affects your life."},
    {"type":"text","content":"CONSENT: you have the right to decide whether you accept AI making decisions about you. Can your personal data be used to train AI? You should be able to say no. Companies that use data without consent are violating a fundamental right. In practice: when an app asks for access to your data read what it will do with it. When a service uses AI for decisions about you, question it."},
    {"type":"text","content":"The European AI Act and data protection laws like Brazils LGPD exist to protect these rights. Knowing them is the first step to demanding them. Your data is worth money — and you have the right to decide who uses it and how."}
  ]$$::jsonb,
  'A criança analisa os termos de privacidade de um app que usa e a Atena explica o que cada cláusula significa na prática.',
  'The child analyzes the privacy terms of an app they use and Atena explains what each clause means in practice.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's15-responsabilidade-quem-culpado',
  'Responsabilidade — quem é culpado quando IA erra?',
  'Responsibility — who is guilty when AI makes mistakes?',
  'Entender a cadeia de responsabilidade quando sistemas de IA causam danos',
  'Understand the chain of responsibility when AI systems cause harm',
  '6-18', 15, 4,
  $$[
    {"type":"text","content":"Quando uma IA comete um erro grave quem é responsável? É uma das questões mais difíceis da era da IA. O carro autônomo que atropela alguém: o fabricante? O programador? A empresa dos dados? O dono? Não existe resposta simples. A cadeia de responsabilidade na IA: CRIADORES — responsáveis pelo design, pelos dados, pelos testes e pelos limites do sistema. EMPRESAS — responsáveis por como o sistema é implantado e monitorado."},
    {"type":"text","content":"USUÁRIOS — responsáveis por como usam a ferramenta especialmente em decisões que afetam outras pessoas. REGULADORES — responsáveis por criar regras que protejam pessoas e punam abusos. A ideia de que a IA decidiu não elimina responsabilidade humana — ela distribui. E você como usuário é parte dessa cadeia."},
    {"type":"text","content":"Usar IA de forma irresponsável tem consequências mesmo que não intencionais. Se você usa uma ferramenta de IA para criar deepfakes, espalhar desinformação ou prejudicar alguém, você é responsável — a ferramenta é apenas o instrumento."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"When an AI makes a serious mistake who is responsible? It is one of the hardest questions of the AI era. The self-driving car that runs someone over: the manufacturer? The programmer? The data company? The owner? There is no simple answer. The chain of responsibility in AI: CREATORS — responsible for design, data, testing and system limits. COMPANIES — responsible for how the system is deployed and monitored."},
    {"type":"text","content":"USERS — responsible for how they use the tool especially in decisions that affect other people. REGULATORS — responsible for creating rules that protect people and punish abuses. The idea that AI decided does not eliminate human responsibility — it distributes it. And you as a user are part of that chain."},
    {"type":"text","content":"Using AI irresponsibly has consequences even if unintentional. If you use an AI tool to create deepfakes, spread disinformation or harm someone, you are responsible — the tool is just the instrument."}
  ]$$::jsonb,
  'A criança e a Atena debatem um caso hipotético de IA que errou e analisam a cadeia de responsabilidade — quem contribuiu e quem deveria responder.',
  'The child and Atena debate a hypothetical case of AI that went wrong and analyze the chain of responsibility — who contributed and who should answer.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's15-voce-criador-etico',
  'Você como criador ético de IA',
  'You as an ethical AI creator',
  'Aprender a aplicar pensamento ético ao criar com IA',
  'Learn to apply ethical thinking when creating with AI',
  '6-18', 15, 5,
  $$[
    {"type":"text","content":"Não espere ser engenheiro sênior para pensar em ética. As decisões éticas mais importantes acontecem no começo — na definição do problema, na escolha dos dados, no design das regras. O checklist ético para criadores: 1) PARA QUEM ESTOU CRIANDO? Quem se beneficia? Quem pode ser prejudicado? Estou incluindo pessoas geralmente excluídas? 2) QUAIS DADOS ESTOU USANDO? De onde vêm? São representativos? Alguém deu consentimento?"},
    {"type":"text","content":"3) O QUE ACONTECE QUANDO ERRO? Qual é o pior caso? Como detectar e corrigir erros? Existe forma de o usuário contestar? 4) QUEM SUPERVISIONA? Existe um humano no loop para decisões importantes? Existe monitoramento contínuo? 5) QUE IMPACTO ISSO TEM NO MUNDO? Além de resolver o problema do usuário que outros efeitos isso cria para a sociedade e grupos vulneráveis?"},
    {"type":"text","content":"Criar IA eticamente não é mais difícil que criar de qualquer jeito — é apenas mais consciente. E criadores conscientes constroem um futuro melhor. A frase que deve guiar tudo: poder sem responsabilidade cria dano. Tecnologia sem ética amplifica esse dano."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Do not wait to be a senior engineer to think about ethics. The most important ethical decisions happen at the beginning — in problem definition, data choices, rule design. The ethical checklist for creators: 1) WHO AM I CREATING FOR? Who benefits? Who could be harmed? Am I including people who are usually excluded? 2) WHAT DATA AM I USING? Where does it come from? Is it representative? Did anyone give consent?"},
    {"type":"text","content":"3) WHAT HAPPENS WHEN I MAKE MISTAKES? What is the worst case? How to detect and correct errors? Is there a way for the user to contest? 4) WHO SUPERVISES? Is there a human in the loop for important decisions? Is there continuous monitoring? 5) WHAT IMPACT DOES THIS HAVE ON THE WORLD? Beyond solving the users problem what other effects does this create for society and vulnerable groups?"},
    {"type":"text","content":"Creating AI ethically is not harder than creating it any other way — it is just more conscious. And conscious creators build a better future. The phrase that should guide everything: power without responsibility creates harm. Technology without ethics amplifies that harm."}
  ]$$::jsonb,
  'A criança aplica o checklist ético a um projeto que criou ou quer criar. A Atena ajuda a identificar riscos éticos e sugerir como mitigá-los.',
  'The child applies the ethical checklist to a project they created or want to create. Atena helps identify ethical risks and suggest how to mitigate them.',
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
),
(
  's15-teste-missao-15',
  'Teste — Missão 15',
  'Test — Mission 15',
  'Quiz para fechar a Missão 15',
  'Quiz to complete Mission 15',
  '6-18', 15, 6,
  $$[
    {"type":"text","content":"Hora de testar o que você aprendeu na Missão 15! Responda as 2 perguntas e avance para a última missão."}
  ]$$::jsonb,
  $$[
    {"type":"text","content":"Time to test what you learned in Mission 15! Answer the 2 questions and advance to the final mission."}
  ]$$::jsonb,
  NULL, NULL,
  75, TRUE, FALSE, 'claude-haiku-4-5-20251001'
);

-- 2) Challenges: 2 por licao = 12 total (PT + EN)

-- s15-por-que-etica-ia-importa
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que aconteceu com o algoritmo de contratação da Amazon em 2018?","options":["Ele contratou pessoas demais e precisou ser desligado","Aprendeu com dados históricos que favoreciam homens e passou a rejeitar automaticamente currículos de mulheres","Ele vazou dados pessoais de candidatos para concorrentes","Ficou tão lento que precisou ser substituído por humanos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What happened with the Amazon hiring algorithm in 2018?',
  $$["It hired too many people and had to be shut down","It learned from historical data that favored men and started automatically rejecting womens resumes","It leaked personal data from candidates to competitors","It got so slow it had to be replaced by humans"]$$::jsonb
FROM lessons WHERE slug = 's15-por-que-etica-ia-importa';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que ética em IA é uma questão urgente e prática não apenas filosófica?","options":["Porque reguladores exigem documentação ética antes de lançar produtos","Porque decisões de IA afetam a vida real de pessoas reais em escala — emprego crédito segurança e oportunidades","Porque empresas de IA precisam de boa reputação para atrair investidores","Porque filósofos são os únicos que entendem como IA funciona"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is AI ethics an urgent and practical issue not just philosophical?',
  $$["Because regulators require ethical documentation before launching products","Because AI decisions affect the real lives of real people at scale — jobs credit security and opportunities","Because AI companies need a good reputation to attract investors","Because philosophers are the only ones who understand how AI works"]$$::jsonb
FROM lessons WHERE slug = 's15-por-que-etica-ia-importa';

-- s15-vies-fairness-representacao
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que viés em IA é descrito como herança?","options":["Porque IA herda problemas dos computadores antigos que a precederam","Porque a IA aprende dos dados criados por humanos que carregam preconceitos históricos e desigualdades existentes","Porque viés é transmitido de uma versão de IA para outra automaticamente","Porque programadores herdam viés dos seus professores de programação"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is bias in AI described as an inheritance?',
  $$["Because AI inherits problems from old computers that preceded it","Because AI learns from data created by humans that carries historical prejudices and existing inequalities","Because bias is transmitted from one AI version to another automatically","Because programmers inherit bias from their programming teachers"]$$::jsonb
FROM lessons WHERE slug = 's15-vies-fairness-representacao';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual pergunta você deve fazer ao usar qualquer sistema de IA?","options":["Qual empresa criou esse sistema e qual o preço da assinatura?","Para quem isso foi testado quem está sendo excluído e quem tomou as decisões sobre os dados?","Quantos parâmetros esse modelo tem e qual é sua velocidade de processamento?","Qual é o prazo de validade dos dados de treinamento?"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What question should you ask when using any AI system?',
  $$["Which company created this system and what is the subscription price?","Who was this tested for who is being excluded and who made decisions about the data?","How many parameters does this model have and what is its processing speed?","What is the expiration date of the training data?"]$$::jsonb
FROM lessons WHERE slug = 's15-vies-fairness-representacao';

-- s15-transparencia-consentimento
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa explicabilidade em IA ética?","options":["A capacidade da IA de explicar conceitos científicos complexos","O direito de saber por que a IA tomou uma decisão que afeta você com os fatores que influenciaram","A capacidade de exportar os dados de treinamento do modelo","A documentação técnica que programadores usam para entender o código"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does explainability mean in ethical AI?',
  $$["The AI capability to explain complex scientific concepts","The right to know why AI made a decision that affects you with the factors that influenced it","The ability to export training data from the model","The technical documentation programmers use to understand the code"]$$::jsonb
FROM lessons WHERE slug = 's15-transparencia-consentimento';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que é consentimento no contexto de uso de dados para IA?","options":["A permissão que a empresa dá para você usar o produto gratuitamente","O direito de decidir se aceita que seus dados pessoais sejam usados para treinar IA ou tomar decisões sobre você","O processo de verificação de identidade ao criar uma conta","A aceitação dos termos de uso obrigatória para usar qualquer serviço digital"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What is consent in the context of data use for AI?',
  $$["The permission the company gives you to use the product for free","The right to decide if you accept that your personal data is used to train AI or make decisions about you","The identity verification process when creating an account","The mandatory acceptance of terms of use to use any digital service"]$$::jsonb
FROM lessons WHERE slug = 's15-transparencia-consentimento';

-- s15-responsabilidade-quem-culpado
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que a IA decidiu não é uma resposta aceitável quando algo dá errado?","options":["Porque IAs não tomam decisões apenas seguem regras fixas","Porque a responsabilidade é distribuída entre criadores empresas usuários e reguladores e não desaparece só porque uma IA foi o instrumento","Porque IAs nunca erram quando são bem programadas","Porque leis proíbem atribuir decisões a sistemas automáticos"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why is AI decided not an acceptable answer when something goes wrong?',
  $$["Because AIs do not make decisions they only follow fixed rules","Because responsibility is distributed among creators companies users and regulators and does not disappear just because an AI was the instrument","Because AIs never make mistakes when well programmed","Because laws prohibit attributing decisions to automated systems"]$$::jsonb
FROM lessons WHERE slug = 's15-responsabilidade-quem-culpado';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Qual é a responsabilidade do usuário na cadeia de responsabilidade da IA?","options":["Nenhuma — a responsabilidade é totalmente dos criadores e das empresas","Apenas reportar bugs e erros para o suporte técnico","Ser responsável por como usa a ferramenta especialmente em decisões que afetam outras pessoas","Pagar pela IA corretamente para garantir qualidade do serviço"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'What is the users responsibility in the AI responsibility chain?',
  $$["None — responsibility is totally on creators and companies","Only reporting bugs and errors to technical support","Being responsible for how they use the tool especially in decisions that affect other people","Paying for AI correctly to ensure service quality"]$$::jsonb
FROM lessons WHERE slug = 's15-responsabilidade-quem-culpado';

-- s15-voce-criador-etico
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Por que decisões éticas são mais importantes no começo de um projeto do que no final?","options":["Porque é mais barato corrigir problemas éticos antes de lançar o produto","Porque as escolhas fundamentais de dados design e regras definem o que é possível corrigir depois — e erros no início se multiplicam","Porque reguladores só auditam a fase inicial do desenvolvimento","Porque usuários beta testam ética antes de qualidade técnica"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'Why are ethical decisions more important at the beginning of a project than at the end?',
  $$["Because it is cheaper to fix ethical problems before launching the product","Because fundamental choices of data design and rules define what can be fixed later — and early errors multiply","Because regulators only audit the initial development phase","Because beta users test ethics before technical quality"]$$::jsonb
FROM lessons WHERE slug = 's15-voce-criador-etico';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"O que significa ter um humano no loop num sistema de IA?","options":["Ter um programador disponível 24h para corrigir bugs","Garantir que decisões importantes tenham supervisão humana não sendo tomadas completamente de forma autônoma","Usar interface de voz para interagir com a IA","Ter um time de moderação para revisar todo conteúdo gerado"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'What does it mean to have a human in the loop in an AI system?',
  $$["Having a 24h available programmer to fix bugs","Ensuring important decisions have human supervision not being made completely autonomously","Using voice interface to interact with AI","Having a moderation team to review all generated content"]$$::jsonb
FROM lessons WHERE slug = 's15-voce-criador-etico';

-- s15-teste-missao-15 (stage test - 2 challenges)
INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Uma empresa usou IA para selecionar candidatos e descobriu-se que o sistema rejeitava automaticamente mulheres para cargos técnicos. Qual é a causa provável e quem é responsável?","options":["A IA malfuncionou por bug técnico e só os programadores são responsáveis","O sistema aprendeu viés dos dados históricos de contratação e a responsabilidade é distribuída entre quem criou implantou e não monitorou","As candidatas não preencheram o formulário corretamente","A IA foi hackeada e reprogramada por concorrentes"]}$$::jsonb,
  '{"answer": 1}'::jsonb, 10,
  'A company used AI to select candidates and it was discovered the system automatically rejected women for technical roles. What is the likely cause and who is responsible?',
  $$["AI malfunctioned due to technical bug and only programmers are responsible","The system learned bias from historical hiring data and responsibility is distributed among those who created deployed and did not monitor","The candidates did not fill out the form correctly","AI was hacked and reprogrammed by competitors"]$$::jsonb
FROM lessons WHERE slug = 's15-teste-missao-15';

INSERT INTO challenges (lesson_id, kind, question, correct_answer, xp_reward, question_en, options_en)
SELECT id, 'multiple_choice',
  $${"question":"Você está criando um app de recomendação de livros com IA. Qual pergunta do checklist ético é mais importante fazer primeiro?","options":["Qual modelo de IA tem a API mais barata?","Quantos usuários preciso para o negócio ser lucrativo?","Para quem estou criando quem pode ser beneficiado e quem pode ser excluído ou prejudicado?","Qual linguagem de programação usar no backend?"]}$$::jsonb,
  '{"answer": 2}'::jsonb, 10,
  'You are creating a book recommendation app with AI. Which ethical checklist question is most important to ask first?',
  $$["Which AI model has the cheapest API?","How many users do I need for the business to be profitable?","Who am I creating for who can be benefited and who can be excluded or harmed?","Which programming language to use in the backend?"]$$::jsonb
FROM lessons WHERE slug = 's15-teste-missao-15';

-- 3) prompt_templates: 3 por licao de conteudo (5 licoes) = 15 total.

-- s15-por-que-etica-ia-importa
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Analisa esse caso ético', 'Me conta um caso real onde IA foi usada de forma antiética e me ajuda a entender o que deu errado e quem foi afetado.', '6-18', 1
FROM lessons WHERE slug = 's15-por-que-etica-ia-importa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Riscos da IA no dia a dia', 'Quais são os riscos éticos mais comuns de IAs que as pessoas usam no dia a dia sem perceber?', '6-18', 2
FROM lessons WHERE slug = 's15-por-que-etica-ia-importa';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'IA ética vs não ética', 'Me dá um exemplo de IA usada eticamente e outro usado de forma antiética na mesma área. O que faz a diferença?', '6-18', 3
FROM lessons WHERE slug = 's15-por-que-etica-ia-importa';

-- s15-vies-fairness-representacao
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Testa viés', 'Vou te fazer perguntas sobre [grupo de pessoas]. Me avisa se você perceber viés nas suas respostas e explica de onde pode vir.', '6-18', 1
FROM lessons WHERE slug = 's15-vies-fairness-representacao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Fairness na prática', 'Me explica como um sistema de contratação com IA poderia ser mais justo. Quais salvaguardas seriam necessárias?', '6-18', 2
FROM lessons WHERE slug = 's15-vies-fairness-representacao';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quem foi excluído?', 'Pensa num sistema de IA para [aplicação]. Quais grupos de pessoas provavelmente foram sub-representados nos dados de treinamento?', '6-18', 3
FROM lessons WHERE slug = 's15-vies-fairness-representacao';

-- s15-transparencia-consentimento
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Explica esses termos', 'Esses são os termos de privacidade de [app]: [cola aqui]. Me explica em linguagem simples o que eles estão me pedindo para aceitar.', '6-18', 1
FROM lessons WHERE slug = 's15-transparencia-consentimento';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Meus direitos digitais', 'Quais são meus direitos quando uma empresa usa IA para tomar decisões sobre mim? O que a LGPD garante?', '6-18', 2
FROM lessons WHERE slug = 's15-transparencia-consentimento';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Consentimento na prática', 'Me dá exemplos concretos de uso de dados com consentimento versus sem consentimento. O que diferencia cada caso?', '6-18', 3
FROM lessons WHERE slug = 's15-transparencia-consentimento';

-- s15-responsabilidade-quem-culpado
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Quem é responsável?', 'Nesse cenário: [descreve situação de IA que causou dano]. Analisa a cadeia de responsabilidade — quem contribuiu e quem deveria responder?', '6-18', 1
FROM lessons WHERE slug = 's15-responsabilidade-quem-culpado';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Regulação de IA', 'Como países deveriam regular IA para proteger pessoas sem impedir a inovação? Quais são os principais desafios?', '6-18', 2
FROM lessons WHERE slug = 's15-responsabilidade-quem-culpado';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Minha responsabilidade', 'Como usuário de IA quais são minhas responsabilidades éticas? Me dá exemplos concretos do dia a dia.', '6-18', 3
FROM lessons WHERE slug = 's15-responsabilidade-quem-culpado';

-- s15-voce-criador-etico
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Checklist ético do meu projeto', 'Meu projeto é [descreve]. Me ajuda a passar pelo checklist ético — quais riscos existem e como posso mitigá-los?', '6-18', 1
FROM lessons WHERE slug = 's15-voce-criador-etico';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Humano no loop', 'Estou criando [sistema com IA]. Em quais decisões devo ter supervisão humana obrigatória? Como implementar isso?', '6-18', 2
FROM lessons WHERE slug = 's15-voce-criador-etico';
INSERT INTO prompt_templates (lesson_id, label, template, age_band, order_index)
SELECT id, 'Impacto além do usuário', 'Meu produto é [descreve]. Quais efeitos ele poderia ter além dos usuários diretos — na sociedade, em grupos vulneráveis, no meio ambiente?', '6-18', 3
FROM lessons WHERE slug = 's15-voce-criador-etico';

COMMIT;
