echo -n "DEVISE_SECRET_KEY=" > .env-prod
rake secret >> .env-prod
echo -n "SECRET_KEY_BASE=" >> .env-prod
rake secret >> .env-prod
echo -n >> .env-prod
