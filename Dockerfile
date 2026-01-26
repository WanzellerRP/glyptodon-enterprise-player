FROM nginx:1.25-alpine
COPY glyptodon-enterprise-player-1.1.0-1/ /usr/share/nginx/html/
EXPOSE 80
