#!/usr/bin/env python3
"""
Speechmatics Real-Time Transcription Web UI
Uses the official Speechmatics Python SDK for backend processing
"""

from flask import Flask, render_template_string, request, jsonify
from flask_sock import Sock
import asyncio
import json
import threading
import time
import uuid
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
            <small style="color: #666; font-size: 12px;">Backend will proxy to Speechmatics with X-Request-ID header</small>
        </div>

        <div class="config-section">
            <label for="language">Select Language:</label>
            <select id="language">
                <option value="ar">Arabic (ar)</option>
                <option value="en">English (en)</option>
                <option value="hi">Hindi (hi)</option>
                <option value="fa">Farsi/Persian (fa)</option>
                <option value="ur">Urdu (ur)</option>
            </select>
        </div>

        <div class="button-group">
            <button id="startBtn" onclick="startRecording()">🎤 Start Recording</button>
            <button id="stopBtn" onclick="stopRecording()" disabled>⏹ Stop Recording</button>
        </div>

        <div id="recordingIndicator" class="recording-indicator">
            🔴 RECORDING - Speak now
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
            const selectedLanguage = document.getElementById('language').value;
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

                updateStatus('Connecting to backend...', 'info');

                // Connect to BACKEND WebSocket (which will add X-Request-ID header)
                const backendWsUrl = 'ws://' + window.location.host + '/ws';
                console.log('Connecting to backend:', backendWsUrl);
                
                ws = new WebSocket(backendWsUrl);

                ws.onopen = () => {
                    updateStatus('✓ Connected to backend!', 'success');
                    
                    // Send config to backend with Speechmatics URL and language
                    console.log('Sending config with Speechmatics URL:', wsUrl, 'Language:', selectedLanguage);
                    ws.send(JSON.stringify({
                        type: 'config',
                        speechmatics_url: wsUrl,
                        language: selectedLanguage
                    }));
                    
                    // Wait a moment for backend to connect to Speechmatics
                    setTimeout(() => {
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

                            // Send binary audio to backend
                            ws.send(pcmData.buffer);
                        };

                        isRecording = true;
                        startBtn.disabled = true;
                        stopBtn.disabled = false;
                        recordingIndicator.classList.add('active');
                    }, 500);
                };

                ws.onmessage = (event) => {
                    try {
                        const data = JSON.parse(event.data);
                        console.log('Received from backend:', data);
                        
                        // Handle messages from backend proxy
                        if (data.type === 'status') {
                            updateStatus(data.message, data.status || 'info');
                        } else if (data.type === 'transcript') {
                            // Final transcript
                            console.log('Final transcript:', data.text);
                            addFinalTranscript(data.text);
                        } else if (data.type === 'partial') {
                            // Partial transcript
                            console.log('Partial transcript:', data.text);
                            updatePartialTranscript(data.text);
                        } else if (data.type === 'error') {
                            console.error('Error:', data.message);
                            updateStatus('✗ Error: ' + data.message, 'error');
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
                // Send stop message to backend
                ws.send(JSON.stringify({
                    type: 'stop'
                }));
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


def safe_send_to_client(ws_client, message_dict):
    """Safely send message to client websocket, catching errors"""
    try:
        ws_client.send(json.dumps(message_dict))
        return True
    except Exception as e:
        print(f"Warning: Failed to send to client: {e}")
        return False

async def transcribe_audio_stream(ws_client, speechmatics_url, audio_queue, language='en'):
    """
    Stream audio from browser to Speechmatics using WebSocket with X-Request-ID header
    """
    print(f"\n{'='*60}")
    print(f"Connecting to Speechmatics at: {speechmatics_url}")
    print(f"Language: {language}")
    
    try:
        # Generate unique request ID for this session
        request_id = f"{uuid.uuid4()}"
        print(f"Generated X-Request-ID: {request_id}")
        
        # Determine if we need authentication based on URL
        headers = {
            'X-Request-ID': request_id,
            'User-Agent': 'Speechmatics-WebUI/1.0',
        }
        
        # Add Bearer token only for cloud URL
        if 'eu2.rt.speechmatics.com' in speechmatics_url:
            headers['Authorization'] = 'Bearer yDCh3V7usUhH0qeKxPh3nZxQW1qVUCU4'
            print("Using cloud URL with Bearer token authentication")
        else:
            print("Using on-premise URL without authentication")
        
        print(f"Headers: {headers}")
        print(f"{'='*60}\n")
        
        async with websockets.connect(
            speechmatics_url, 
            ping_interval=None,
            open_timeout=30,
            close_timeout=30,
            additional_headers=headers
        ) as websocket:
            print("✓ WebSocket connection established!")
            
            # Send StartRecognition message
            start_message = {
                "message": "StartRecognition",
                "audio_format": {
                    "type": "raw",
                    "encoding": "pcm_s16le",
                    "sample_rate": 16000
                },
                "transcription_config": {
                    "language": language,
                    "enable_partials": True,
                    "max_delay": 0.8,
                    "operating_point": "enhanced"
                }
            }
            
            print(f"Sending StartRecognition message with language: {language}...")
            await websocket.send(json.dumps(start_message))
            
            # Send audio to Speechmatics
            async def send_audio():
                audio_chunk_count = 0
                try:
                    while True:
                        try:
                            audio_chunk = await asyncio.wait_for(
                                asyncio.get_event_loop().run_in_executor(None, audio_queue.get, True, 1.0),
                                timeout=1.0
                            )
                            if audio_chunk is None:  # Stop signal
                                print(f"Stop signal received after {audio_chunk_count} chunks")
                                break
                            audio_chunk_count += 1
                            if audio_chunk_count % 50 == 0:  # Log every 50 chunks
                                print(f"Sent {audio_chunk_count} audio chunks ({len(audio_chunk)} bytes each)")
                            await websocket.send(audio_chunk)
                        except Empty:
                            continue
                        except asyncio.TimeoutError:
                            continue
                except Exception as e:
                    print(f"Error sending audio: {e}")
                    import traceback
                    traceback.print_exc()
                finally:
                    # Send EndOfStream
                    print(f"Sending EndOfStream after {audio_chunk_count} total chunks...")
                    end_message = json.dumps({"message": "EndOfStream", "last_seq_no": audio_chunk_count})
                    await websocket.send(end_message)
            
            # Receive messages from Speechmatics
            async def receive_messages():
                message_count = 0
                try:
                    while True:
                        message = await websocket.recv()
                        message_count += 1
                        data = json.loads(message)
                        msg_type = data.get('message')
                        
                        print(f"[MSG {message_count}] Received: {msg_type}")
                        
                        if msg_type == 'RecognitionStarted':
                            print("✓ Recognition started!")
                            safe_send_to_client(ws_client, {
                                'type': 'status',
                                'message': '✓ Recognition started! Speak now...',
                                'status': 'success'
                            })
                            
                        elif msg_type == 'AddTranscript':
                            # Final transcript
                            metadata = data.get('metadata', {})
                            transcript = metadata.get('transcript', '')
                            
                            print(f"  AddTranscript - transcript from metadata: '{transcript}'")
                            print(f"  Full data: {json.dumps(data, indent=2, ensure_ascii=False)}")
                            
                            if transcript:
                                print(f"[FINAL TRANSCRIPT] {transcript}")
                                sent = safe_send_to_client(ws_client, {
                                    'type': 'transcript',
                                    'text': transcript
                                })
                                print(f"  Sent to client: {sent}")
                                        
                        elif msg_type == 'AddPartialTranscript':
                            # Partial transcript
                            metadata = data.get('metadata', {})
                            transcript = metadata.get('transcript', '')
                            
                            print(f"  AddPartialTranscript - transcript from metadata: '{transcript}'")
                            print(f"  Full data: {json.dumps(data, indent=2, ensure_ascii=False)}")
                            
                            if transcript:
                                print(f"[PARTIAL TRANSCRIPT] {transcript}")
                                sent = safe_send_to_client(ws_client, {
                                    'type': 'partial',
                                    'text': transcript
                                })
                                print(f"  Sent to client: {sent}")
                        
                        elif msg_type == 'AudioAdded':
                            # Audio was received by Speechmatics (useful for debugging)
                            seq_no = data.get('seq_no', '?')
                            if seq_no % 100 == 0:
                                print(f"  Audio chunk {seq_no} acknowledged")
                                
                        elif msg_type == 'EndOfTranscript':
                            print("✓ Transcription complete")
                            break
                            
                        elif msg_type == 'Error':
                            error_msg = data.get('reason', 'Unknown error')
                            print(f"✗ Speechmatics error: {error_msg}")
                            print(f"  Full error data: {data}")
                            safe_send_to_client(ws_client, {
                                'type': 'error',
                                'message': error_msg
                            })
                            break
                        
                        elif msg_type == 'Warning':
                            warning_msg = data.get('reason', 'Unknown warning')
                            print(f"⚠ Warning: {warning_msg}")
                            
                except Exception as e:
                    print(f"Error receiving messages: {e}")
                    import traceback
                    traceback.print_exc()
            
            # Run both tasks concurrently
            await asyncio.gather(send_audio(), receive_messages())
            
    except websockets.exceptions.InvalidStatusCode as e:
        error_msg = f"✗ WebSocket rejected: HTTP {e.status_code}"
        print(error_msg)
        safe_send_to_client(ws_client, {'type': 'error', 'message': error_msg})
            
    except Exception as e:
        error_msg = f"✗ Transcription error: {str(e)}"
        print(error_msg)
        import traceback
        traceback.print_exc()
        safe_send_to_client(ws_client, {'type': 'error', 'message': error_msg})

@sock.route('/ws')
def websocket_handler(ws):
    """WebSocket endpoint for receiving audio from browser"""
    speechmatics_url = None
    selected_language = 'en'  # Default language
    audio_queue = Queue()
    transcription_task = None
    loop = None
    message_count = 0
    audio_count = 0
    
    print("\n" + "="*60)
    print("New WebSocket connection from browser")
    print("="*60 + "\n")
    
    try:
        while True:
            message = ws.receive(timeout=None)
            if message is None:
                print("Received None message, breaking")
                break
            
            message_count += 1
                
            # Handle text messages (config and control)
            if isinstance(message, str):
                print(f"[{message_count}] Received TEXT message: {message[:100]}...")
                try:
                    data = json.loads(message)
                    
                    if data.get('type') == 'config':
                        speechmatics_url = data.get('speechmatics_url')
                        selected_language = data.get('language', 'en')
                        print(f"✓ Config received - Speechmatics URL: {speechmatics_url}")
                        print(f"✓ Selected language: {selected_language}")
                        
                        # Start transcription session in background thread
                        if speechmatics_url:
                            safe_send_to_client(ws, {
                                'type': 'status',
                                'message': f'Starting transcription session for {selected_language.upper()}...',
                                'status': 'info'
                            })
                            
                            # Run async transcription in a separate thread
                            def run_transcription():
                                nonlocal loop
                                loop = asyncio.new_event_loop()
                                asyncio.set_event_loop(loop)
                                loop.run_until_complete(
                                    transcribe_audio_stream(ws, speechmatics_url, audio_queue, selected_language)
                                )
                            
                            print("Starting transcription thread...")
                            transcription_task = threading.Thread(target=run_transcription, daemon=True)
                            transcription_task.start()
                            print("Transcription thread started")
                    
                    elif data.get('type') == 'stop':
                        print("Stop request received from browser")
                        audio_queue.put(None)
                        break
                        
                except json.JSONDecodeError as e:
                    print(f"Invalid JSON received: {e}")
            
            # Handle binary audio data (bytes or bytearray)
            elif isinstance(message, (bytes, bytearray)):
                audio_count += 1
                if audio_count == 1 or audio_count % 100 == 0:
                    print(f"[{message_count}] Received BINARY audio chunk #{audio_count}: {len(message)} bytes")
                if audio_queue is not None:
                    # Convert to bytes if it's bytearray
                    audio_data = bytes(message) if isinstance(message, bytearray) else message
                    audio_queue.put(audio_data)
            else:
                print(f"[{message_count}] Unknown message type: {type(message)}")
    
    except Exception as e:
        print(f"WebSocket error: {e}")
        import traceback
        traceback.print_exc()
        safe_send_to_client(ws, {'type': 'error', 'message': str(e)})
    finally:
        # Cleanup
        print(f"\nCleaning up WebSocket connection...")
        print(f"  Total messages received: {message_count}")
        print(f"  Total audio chunks: {audio_count}")
        if audio_queue:
            audio_queue.put(None)
        if transcription_task and transcription_task.is_alive():
            print("  Waiting for transcription thread to finish...")
            transcription_task.join(timeout=5)
        if loop:
            try:
                loop.close()
            except:
                pass
        print("WebSocket connection closed\n")

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
    print(f"  ✓ Real-time transcription")
    print(f"  ✓ Multi-language support (Arabic, English, Hindi, Farsi, Urdu)")
    print(f"  ✓ Official Speechmatics Python SDK")
    print(f"  ✓ Partial and final transcripts")
    print("=" * 60)
    app.run(host='0.0.0.0', port=30602, debug=True)

