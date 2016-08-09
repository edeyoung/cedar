echo -n "DEVISE_SECRET_KEY=" > .env-prod
cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 36 | head -n 1 >> .env-prod
echo -n "SECRET_KEY_BASE=" >> .env-prod
cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 36 | head -n 1 >> .env-prod
echo -n >> .env-prod
