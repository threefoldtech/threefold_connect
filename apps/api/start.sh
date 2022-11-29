./wait-for-it.sh "${DATABASE_HOST:-dev-database}":"${DATABASE_PORT:-3306}" --strict --timeout=45 -- npm run prisma:migrate-prod
pm2-runtime start ./dist/main.js
