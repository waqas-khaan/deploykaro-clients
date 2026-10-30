ChaiChat
========

A tiny message board for the chai corner. One Python file, no libraries
to install (Python 3.10 or newer, which Ubuntu already has).

Run it:
    DATA_DIR=/some/folder python3 chaichat.py

Settings (environment variables):
    PORT       default 5050. Listens on 127.0.0.1 only.
    DATA_DIR   REQUIRED. Messages are saved in DATA_DIR/messages.json.
               The app refuses to start if it cannot write there.

Endpoints:
    GET  /               the board, as a web page
    GET  /api/messages   all messages as JSON
    POST /api/messages   add a message (form fields: name, text)

Example:
    curl -d "name=Ali" -d "text=Chai is ready" http://127.0.0.1:5050/api/messages

Notes from the developer:
  - Don't run it as root, please.
  - Messages must survive restarts and reboots.
  - We only tested it with "python3 chaichat.py" on my laptop. Good luck!
