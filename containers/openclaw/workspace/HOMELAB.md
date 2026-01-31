# Homelab Services

You have access to the following homelab services via their APIs. Use `curl` with the exec tool to interact with them.

## Network Topology

- **Host IP**: `192.168.1.5` (NixOS homelab machine running this OpenClaw instance)
- **Synology NAS**: `192.168.1.2` (runs Jellyfin)
- **Container DNS**: Services on the podman network can be accessed by container name (e.g., `http://sonarr:8989`)

## Media Services

### Jellyfin (Media Server) - Synology NAS
- **URL**: `http://192.168.1.2:8096` (on Synology NAS, not accessible by container name)
- **API Key**: Available as `$JELLYFIN_API_KEY` environment variable
- **Auth Header**: `X-Emby-Token: $JELLYFIN_API_KEY`
- **Docs**: https://api.jellyfin.org/
- **Common endpoints**:
  - `GET /Users` - List users
  - `GET /Users/{userId}/Items` - Get user's media items
  - `GET /Users/{userId}/Items/Latest` - Recently added items
  - `GET /Sessions` - Active playback sessions
  - `GET /System/Info` - Server info

### Sonarr (TV Shows)
- **URL**: `http://sonarr:8989`
- **API Key**: Available as `$SONARR_API_KEY` environment variable
- **Auth Header**: `X-Api-Key: $SONARR_API_KEY`
- **Common endpoints**:
  - `GET /api/v3/series` - List all series
  - `GET /api/v3/queue` - Download queue
  - `GET /api/v3/calendar` - Upcoming episodes
  - `GET /api/v3/history` - Recent activity
  - `GET /api/v3/system/status` - System status

### Radarr (Movies)
- **URL**: `http://radarr:7878`
- **API Key**: Available as `$RADARR_API_KEY` environment variable
- **Auth Header**: `X-Api-Key: $RADARR_API_KEY`
- **Common endpoints**:
  - `GET /api/v3/movie` - List all movies
  - `GET /api/v3/queue` - Download queue
  - `GET /api/v3/calendar` - Upcoming releases
  - `GET /api/v3/system/status` - System status

### Prowlarr (Indexer Manager)
- **URL**: `http://prowlarr:9696`
- **API Key**: Available as `$PROWLARR_API_KEY` environment variable
- **Auth Header**: `X-Api-Key: $PROWLARR_API_KEY`

### Bazarr (Subtitles)
- **URL**: `http://bazarr:6767`
- **API Key**: Available as `$BAZARR_API_KEY` environment variable

### Jellyseerr (Media Requests & Discovery)
- **URL**: `http://jellyseerr:5055` or `http://192.168.1.5:5055`
- **API Key**: Available as `$JELLYSEERR_API_KEY` environment variable
- **Auth Header**: `X-Api-Key: $JELLYSEERR_API_KEY`
- **Docs**: https://api-docs.overseerr.dev/ (Jellyseerr uses Overseerr API)
- **Common endpoints**:
  - `GET /api/v1/discover/movies` - Discover popular/trending movies
  - `GET /api/v1/discover/movies/upcoming` - Upcoming movies
  - `GET /api/v1/discover/tv` - Discover popular/trending TV shows
  - `GET /api/v1/discover/tv/upcoming` - Upcoming TV shows
  - `GET /api/v1/discover/trending` - Trending media (movies & TV)
  - `GET /api/v1/request` - List all requests
  - `POST /api/v1/request` - Create a new request
  - `GET /api/v1/search?query={query}` - Search for movies/TV shows
  - `GET /api/v1/movie/{tmdbId}` - Get movie details by TMDB ID
  - `GET /api/v1/tv/{tmdbId}` - Get TV show details by TMDB ID
  - `GET /api/v1/movie/{tmdbId}/recommendations` - Get movie recommendations
  - `GET /api/v1/tv/{tmdbId}/recommendations` - Get TV show recommendations
  - `GET /api/v1/media?filter=available` - Media already available in library
  - `GET /api/v1/media?filter=processing` - Media being processed

## Download Clients

### qBittorrent (via gluetun VPN)
- **URL**: `http://gluetun:8080` (routes through VPN container)
- **Auth**: Username `admin`, password available as `$QBITTORRENT_PASSWORD`
- **Note**: Requires session authentication first
- **Common endpoints**:
  - `POST /api/v2/auth/login` - Login (username=admin, password=$QBITTORRENT_PASSWORD)
  - `GET /api/v2/torrents/info` - List torrents (after login)
  - `GET /api/v2/transfer/info` - Transfer stats
  - `GET /api/v2/sync/maindata` - Full sync data

## System Services

### Grafana (Monitoring)
- **URL**: `http://192.168.1.5:2342`
- **Auth**: Username `admin`, password available as `$GRAFANA_PASSWORD`

### Uptime Kuma (Status Monitoring)
- **URL**: `http://uptimekuma:3001`

### AdGuard Home (DNS/Ad Blocking)
- **URL**: `http://adguardhome:3000` or `http://192.168.1.5:3000`
- **Auth**: Password available as `$ADGUARDHOME_PASSWORD`

### Change Detection
- **URL**: `http://changedetection:5000`
- **API Key**: Available as `$CHANGEDETECTION_API_KEY`

## Usage Examples

```bash
# Check Jellyfin sessions (note: uses IP, not container name)
curl -s -H "X-Emby-Token: $JELLYFIN_API_KEY" "http://192.168.1.2:8096/Sessions"

# List Jellyfin users
curl -s -H "X-Emby-Token: $JELLYFIN_API_KEY" "http://192.168.1.2:8096/Users"

# List Sonarr series
curl -s -H "X-Api-Key: $SONARR_API_KEY" "http://sonarr:8989/api/v3/series"

# Get Sonarr upcoming calendar
curl -s -H "X-Api-Key: $SONARR_API_KEY" "http://sonarr:8989/api/v3/calendar"

# Get Radarr movies
curl -s -H "X-Api-Key: $RADARR_API_KEY" "http://radarr:7878/api/v3/movie"

# Get Radarr queue
curl -s -H "X-Api-Key: $RADARR_API_KEY" "http://radarr:7878/api/v3/queue"

# Discover upcoming movies (Jellyseerr)
curl -s -H "X-Api-Key: $JELLYSEERR_API_KEY" "http://jellyseerr:5055/api/v1/discover/movies/upcoming"

# Discover trending content
curl -s -H "X-Api-Key: $JELLYSEERR_API_KEY" "http://jellyseerr:5055/api/v1/discover/trending"

# Search for a movie or TV show
curl -s -H "X-Api-Key: $JELLYSEERR_API_KEY" "http://jellyseerr:5055/api/v1/search?query=inception"

# Get recommendations based on a movie (TMDB ID)
curl -s -H "X-Api-Key: $JELLYSEERR_API_KEY" "http://jellyseerr:5055/api/v1/movie/27205/recommendations"
```

## Network Notes

- Services on the NixOS host (192.168.1.5) are accessible by container name via podman DNS
- Jellyfin runs on Synology NAS (192.168.1.2) - must use IP address
- qBittorrent routes through gluetun VPN container for privacy
