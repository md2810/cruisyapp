#!/usr/bin/env python3
"""
Multi-Source AIS Scraper for Cruisy App
Connects to multiple AIS data sources and stores ship positions in memory.
Includes a web dashboard at http://localhost:5000

Sources:
    - AISStream.io (Global WebSocket)
    - Barents Watch (Norwegian waters)
    - Digitraffic (Finnish waters)

Usage:
    python ais_scraper.py

Environment Variables:
    AISSTREAM_API_KEY - API key for aisstream.io
    BARENTSWATCH_CLIENT_ID - Barents Watch API client ID
    BARENTSWATCH_CLIENT_SECRET - Barents Watch API client secret
"""

import asyncio
import json
import logging
import os
import signal
import sys
import threading
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional

import aiohttp
import websockets
from flask import Flask, jsonify, render_template_string

# Configure logging (console only for memory efficiency)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger('AIS')

# Suppress Flask/Werkzeug logging
logging.getLogger('werkzeug').setLevel(logging.WARNING)

# ============================================================================
# Configuration
# ============================================================================

AISSTREAM_API_KEY = os.getenv('AISSTREAM_API_KEY', 'd660dcfe78606d61b7214fb0926ad767c2c9cd9a')

# Barents Watch (Norway)
BARENTSWATCH_CLIENT_ID = os.getenv('BARENTSWATCH_CLIENT_ID', 'marco.duzevic@icloud.com:Cruisy')
BARENTSWATCH_CLIENT_SECRET = os.getenv('BARENTSWATCH_CLIENT_SECRET', "Q3h3I[1J';U$")

# Dashboard port
DASHBOARD_PORT = int(os.getenv('DASHBOARD_PORT', '5000'))

# Minimum time between updates for same ship (seconds)
MIN_UPDATE_INTERVAL = 30

# Polling interval for REST APIs (seconds)
REST_POLL_INTERVAL = 60

# Memory limits
MAX_SHIPS = 500  # Maximum ships to keep in memory
MAX_AGE_MINUTES = 30  # Remove ships not updated in this time

# ============================================================================
# Data Classes
# ============================================================================

@dataclass
class ShipPosition:
    """Standardized ship position data from any source."""
    mmsi: str
    latitude: float
    longitude: float
    speed: float
    heading: float
    timestamp: datetime
    source: str
    ship_name: Optional[str] = None
    company: Optional[str] = None


@dataclass
class SourceStatus:
    """Status tracking for each data source."""
    name: str
    online: bool = False
    last_success: Optional[datetime] = None
    error_count: int = 0
    positions_received: int = 0


# ============================================================================
# Global State
# ============================================================================

last_updates: dict = {}  # MMSI -> last update timestamp
live_positions: dict = {}  # MMSI -> position data (in-memory storage)
source_status: dict = {}
running = True


# ============================================================================
# Smart Merge Logic
# ============================================================================

def should_update_position(position: ShipPosition) -> bool:
    """Check if enough time has passed since last update for this ship."""
    last_update = last_updates.get(position.mmsi)
    if last_update is None:
        # Don't add new ships if at capacity
        if len(live_positions) >= MAX_SHIPS:
            return False
        return True
    time_diff = (position.timestamp - last_update).total_seconds()
    return time_diff >= MIN_UPDATE_INTERVAL


def update_ship_position(position: ShipPosition):
    """Update ship position in memory if enough time has passed."""
    if not should_update_position(position):
        return False

    live_positions[position.mmsi] = (
        position.latitude,
        position.longitude,
        position.speed,
        position.heading,
        position.timestamp,
        position.ship_name,
        position.source
    )
    last_updates[position.mmsi] = position.timestamp
    # Only log occasionally to reduce spam
    if len(live_positions) % 50 == 0:
        logger.info(f"Tracking {len(live_positions)} ships")
    return True


