# ISL Gloss Server

A local FastAPI server that provides English-to-Indian Sign Language (ISL) Gloss translation using the fine-tuned mT5 model (`Parth136/isl-text2gloss-mt5`).

---

## 🚀 Setup & Run Instructions

### 1. Create a Virtual Environment

Open a terminal inside the `isl_gloss_server` directory:

- **Windows (PowerShell / Command Prompt):**
  ```powershell
  python -m venv venv
  .\venv\Scripts\activate
  ```

- **macOS / Linux:**
  ```bash
  python3 -m venv venv
  source venv/bin/activate
  ```

---

### 2. Install Dependencies

With the virtual environment activated, install all required packages:

```bash
pip install -r requirements.txt
```

---

### 3. Run the Server

Start the FastAPI server listening on all network interfaces (`0.0.0.0`) on port `8000`:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

> **Note:** Upon launch, you will see:
> `Loading model, this may take a minute...`
> Once Hugging Face downloads and loads the weights into memory, you will see:
> `Model loaded. Ready to serve requests.`

---

### 4. Test That the Server is Working

#### Interactive API Docs (Swagger UI)
Open [http://localhost:8000/docs](http://localhost:8000/docs) in your browser to test the endpoints directly.

#### Test with cURL
Run the following command in a separate terminal:

```bash
curl -X POST http://localhost:8000/translate -H "Content-Type: application/json" -d "{\"sentence\": \"I am not going to school today\"}"
```

**Expected Response:**
```json
{
  "gloss": "TODAY SCHOOL I GO NOT"
}
```

---

### 5. Finding Your Local Network IP Address

To allow external physical devices (such as a phone on the same Wi-Fi) to reach this server:

- **Windows:** Run `ipconfig` in CMD/PowerShell and look for **IPv4 Address** (e.g., `192.168.1.15`).
- **macOS / Linux:** Run `ifconfig` or `ip addr` and look for your active Wi-Fi interface IP address.

---

### 6. Network Configuration for Testing

- **Android Emulator:** Use `http://10.0.2.2:8000` to access localhost from inside the Android virtual device loopback.
- **Physical Device (Android / iOS):** Ensure both your laptop and mobile device are connected to the same Wi-Fi network, and use your laptop's local IP address (e.g., `http://192.168.1.X:8000`).

---

### 7. Important Server Lifecycle Note

> ⚠️ **Keep this terminal running!**
> This server must remain open and running in your terminal window for as long as you are testing the Flutter application. Closing the terminal or pressing `Ctrl+C` will stop the API server.
