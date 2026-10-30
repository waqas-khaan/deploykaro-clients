// RickshawGo live API v2 - now with Express
const express = require("express");

const PORT = process.env.PORT || 3000;
const KEY = process.env.MAPS_KEY;

if (!KEY) {
  console.error("FATAL: MAPS_KEY is not set. Refusing to start.");
  process.exit(1);
}

const app = express();

const rickshaws = [
  { id: "PSH-101", area: "Saddar", status: "free" },
  { id: "PSH-117", area: "University Town", status: "busy" },
  { id: "PSH-142", area: "Hayatabad", status: "free" },
  { id: "PSH-150", area: "Board Bazaar", status: "free" },
];

app.get("/api/health", (req, res) => {
  res.json({ status: "ok", version: 2, port: Number(PORT), pid: process.pid });
});

app.get("/api/rickshaws", (req, res) => {
  res.json({ rickshaws: rickshaws });
});

app.get("/api/rickshaws/free", (req, res) => {
  res.json({ rickshaws: rickshaws.filter((r) => r.status === "free") });
});

app.listen(PORT, "127.0.0.1", () => {
  console.log(`RickshawGo API v2 listening on 127.0.0.1:${PORT}`);
});
