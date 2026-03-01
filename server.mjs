import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Absolute path
const webRoot = path.join(__dirname, "build", "web");

const NO_CACHE_PATHS = new Set([
  "/",
  "/index.html",
  "/flutter_service_worker.js",
  "/version.json",
  "/manifest.json",
  "/flutter.js"
]);

app.use((req, res, next) => {
  if (NO_CACHE_PATHS.has(req.path)) {
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    res.setHeader("Pragma", "no-cache");
    res.setHeader("Expires", "0");
  }
  next();
});

app.use(
  express.static(webRoot, {
    etag: true,
    lastModified: true,
    maxAge: "30d",
    immutable: true,
    setHeaders: (res, filePath) => {
      const fileName = path.basename(filePath);

      // Override caching for critical bootstrap files if served by static middleware
      if (
        fileName === "index.html" ||
        fileName === "flutter_service_worker.js" ||
        fileName === "version.json" ||
        fileName === "manifest.json" ||
        fileName === "flutter.js"
      ) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setHeader("Expires", "0");
      }
    }
  })
);

app.get(/.*/, (req, res) => {
  res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  res.setHeader("Pragma", "no-cache");
  res.setHeader("Expires", "0");
  res.sendFile(path.join(webRoot, "index.html"));
});

app.listen(PORT, () => console.log(`Web on http://localhost:${PORT}`));
