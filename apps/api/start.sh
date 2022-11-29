sleep 5
npm run prisma:migrate-prod
pm2-runtime start ./dist/main.js
