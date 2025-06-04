# 3DModelManager

**IMPORTANT** <br>
This is an early proof of concept! Nothing about this is stable or final.

This project is designed to work with a 3D Model server. The server sends 3D models to this client via a WebSocket connection.

## Features
- WebSocket-based communication with the 3D Model server.
- Real-time model updates and rendering.

## Requirements
- Godot Engine
- WebSocket support enabled

## Usage
1. Download and start the [3DModelServer](https://github.com/hunsri/3DModelServer) 
2. Run this client to connect via WebSocket.
3. Models will be received and rendered in real-time.