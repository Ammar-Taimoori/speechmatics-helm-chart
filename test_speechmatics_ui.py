#!/usr/bin/env python3
"""
Speechmatics Real-Time Transcription Web UI
Uses the official Speechmatics Python SDK for backend processing
"""

from flask import Flask, render_template_string, request, jsonify
from flask_sock import Sock
import asyncio
import json
import base64
import threading
from queue import Queue, Empty
import websockets

app = Flask(__name__)
sock = Sock(app)

# Configuration for on-premise deployment
SPEECHMATICS_URL = None  # Will be set from client request

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Speechmatics Real-Time Transcription</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .config-section {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"], select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 14px;
        }
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        button {
            flex: 1;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        #startBtn {
            background-color: #4CAF50;
        }
        #startBtn:hover {
            background-color: #45a049;
        }
        #stopBtn {
            background-color: #f44336;
        }
        #stopBtn:hover {
            background-color: #da190b;
        }
        button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }
        .recording-indicator {
            display: none;
            text-align: center;
            margin-top: 20px;
            padding: 15px;
            background-color: #ffebee;
            border-radius: 5px;
            color: #c62828;
            font-weight: bold;
            animation: pulse 1.5s infinite;
        }
        .recording-indicator.active {
            display: block;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .status {
            margin-top: 20px;
            padding: 15px;
            border-radius: 5px;
            font-weight: bold;
        }
        .status.info {
            background-color: #e3f2fd;
            color: #1976d2;
        }
        .status.success {
            background-color: #e8f5e9;
            color: #388e3c;
        }
        .status.error {
            background-color: #ffebee;
            color: #c62828;
        }
        .transcript {
            margin-top: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-left: 4px solid #4CAF50;
            border-radius: 5px;
            min-height: 100px;
            white-space: pre-wrap;
            word-wrap: break-word;
            max-height: 400px;
            overflow-y: auto;
            font-size: 16px;
            line-height: 1.6;
        }
        .partial-transcript {
            color: #666;
            font-style: italic;
        }
        .final-transcript {
            color: #000;
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎤 Speechmatics Live Transcription</h1>
        
        <div class="config-section">
            <label for="wsUrl">Speechmatics URL:</label>
            <input type="text" id="wsUrl" value="ws://172.29.128.32:30605/v1" placeholder="ws://your-proxy:port/v1">
            <small style="color: #666; font-size: 12px;">Browser connects directly to Speechmatics (no backend proxy)</small>
        </div>

        <div class="button-group">
            <button id="startBtn" onclick="startRecording()">🎤 Start Recording</button>
            <button id="stopBtn" onclick="stopRecording()" disabled>⏹ Stop Recording</button>
        </div>

        <div id="recordingIndicator" class="recording-indicator">
            🔴 RECORDING - Speak in Arabic
        </div>

        <div id="status" class="status hidden"></div>
        
        <div id="transcriptContainer" class="hidden">
            <h3>Live Transcript:</h3>
            <div id="transcript" class="transcript"></div>
        </div>
    </div>

    <script>
        let ws = null;
        let mediaRecorder = null;
        let audioContext = null;
        let isRecording = false;
        let finalTranscript = '';
        let partialTranscript = '';

        function updateStatus(message, type = 'info') {
            const statusDiv = document.getElementById('status');
            statusDiv.textContent = message;
            statusDiv.className = 'status ' + type;
            statusDiv.classList.remove('hidden');
        }

        function updateTranscript() {
            const transcriptDiv = document.getElementById('transcript');
            const transcriptContainer = document.getElementById('transcriptContainer');
            transcriptContainer.classList.remove('hidden');
            
            let html = '<span class="final-transcript">' + finalTranscript + '</span>';
            if (partialTranscript) {
                html += '<span class="partial-transcript"> ' + partialTranscript + '</span>';
            }
            
            transcriptDiv.innerHTML = html;
            transcriptDiv.scrollTop = transcriptDiv.scrollHeight;
        }

        function addFinalTranscript(text) {
            if (text) {
                finalTranscript += (finalTranscript ? ' ' : '') + text;
                partialTranscript = '';
                updateTranscript();
            }
        }

        function updatePartialTranscript(text) {
            partialTranscript = text;
            updateTranscript();
        }

        async function startRecording() {
            const wsUrl = document.getElementById('wsUrl').value;
            const startBtn = document.getElementById('startBtn');
            const stopBtn = document.getElementById('stopBtn');
            const recordingIndicator = document.getElementById('recordingIndicator');

            try {
                finalTranscript = '';
                partialTranscript = '';
                document.getElementById('transcript').textContent = '';

                updateStatus('Requesting microphone access...', 'info');
                const stream = await navigator.mediaDevices.getUserMedia({ 
                    audio: {
                        channelCount: 1,
                        sampleRate: 16000,
                        echoCancellation: true,
                        noiseSuppression: true,
                    } 
                });

                updateStatus('Connecting to Speechmatics...', 'info');

                // Connect DIRECTLY to Speechmatics (browser to proxy)
                ws = new WebSocket(wsUrl);

                ws.onopen = () => {
                    updateStatus('✓ Connected! Sending configuration...', 'success');
                    
                    // Send StartRecognition message
                    const startMessage = {
                        message: 'StartRecognition',
                        audio_format: {
                            type: 'raw',
                            encoding: 'pcm_s16le',
                            sample_rate: 16000
                        },
                        transcription_config: {
                            language: 'ar',
                            enable_partials: true,
                            max_delay: 0.8
                        }
                    };
                    
                    console.log('Sending StartRecognition:', JSON.stringify(startMessage, null, 2));
                    ws.send(JSON.stringify(startMessage));

                    // Setup audio capture and streaming
                    audioContext = new AudioContext({ sampleRate: 16000 });
                    const source = audioContext.createMediaStreamSource(stream);
                    const processor = audioContext.createScriptProcessor(4096, 1, 1);

                    source.connect(processor);
                    processor.connect(audioContext.destination);

                    processor.onaudioprocess = (e) => {
                        if (!isRecording || ws.readyState !== WebSocket.OPEN) return;

                        const inputData = e.inputBuffer.getChannelData(0);
                        const pcmData = new Int16Array(inputData.length);
                        
                        for (let i = 0; i < inputData.length; i++) {
                            const s = Math.max(-1, Math.min(1, inputData[i]));
                            pcmData[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
                        }

                        ws.send(pcmData.buffer);
                    };

                    isRecording = true;
                    startBtn.disabled = true;
                    stopBtn.disabled = false;
                    recordingIndicator.classList.add('active');
                };

                ws.onmessage = (event) => {
                    try {
                        const data = JSON.parse(event.data);
                        console.log('Received:', data.message, data);
                        
                        if (data.message === 'RecognitionStarted') {
                            updateStatus('✓ Recognition started! Speak now...', 'success');
                        } else if (data.message === 'AddTranscript') {
                            // Final transcript
                            const results = data.results || [];
                            for (const result of results) {
                                if (result.type === 'transcript') {
                                    const alternatives = result.alternatives || [];
                                    if (alternatives.length > 0) {
                                        const text = alternatives[0].content;
                                        console.log('Final transcript:', text);
                                        addFinalTranscript(text);
                                    }
                                }
                            }
                        } else if (data.message === 'AddPartialTranscript') {
                            // Partial transcript
                            const results = data.results || [];
                            let partialText = '';
                            for (const result of results) {
                                if (result.type === 'transcript') {
                                    const alternatives = result.alternatives || [];
                                    if (alternatives.length > 0) {
                                        partialText += alternatives[0].content + ' ';
                                    }
                                }
                            }
                            if (partialText) {
                                console.log('Partial transcript:', partialText);
                                updatePartialTranscript(partialText.trim());
                            }
                        } else if (data.message === 'EndOfTranscript') {
                            console.log('End of transcript');
                            updateStatus('✓ Transcription complete', 'success');
                        } else if (data.message === 'Error') {
                            console.error('Error:', data.type, data.reason);
                            updateStatus('✗ Error: ' + data.reason, 'error');
                            stopRecording();
                        }
                    } catch (error) {
                        console.error('Error parsing message:', error, event.data);
                    }
                };

                ws.onerror = (error) => {
                    console.error('WebSocket error:', error);
                    updateStatus('✗ Connection error', 'error');
                    stopRecording();
                };

                ws.onclose = () => {
                    updateStatus('Connection closed', 'info');
                    stopRecording();
                };

            } catch (error) {
                updateStatus('✗ Error: ' + error.message, 'error');
                startBtn.disabled = false;
                stopBtn.disabled = true;
            }
        }

        function stopRecording() {
            const startBtn = document.getElementById('startBtn');
            const stopBtn = document.getElementById('stopBtn');
            const recordingIndicator = document.getElementById('recordingIndicator');

            isRecording = false;

            if (ws && ws.readyState === WebSocket.OPEN) {
                // Send EndOfStream message
                const endMessage = {
                    message: 'EndOfStream',
                    last_seq_no: 0
                };
                ws.send(JSON.stringify(endMessage));
                ws.close();
            }

            if (audioContext) {
                audioContext.close();
                audioContext = null;
            }

            startBtn.disabled = false;
            stopBtn.disabled = true;
            recordingIndicator.classList.remove('active');
            
            updateStatus('Recording stopped', 'info');
        }
    </script>
</body>
</html>
"""


async def transcribe_audio_stream(ws_client, speechmatics_url, audio_queue):
    """
    Stream audio from browser to Speechmatics using direct WebSocket connection
    """
    print(f"Connecting to Speechmatics at: {speechmatics_url}")
    
    try:
        # Add headers to avoid proxy rejection
        extra_headers = {
            'User-Agent': 'Mozilla/5.0',
        }
        
        print(f"Attempting connection with headers: {extra_headers}")
        async with websockets.connect(
            speechmatics_url, 
            ping_interval=None,
            extra_headers=extra_headers
        ) as websocket:
            print("WebSocket connection established successfully!")
            # Send StartRecognition message
            start_message = {
                "message": "StartRecognition",
                "audio_format": {
                    "type": "raw",
                    "encoding": "pcm_s16le",
                    "sample_rate": 16000
                },
                "transcription_config": {
                    "language": "ar",
                    "enable_partials": True,
                    "max_delay": 0.8
                }
            }
            
            print(f"Sending StartRecognition: {json.dumps(start_message)}")
            await websocket.send(json.dumps(start_message))
            
            # Create tasks for sending audio and receiving messages
            async def send_audio():
                try:
                    while True:
                        audio_chunk = await asyncio.wait_for(audio_queue.get(), timeout=1.0)
                        if audio_chunk is None:  # Stop signal
                            break
                        await websocket.send(audio_chunk)
                except asyncio.TimeoutError:
                    pass
                except Exception as e:
                    print(f"Error sending audio: {e}")
                finally:
                    # Send EndOfStream
                    end_message = json.dumps({"message": "EndOfStream", "last_seq_no": 0})
                    await websocket.send(end_message)
            
            async def receive_messages():
                try:
                    while True:
                        message = await websocket.recv()
                        data = json.loads(message)
                        
                        print(f"Received: {data.get('message')}")
                        
                        if data.get('message') == 'RecognitionStarted':
                            ws_client.send(json.dumps({
                                'type': 'status',
                                'message': '✓ Recognition started! Speak now...',
                                'status': 'success'
                            }))
                        elif data.get('message') == 'AddTranscript':
                            # Final transcript
                            results = data.get('results', [])
                            for result in results:
                                if result.get('type') == 'transcript':
                                    alternatives = result.get('alternatives', [])
                                    if alternatives:
                                        text = alternatives[0].get('content', '')
                                        ws_client.send(json.dumps({
                                            'type': 'transcript',
                                            'text': text
                                        }))
                        elif data.get('message') == 'AddPartialTranscript':
                            # Partial transcript
                            results = data.get('results', [])
                            partial_text = ''
                            for result in results:
                                if result.get('type') == 'transcript':
                                    alternatives = result.get('alternatives', [])
                                    if alternatives:
                                        partial_text += alternatives[0].get('content', '') + ' '
                            if partial_text:
                                ws_client.send(json.dumps({
                                    'type': 'partial',
                                    'text': partial_text.strip()
                                }))
                        elif data.get('message') == 'EndOfTranscript':
                            break
                        elif data.get('message') == 'Error':
                            error_msg = data.get('reason', 'Unknown error')
                            print(f"Speechmatics error: {error_msg}")
                            ws_client.send(json.dumps({
                                'type': 'error',
                                'message': error_msg
                            }))
                            break
                except Exception as e:
                    print(f"Error receiving messages: {e}")
            
            # Run both tasks concurrently
            await asyncio.gather(send_audio(), receive_messages())
            
    except websockets.exceptions.InvalidStatusCode as e:
        error_msg = f"WebSocket connection rejected: HTTP {e.status_code}"
        print(f"{error_msg} - {e}")
        try:
            ws_client.send(json.dumps({
                'type': 'error',
                'message': error_msg
            }))
        except:
            pass
    except Exception as e:
        error_msg = f"Transcription error: {str(e)}"
        print(error_msg)
        import traceback
        traceback.print_exc()
        try:
            ws_client.send(json.dumps({
                'type': 'error',
                'message': error_msg
            }))
        except:
            pass

@sock.route('/ws')
def websocket_handler(ws):
    """
    WebSocket endpoint for receiving audio from browser and streaming to Speechmatics
    """
    speechmatics_url = None
    audio_queue = Queue()
    transcription_task = None
    loop = None
    
    try:
        while True:
            message = ws.receive()
            if message is None:
                break
                
            # Handle text messages (config and control)
            if isinstance(message, str):
                try:
                    data = json.loads(message)
                    
                    if data.get('type') == 'config':
                        speechmatics_url = data.get('speechmatics_url')
                        
                        # Start transcription session in background thread
                        if speechmatics_url:
                            ws.send(json.dumps({
                                'type': 'status',
                                'message': 'Starting transcription session...',
                                'status': 'info'
                            }))
                            
                            # Run async transcription in a separate thread
                            def run_transcription():
                                nonlocal loop
                                loop = asyncio.new_event_loop()
                                asyncio.set_event_loop(loop)
                                loop.run_until_complete(
                                    transcribe_audio_stream(ws, speechmatics_url, audio_queue)
                                )
                            
                            transcription_task = threading.Thread(target=run_transcription)
                            transcription_task.start()
                    
                    elif data.get('type') == 'stop':
                        # Send stop signal to transcription
                        audio_queue.put(None)
                        break
                        
                except json.JSONDecodeError:
                    pass
            
            # Handle binary audio data
            elif isinstance(message, bytes):
                if audio_queue is not None:
                    audio_queue.put(message)
    
    except Exception as e:
        print(f"WebSocket error: {e}")
        try:
            ws.send(json.dumps({
                'type': 'error',
                'message': str(e)
            }))
        except:
            pass
    finally:
        # Cleanup
        if audio_queue:
            audio_queue.put(None)
        if transcription_task and transcription_task.is_alive():
            transcription_task.join(timeout=5)
        if loop:
            try:
                loop.close()
            except:
                pass

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

if __name__ == '__main__':
    print("=" * 60)
    print("🎤 Speechmatics Real-Time Transcription Web UI (SDK)")
    print("=" * 60)
    print(f"Starting server on http://0.0.0.0:30602")
    print(f"Access the UI at: http://localhost:30602")
    print(f"")
    print(f"Features:")
    print(f"  ✓ Live microphone recording")
    print(f"  ✓ Real-time transcription (Arabic only)")
    print(f"  ✓ Official Speechmatics Python SDK")
    print(f"  ✓ Partial and final transcripts")
    print("=" * 60)
    app.run(host='0.0.0.0', port=30602, debug=True)

