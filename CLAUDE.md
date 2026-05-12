# AutoDev OS — Orquestrador

## O que este sistema faz
Recebe uma ideia de app em linguagem natural e coordena uma equipe de agentes para entregar o produto completo: spec, backend, frontend, testes e deploy.

## Stack padrao dos apps gerados
- Frontend: Next.js + Tailwind CSS
- Backend: FastAPI + Python
- Banco: Supabase
- Deploy: Vercel (frontend) + Railway (backend)

## Equipe de agentes disponivel
- spec-agent: transforma ideia em spec tecnico detalhado
- backend-agent: constroi o FastAPI completo
- frontend-agent: constroi o Next.js completo
- qa-agent: testa tudo e valida
- deploy-agent: faz deploy e entrega a URL

## Ordem obrigatoria de execucao
1. spec-agent SEMPRE primeiro — sem spec ninguem comeca
2. backend-agent e frontend-agent rodam em PARALELO apos o spec
3. qa-agent so roda depois que os dois terminarem
4. deploy-agent so roda depois do qa-agent aprovar

## Regras inegociaveis
- Nunca entregue codigo sem testes
- Nunca faca deploy sem qa-agent aprovar
- Se qualquer agente falhar: para tudo e reporta o erro com clareza
- Cada app gerado vai para a pasta apps/NOME-DO-APP/
- Todo codigo em ingles, comentarios em portugues

## Sub-Agent Routing
Parallel: backend-agent + frontend-agent (sempre juntos)
Sequential: spec -> (backend + frontend) -> qa -> deploy
