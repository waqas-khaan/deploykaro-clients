// RickshawGo live API v2.1 - request logging and a count endpoint
const express = require("express");
const morgan = require("morgan");

const PORT = process.env.PORT || 3000;
const KEY = process.env.MAPS_KEY;

if (!KEY) {
  console.error("FATAL: MAPS_KEY is not set. Refusing to start.");
  process.exit(1);
}

const app = express();
app.use(morgan("combined"));

const rickshaws = [
  { id: "PSH-101", area: "Saddar", status: "free" },
  { id: "PSH-117", area: "University Town", status: "busy" },
  { id: "PSH-142", area: "Hayatabad", status: "free" },
  { id: "PSH-150", area: "Board Bazaar", status: "free" },
];

app.get('/', (req, res) => {
  res.send(`
    <h1>Welcome to RickshawGo!</h1>
    <a href="/api/rickshaws/free"><button>Get Free Rickshaws</button></a>
  `);
});

app.get("/api/health", (req, res) => {
  res.json({ status: "ok", version: "2.1", port: Number(PORT), pid: process.pid });
});

app.get("/api/rickshaws", (req, res) => {
  res.json({ rickshaws: rickshaws });
});

app.get("/api/rickshaws/free", (req, res) => {
  res.json({ rickshaws: rickshaws.filter((r) => r.status === "free") });
});

app.get("/api/rickshaws/count", (req, res) => {
  const free = rickshaws.filter((r) => r.status === "free").length;
  res.json({ total: rickshaws.length, free: free });
});

app.listen(PORT, "127.0.0.1", () => {
  console.log(`RickshawGo API v2.1 listening on 127.0.0.1:${PORT}`);
});
