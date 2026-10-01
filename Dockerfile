# ==========================================
# Estágio 1: Build & Dependências de Compilação
# ==========================================

FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copia apenas os manifestos de dependência primeiro para otimizar cache
COPY package*.json ./

# Instala todas as dependências (incluindo devDependencies como typescript)
RUN npm ci

# Copia o código-fonte e compila para JavaScript
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ==========================================
# Estágio 2: Imagem Final de Execução (Runtime)
# ==========================================
FROM node:20-alpine AS runner

# Boa prática: definir variável de ambiente para produção
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Copia os manifestos novamente para instalar APENAS dependências de produção
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copia apenas os arquivos transpilados do estágio builder
COPY --from=builder /usr/src/app/dist ./dist

# Altera a propriedade da pasta para o usuário não-privilegiado 'node'
RUN chown -R node:node /usr/src/app

# Troca o usuário de execução de root (UID 0) para node (UID 1000)
USER node

# Documenta a porta que a aplicação escuta internamente
EXPOSE 3000

# Execução do binário compilado
CMD ["node", "dist/index.js"]