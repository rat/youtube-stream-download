#!/bin/bash

API_KEYS=("1" "2" "3" "4")

random_index=$((RANDOM % ${#API_KEYS[@]}))
API_KEY="${API_KEYS[$random_index]}"

# Substitua "ID_DO_CANAL" pelo ID do canal do YouTube desejado
CHANNEL_ID="UC-ejCZg37Eyj1Ln5hJAheCw"

# Nome do arquivo para salvar a URL do último vídeo
FILE_NAME="/home/rat/last_url.txt"

# URL da API do YouTube para obter os vídeos mais recentes de um canal
API_URL="https://www.googleapis.com/youtube/v3/search?part=snippet&eventType=live&channelId=$CHANNEL_ID&type=video&order=date&maxResults=1&key=$API_KEY"

# Substitua "SEU_TOKEN_AQUI" pelo token do seu bot
BOT_TOKEN="1"

# Substitua "SEU_CHAT_ID_AQUI" pelo ID do chat para onde você deseja enviar a mensagem
CHAT_ID="1"

MESSAGE="new video downloaded"

# Função para enviar mensagem para o Telegram
send_message() {
    local message="$1"
    local api_url="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

    # Use o cURL para fazer a solicitação à API
    curl -s -X POST "$api_url" -d "chat_id=$CHAT_ID&text=$message"
}

# Use o cURL para fazer a solicitação à API e obter a resposta em JSON
response=$(curl -s "$API_URL")

# Extrair o link do vídeo mais recente do JSON
latest_video_link=$(echo "$response" | jq -r '.items[0].id.videoId' | xargs -I{} echo "https://www.youtube.com/watch?v={}")

# Verificar se o arquivo existe
if [ -e "$FILE_NAME" ]; then
    # Ler a URL do arquivo
    saved_video_link=$(cat "$FILE_NAME")

    # Verificar se a URL do arquivo é diferente da última URL
    if [ "$latest_video_link" != "$saved_video_link" ]; then
        # Salvar a última URL no arquivo
        echo "$latest_video_link" > "$FILE_NAME"
        # Imprimir a URL
        yt-dlp --live-from-start --force-ipv4 --progress -o "/home/rat/Dropbox/%(title)s-%(id)s.%(ext)s" "$latest_video_link" > output.log 2>&1
        send_message "$MESSAGE"
    fi
else
    # Se o arquivo não existir, criá-lo e salvar a URL
    echo "$latest_video_link" > "$FILE_NAME"
    # Imprimir a URL
    yt-dlp --live-from-start --force-ipv4 --progress -o "/home/rat/Dropbox/%(title)s-%(id)s.%(ext)s" "$latest_video_link" > output.log 2>&1
    send_message "$MESSAGE"
fi
