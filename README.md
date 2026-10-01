# DevOps Lab — Multi-Container Web Architecture

Ambiente de arquitetura web moderna conteinerizado utilizando **Docker** e **Docker Compose**, focado em boas práticas de engenharia de software, segurança de containers, isolamento de redes, persistência de dados e otimização de builds multiplataforma (Linux e Windows com WSL2).

---

## 🛠️ Tecnologias Utilizadas

- **Runtime / Backend:** Node.js 20 (Alpine Linux), TypeScript, Express
- **Banco de Dados Relacional:** PostgreSQL 16
- **Camada de Cache em Memória:** Redis 7 (Alpine Linux)
- **Containerização & Orquestração:** Docker Engine, Docker Compose v2 (Compose Specification)

---

## 🏛️ Arquitetura & Topologia de Redes

A stack foi projetada seguindo o princípio do menor privilégio em redes virtuais: apenas a aplicação expõe portas para o host (`3000`). Os serviços de banco de dados e cache operam exclusivamente dentro de uma rede *bridge* privada e isolada, comunicando-se via DNS interno do Docker.

```text
[ Host (Windows / Linux) ]
            │
            │ Porta 3000 (Mapeada)
            ▼
┌─────────────────────────────────────────────────────────────┐
│ Docker Bridge Network: app-network                          │
│                                                             │
│   ┌───────────────────┐                                     │
│   │    app (Node)     │                                     │
│   │  Non-root (node)  │                                     │
│   └─────────┬─────────┘                                     │
│             │                                               │
│             │ Resolução interna via DNS do Docker           │
│             ├───────────────────────┐                       │
│             │                       │                       │
│             ▼ (Porta 5432)          ▼ (Porta 6379)          │
│   ┌───────────────────┐   ┌───────────────────┐             │
│   │     postgres      │   │       redis       │             │
│   └─────────┬─────────┘   └─────────┬─────────┘             │
└─────────────┼───────────────────────┼───────────────────────┘
              ▼                       ▼
      [ Volume Nomeado ]      [ Volume Nomeado ]
           pgdata                  redisdata