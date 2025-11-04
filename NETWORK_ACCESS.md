# Accessing Verba from Other Devices

## Quick Start

### Local Access (same computer)
```bash
./start_verba.sh
```
Then open: **http://localhost:5173**

### Network Access (from other devices)
```bash
./start_verba_network.sh
```
Then from any device on the same WiFi/network, open: **http://192.168.100.69:5173**

## Your Network Details

- **Your Computer IP**: `192.168.100.69`
- **Frontend URL**: `http://192.168.100.69:5173`
- **Backend API**: `http://192.168.100.69:8000`

## Accessing from Other Devices

### From Phone/Tablet (Same WiFi)
1. Make sure your device is on the **same WiFi network** as your computer
2. Start Verba with network access: `./start_verba_network.sh`
3. Open browser on your phone/tablet
4. Go to: `http://192.168.100.69:5173`

### From Another Computer (Same Network)
1. Start Verba with network access: `./start_verba_network.sh`
2. On the other computer, open browser
3. Go to: `http://192.168.100.69:5173`

## Troubleshooting

### Can't Connect from Other Devices?

#### 1. Check Firewall (Most Common Issue)
Fedora's firewall might be blocking the ports. Open them temporarily:

```bash
# Open ports for this session
sudo firewall-cmd --add-port=5173/tcp --add-port=8000/tcp

# Or make it permanent
sudo firewall-cmd --add-port=5173/tcp --add-port=8000/tcp --permanent
sudo firewall-cmd --reload
```

#### 2. Verify Network Connection
Make sure both devices are on the **same WiFi network** (not guest network).

```bash
# Check your IP address
hostname -I
```

#### 3. Test Backend API
From another device, try accessing:
```
http://192.168.100.69:8000/api/status
```
You should see JSON with status information.

#### 4. Check Verba is Running
```bash
# Check if processes are running
ps aux | grep -E "(python app.py|vite)"

# Check logs
tail -f verba-backend.log
tail -f verba-frontend.log
```

## Security Notes

⚠️ **Important**: Network access is configured for **local network only** (development mode).

- Only works on your local WiFi/LAN (192.168.x.x, 10.x.x.x)
- Not accessible from the internet
- CORS is configured to allow local network IPs only
- **Do NOT expose** ports 5173/8000 to the internet without proper security

## Audio Recording on Mobile Devices

📱 **Note**: System audio recording only works on the host computer (where Verba is running).

- **On your computer**: Both "System Audio" and "Microphone" options work
- **On phone/tablet**: Only "Microphone" option will work (system audio capture not supported by browsers on mobile)

## Stopping Network Access

```bash
./stop_verba.sh
```

This stops both local and network access.

## Advanced: Custom Port Configuration

If you need to use different ports:

1. Edit `backend/app.py` - change port in `uvicorn.run()`
2. Edit `start_verba_network.sh` - update port numbers
3. Update firewall rules with new ports
4. Access via: `http://192.168.100.69:YOUR_PORT`