def cleanup_old_positions():
    """Remove ships not updated recently."""
    now = datetime.now(timezone.utc)
    cutoff = MAX_AGE_MINUTES * 60
    to_remove = [
        mmsi for mmsi, ts in last_updates.items()
        if (now - ts).total_seconds() > cutoff
    ]
    for mmsi in to_remove:
        live_positions.pop(mmsi, None)
        last_updates.pop(mmsi, None)
    if to_remove:
        logger.info(f"Cleaned up {len(to_remove)} stale ships, {len(live_positions)} remaining")


# ============================================================================
# Base Collector Class
# ============================================================================

class AISCollector(ABC):
    def __init__(self, name: str):
        self.name = name
        self.status = SourceStatus(name=name)
        source_status[name] = self.status

    @abstractmethod
    async def connect(self):
        pass

    def mark_online(self):
        self.status.online = True
        self.status.last_success = datetime.now(timezone.utc)
        self.status.error_count = 0

    def mark_offline(self, error: str = None):
        self.status.online = False
        self.status.error_count += 1
        if error:
            logger.warning(f"Source [{self.name}] offline - {error}")

    def record_position(self):
        self.status.positions_received += 1


# ============================================================================
# Source A: AISStream.io
# ============================================================================

class AISStreamCollector(AISCollector):
    URL = 'wss://stream.aisstream.io/v0/stream'

    def __init__(self):
        super().__init__('AISStream.io')
        self.api_key = AISSTREAM_API_KEY

    async def connect(self):
        if not self.api_key:
            self.mark_offline("No API key")
            return

        # Track all ships globally (no MMSI filter)
        subscription = {
            "APIKey": self.api_key,
            "BoundingBoxes": [[[-90, -180], [90, 180]]],
            "FilterMessageTypes": ["PositionReport"]
        }

        try:
            async with websockets.connect(self.URL) as ws:
                await ws.send(json.dumps(subscription))
                self.mark_online()
                logger.info(f"[{self.name}] Connected, tracking all ships globally")

                async for message_json in ws:
                    if not running:
                        break
                    try:
                        message = json.loads(message_json)
                        position = self._parse_message(message)
                        if position:
                            self.record_position()
                            update_ship_position(position)
                    except Exception as e:
                        logger.error(f"[{self.name}] Parse error: {e}")

        except websockets.ConnectionClosed as e:
            self.mark_offline(f"Closed: {e.code}")
        except Exception as e:
            self.mark_offline(str(e))

        await asyncio.sleep(5)

    def _parse_message(self, message: dict) -> Optional[ShipPosition]:
        if message.get('MessageType') != 'PositionReport':
            return None
        pos = message.get('Message', {}).get('PositionReport', {})
        meta = message.get('MetaData', {})
        mmsi = str(pos.get('UserID', ''))
        if not mmsi:
            return None
        lat, lon = pos.get('Latitude'), pos.get('Longitude')
        if lat is None or lon is None:
            return None
        heading = pos.get('TrueHeading', 511)
        if heading == 511:
            heading = pos.get('Cog', 0)
        time_str = meta.get('time_utc', '')
        try:
            timestamp = datetime.fromisoformat(time_str.replace('Z', '+00:00'))
        except:
            timestamp = datetime.now(timezone.utc)
        ship_name = meta.get('ShipName', '').strip() or None
        return ShipPosition(mmsi=mmsi, latitude=lat, longitude=lon, speed=pos.get('Sog', 0),
                           heading=heading, timestamp=timestamp, source=self.name, ship_name=ship_name)


# ============================================================================
# Source B: Digitraffic (Finland)
# ============================================================================

