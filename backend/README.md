# Cruisy AIS Scraper

Multi-source AIS (Automatic Identification System) data scraper for real-time cruise ship tracking.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Multi-Source AIS Scraper                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ AISStream   │  │ Digitraffic │  │BarentsWatch │              │
│  │   (Global)  │  │  (Finland)  │  │  (Norway)   │              │
│  │  WebSocket  │  │    REST     │  │ REST+OAuth  │              │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘              │
│         │                │                │                      │
│         ▼                ▼                ▼                      │
│  ┌─────────────────────────────────────────────────────┐        │
│  │              Smart Merge Logic                       │        │
│  │  - Deduplicate by MMSI                              │        │
│  │  - Only write if timestamp > 30s newer              │        │
│  │  - Prevents "jumping" ships                         │        │
│  └──────────────────────┬──────────────────────────────┘        │
│                         │                                        │
│                         ▼                                        │
│  ┌─────────────────────────────────────────────────────┐        │
│  │              Firestore: live_positions/{mmsi}        │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Sources

| Source | Coverage | Auth | Status |
|--------|----------|------|--------|
| **AISStream.io** | Global | API Key | ✅ Active |
| **Digitraffic.fi** | Finland/Baltic | None (public) | ✅ Active |
| **BarentsWatch.no** | Norway/Arctic | OAuth2 | ✅ Active |
| **US NAIS** | US Waters | Special access | ❌ Covered by AISStream |

## Setup

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Firebase Service Account

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project → Settings → Service Accounts
3. Click "Generate new private key"
4. Save as `firebase-service-account.json` in the `backend/` folder

### 3. Configure API Keys

Create a `.env` file or set environment variables:

```bash
# Required - AISStream.io (register at https://aisstream.io)
AISSTREAM_API_KEY=your_aisstream_api_key

# Optional - Barents Watch (register at https://www.barentswatch.no/)
BARENTSWATCH_CLIENT_ID=your_client_id
BARENTSWATCH_CLIENT_SECRET=your_client_secret
```

### 4. Run the Scraper

```bash
python ais_scraper.py
```

## Output

The scraper will:
1. Connect to all configured sources in parallel
2. Log status every minute showing online sources and positions received
3. Write positions to Firestore `live_positions/{mmsi}` collection

Example output:
```
2024-01-06 21:40:52 - INFO - [AIS-Scraper] Starting Cruisy Multi-Source AIS Scraper
2024-01-06 21:40:52 - INFO - [AIS-Scraper] Firebase initialized successfully
2024-01-06 21:40:52 - INFO - [AIS-Scraper] Loaded 23 ships from whitelist
2024-01-06 21:40:52 - INFO - [AIS-Scraper] Tracking 23 ships from 2 active sources
2024-01-06 21:40:52 - INFO - [AIS-Scraper] Active sources: AISStream.io, Digitraffic.fi
2024-01-06 21:40:53 - INFO - [AIS-Scraper] [AISStream.io] Connected, tracking 23 ships
2024-01-06 21:41:05 - INFO - [AIS-Scraper] [AISStream.io] Updated AIDAprima: (54.3421, 10.1234) @ 18.5kn
```

## Firestore Schema

### `ships` Collection
```json
{
  "mmsi": 211349270,
  "name": "AIDAprima",
  "company": "AIDA Cruises",
  "active": true
}
```

### `live_positions` Collection
```json
{
  "mmsi": 211349270,
  "latitude": 54.3421,
  "longitude": 10.1234,
  "speed": 18.5,
  "heading": 245.0,
  "timestamp": "2024-01-06T21:41:05Z",
  "updated_at": "<server_timestamp>",
  "ship_name": "AIDAprima",
  "company": "AIDA Cruises",
  "source": "AISStream.io"
}
```

## Smart Merge Logic

The scraper uses intelligent deduplication:

1. **Whitelist Filter**: Only ships in the `ships` collection with `active: true` are tracked
2. **Timestamp Comparison**: New positions only written if 30+ seconds newer than last write
3. **Source Agnostic**: Best (newest) data wins regardless of source
4. **Prevents Jumping**: Ships won't "teleport" due to delayed data from slower sources

## Adding New Ships

Add to Firestore `ships` collection:
```json
{
  "mmsi": 123456789,
  "name": "Ship Name",
  "company": "Cruise Line",
  "active": true
}
```

The scraper refreshes the whitelist every 5 minutes automatically.

## Running as a Service (systemd)

Create `/etc/systemd/system/cruisy-ais.service`:

```ini
[Unit]
Description=Cruisy AIS Scraper
After=network.target

[Service]
Type=simple
User=cruisy
WorkingDirectory=/opt/cruisy/backend
ExecStart=/usr/bin/python3 ais_scraper.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Then:
```bash
sudo systemctl daemon-reload
sudo systemctl enable cruisy-ais
sudo systemctl start cruisy-ais
```

## Docker Deployment

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "ais_scraper.py"]
```

Build and run:
```bash
docker build -t cruisy-ais .
docker run -d --name cruisy-ais \
  -v $(pwd)/firebase-service-account.json:/app/firebase-service-account.json \
  -e AISSTREAM_API_KEY=your_key \
  cruisy-ais
```

## Troubleshooting

### "WebSocket connection closed immediately"
- Check your AISStream.io API key is valid
- Ensure `FiltersShipMMSI` contains strings, not integers

### "No ships in whitelist"
- The `ships` collection may be empty
- First run will seed initial ships automatically

### "Source [X] offline"
- Check credentials for that source
- Some sources (BarentsWatch, AISHub) require registration
- The scraper continues with other sources
