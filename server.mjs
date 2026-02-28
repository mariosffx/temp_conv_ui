import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Recreate __dirname in ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Absolute path
const webRoot = path.join(__dirname, "build", "web");

// Static assets
app.use(express.static(webRoot, { immutable: true, maxAge: "30d" }));

app.get(/.*/, (req, res) => {
  res.sendFile(path.join(webRoot, "index.html"));
});

app.listen(PORT, () => console.log(`Web on http://localhost:${PORT}`));