class DigitrafficCollector(AISCollector):
    URL = 'https://meri.digitraffic.fi/api/ais/v1/locations'

    def __init__(self):
        super().__init__('Digitraffic.fi')

    async def connect(self):
        async with aiohttp.ClientSession() as session:
            while running:
                try:
                    async with session.get(self.URL, timeout=aiohttp.ClientTimeout(total=30)) as resp:
                        if resp.status == 200:
                            data = await resp.json()
                            self.mark_online()
                            for feature in data.get('features', []):
                                position = self._parse_feature(feature)
                                if position:
                                    self.record_position()
                                    update_ship_position(position)
                        else:
                            self.mark_offline(f"HTTP {resp.status}")
                except asyncio.TimeoutError:
                    self.mark_offline("Timeout")
                except Exception as e:
                    self.mark_offline(str(e))
                await asyncio.sleep(REST_POLL_INTERVAL)

    def _parse_feature(self, feature: dict) -> Optional[ShipPosition]:
        try:
            props = feature.get('properties', {})
            coords = feature.get('geometry', {}).get('coordinates', [])
            if len(coords) < 2:
                return None
            mmsi = str(props.get('mmsi', ''))
            if not mmsi:
                return None
            timestamp = datetime.fromtimestamp(props.get('timestampExternal', 0) / 1000, tz=timezone.utc)
            return ShipPosition(mmsi=mmsi, latitude=coords[1], longitude=coords[0],
                               speed=props.get('sog', 0) / 10.0, heading=props.get('heading', 0) / 10.0,
                               timestamp=timestamp, source=self.name)
        except:
            return None


# ============================================================================
# Source C: Barents Watch (Norway)
# ============================================================================

class BarentsWatchCollector(AISCollector):
    TOKEN_URL = 'https://id.barentswatch.no/connect/token'
    AIS_URL = 'https://www.barentswatch.no/bwapi/v2/geodata/ais/openpositions'

    def __init__(self):
        super().__init__('BarentsWatch.no')
        self.client_id = BARENTSWATCH_CLIENT_ID
        self.client_secret = BARENTSWATCH_CLIENT_SECRET
        self.access_token = None
        self.token_expires = None

    async def _get_token(self, session):
        if not self.client_id or not self.client_secret:
            return False
        try:
            data = {'grant_type': 'client_credentials', 'client_id': self.client_id,
                    'client_secret': self.client_secret, 'scope': 'api'}
            async with session.post(self.TOKEN_URL, data=data) as resp:
                if resp.status == 200:
                    token_data = await resp.json()
                    self.access_token = token_data.get('access_token')
                    self.token_expires = datetime.now(timezone.utc).timestamp() + token_data.get('expires_in', 3600) - 60
                    return True
            return False
        except:
            return False

    async def connect(self):
        if not self.client_id or not self.client_secret:
            self.mark_offline("No credentials")
            return

        async with aiohttp.ClientSession() as session:
            while running:
                try:
                    if not self.access_token or datetime.now(timezone.utc).timestamp() > self.token_expires:
                        if not await self._get_token(session):
                            self.mark_offline("Auth failed")
                            await asyncio.sleep(300)
                            continue

                    headers = {'Authorization': f'Bearer {self.access_token}'}
                    async with session.get(self.AIS_URL, headers=headers, timeout=aiohttp.ClientTimeout(total=30)) as resp:
                        if resp.status == 200:
                            data = await resp.json()
                            self.mark_online()
                            for item in data:
                                position = self._parse_item(item)
                                if position:
                                    self.record_position()
                                    update_ship_position(position)
                        elif resp.status == 401:
                            self.access_token = None
                        else:
                            self.mark_offline(f"HTTP {resp.status}")
                except asyncio.TimeoutError:
                    self.mark_offline("Timeout")
                except Exception as e:
                    self.mark_offline(str(e))
                await asyncio.sleep(REST_POLL_INTERVAL)

    def _parse_item(self, item: dict) -> Optional[ShipPosition]:
        try:
            mmsi = str(item.get('mmsi', ''))
            if not mmsi:
                return None
            time_str = item.get('timeStamp', '')
            try:
                timestamp = datetime.fromisoformat(time_str.replace('Z', '+00:00'))
            except:
                timestamp = datetime.now(timezone.utc)
            return ShipPosition(mmsi=mmsi, latitude=item.get('latitude', 0), longitude=item.get('longitude', 0),
                               speed=item.get('speedOverGround', 0), heading=item.get('trueHeading', 0),
                               timestamp=timestamp, source=self.name, ship_name=item.get('name'))
        except:
            return None


# ============================================================================
# Flask Dashboard
# ============================================================================

app = Flask(__name__)

DASHBOARD_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Cruisy AIS Dashboard</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: monospace; background: #1a1a2e; color: #eee; }
        #header { background: #16213e; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #0f3460; }
        #header h1 { font-size: 16px; color: #00d4ff; }
        #stats { display: flex; gap: 15px; font-size: 12px; }
        .stat { background: #0f3460; padding: 5px 10px; border-radius: 4px; }
        .stat-value { color: #00d4ff; font-weight: bold; }
        #map { height: calc(100vh - 45px - 180px); }
        #sidebar { height: 180px; background: #16213e; overflow-y: auto; padding: 10px; font-size: 11px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 5px 8px; text-align: left; border-bottom: 1px solid #0f3460; }
        th { background: #0f3460; color: #00d4ff; position: sticky; top: 0; }
        tr:hover { background: #0f3460; cursor: pointer; }
        .online { color: #00ff88; }
        .stale { color: #ffa500; }
        .offline { color: #ff6b6b; }
        .speed { color: #00d4ff; }
        .src { opacity: 0.6; font-size: 10px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>CRUISY AIS DASHBOARD</h1>
        <div id="stats">
            <div class="stat">Tracked: <span class="stat-value" id="total-ships">-</span></div>
            <div class="stat">Live: <span class="stat-value" id="live-count">-</span></div>
            <div class="stat">Sources: <span class="stat-value" id="sources">-</span></div>
            <div class="stat">Updated: <span class="stat-value" id="last-update">-</span></div>
        </div>
    </div>
    <div id="map"></div>
    <div id="sidebar">
        <table><thead><tr><th>Ship</th><th>Position</th><th>Speed</th><th>Source</th><th>Age</th></tr></thead>
        <tbody id="ship-table"></tbody></table>
    </div>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        const map = L.map('map').setView([54, 10], 5);
        L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; OSM, CARTO'
        }).addTo(map);
        const markers = {};
        const shipIcon = L.divIcon({className:'ship-marker',html:'<div style="color:#00d4ff;font-size:18px;text-shadow:0 0 3px #000;">⛴</div>',iconSize:[18,18],iconAnchor:[9,9]});

        function formatAge(ts) {
            if (!ts) return '-';
            const diff = (Date.now() - new Date(ts).getTime()) / 60000;
            if (diff < 1) return '<span class="online">LIVE</span>';
            if (diff < 10) return '<span class="online">' + Math.floor(diff) + 'm</span>';
            if (diff < 60) return '<span class="stale">' + Math.floor(diff) + 'm</span>';
            return '<span class="offline">' + Math.floor(diff/60) + 'h</span>';
        }

        function refresh() {
            fetch('/api/status').then(r => r.json()).then(data => {
                document.getElementById('total-ships').textContent = data.total_ships || 0;
                document.getElementById('live-count').textContent = data.live_count || 0;
                document.getElementById('sources').textContent = (data.sources_online||[]).join(', ') || 'None';
                document.getElementById('last-update').textContent = new Date().toLocaleTimeString();

                const ships = data.positions || [];
                document.getElementById('ship-table').innerHTML = ships.map(s =>
                    `<tr onclick="map.setView([${s.lat},${s.lon}],10)">
                        <td>${s.name||'?'}</td>
                        <td>${s.lat?.toFixed(2)}, ${s.lon?.toFixed(2)}</td>
                        <td class="speed">${s.speed?.toFixed(1)||0} kn</td>
                        <td class="src">${s.source||'-'}</td>
                        <td>${formatAge(s.timestamp)}</td>
                    </tr>`).join('');

                ships.forEach(s => {
                    if (!s.lat || !s.lon) return;
                    if (markers[s.mmsi]) {
                        markers[s.mmsi].setLatLng([s.lat, s.lon]);
                    } else {
                        markers[s.mmsi] = L.marker([s.lat, s.lon], {icon: shipIcon})
                            .addTo(map).bindPopup(`<b>${s.name||'?'}</b><br>MMSI: ${s.mmsi}<br>${s.speed?.toFixed(1)||0} kn`);
                    }
                });
            }).catch(e => console.error(e));
        }
        refresh();
        setInterval(refresh, 15000);
    </script>
</body>
</html>
"""

@app.route('/')
def dashboard():
    return render_template_string(DASHBOARD_HTML)

@app.route('/api/status')
def api_status():
    try:
        positions = []
        live_count = 0
        now = datetime.now(timezone.utc)

        # Tuple format: (lat, lon, speed, heading, timestamp, ship_name, source)
        for mmsi, data in live_positions.items():
            lat, lon, speed, heading, ts, name, source = data
            age = (now - ts).total_seconds() / 60
            if age < 10:
                live_count += 1
            positions.append({
                'mmsi': mmsi,
                'name': name,
                'lat': lat,
                'lon': lon,
                'speed': speed,
                'source': source,
                'timestamp': ts.isoformat()
            })

        return jsonify({
            'total_ships': len(positions),
            'live_count': live_count,
            'positions': positions,
            'sources_online': [s.name for s in source_status.values() if s.online],
            'sources_offline': [s.name for s in source_status.values() if not s.online],
            'total_received': sum(s.positions_received for s in source_status.values())
        })
    except Exception as e:
        return jsonify({'error': str(e)})


def run_dashboard():
    """Run Flask in a separate thread."""
    app.run(host='0.0.0.0', port=DASHBOARD_PORT, debug=False, use_reloader=False, threaded=True)


# ============================================================================
# Main Loop
# ============================================================================

async def run_collectors():
    collectors = [AISStreamCollector(), DigitrafficCollector(), BarentsWatchCollector()]
    active = [c.name for c in collectors if not (c.name == 'BarentsWatch.no' and not BARENTSWATCH_CLIENT_ID)]
    logger.info(f"Starting {len(active)} sources: {', '.join(active)}")
    tasks = [asyncio.create_task(collector_loop(c)) for c in collectors]
    try:
        await asyncio.gather(*tasks)
    except asyncio.CancelledError:
        pass


async def collector_loop(collector):
    while running:
        try:
            await collector.connect()
        except Exception as e:
            logger.error(f"[{collector.name}] Error: {e}")
            await asyncio.sleep(10)


async def log_status_periodically():
    while running:
        await asyncio.sleep(60)
        cleanup_old_positions()
        online = [s.name for s in source_status.values() if s.online]
        total = sum(s.positions_received for s in source_status.values())
        logger.info(f"Status: {len(online)} sources, {len(live_positions)} ships, {total} total received")


async def main():
    global running

    logger.info("=" * 60)
    logger.info("Cruisy Multi-Source AIS Scraper (In-Memory Mode)")
    logger.info(f"Dashboard: http://localhost:{DASHBOARD_PORT}")
    logger.info("=" * 60)

    # Start Flask dashboard in background thread
    dashboard_thread = threading.Thread(target=run_dashboard, daemon=True)
    dashboard_thread.start()
    logger.info(f"Dashboard started at http://localhost:{DASHBOARD_PORT}")

    try:
        await asyncio.gather(
            run_collectors(),
            log_status_periodically()
        )
    except asyncio.CancelledError:
        pass


def signal_handler(signum, frame):
    global running
    logger.info("Shutdown signal received...")
    running = False


if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Interrupted")
    finally:
        logger.info("Stopped")
