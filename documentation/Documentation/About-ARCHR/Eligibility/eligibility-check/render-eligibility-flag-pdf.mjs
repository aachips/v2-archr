import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync, mkdirSync, rmSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const sourcePath = join(here, "eligibility-flag-decision-diagrams.md");
const outputPath = join(here, "eligibility-flag-decision-diagrams.pdf");
const workPath = join(here, ".eligibility-flag-pdf");
const chromePath = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const puppeteerConfig = join(here, "mermaid-puppeteer-config.json");

rmSync(workPath, { recursive: true, force: true });
mkdirSync(workPath, { recursive: true });

const markdown = readFileSync(sourcePath, "utf8");
const diagrams = [];
const tokenized = markdown.replace(/```mermaid\s*\n([\s\S]*?)```/g, (_, diagram) => {
  const index = diagrams.length;
  const inputPath = join(workPath, `diagram-${index + 1}.mmd`);
  const outputPath = join(workPath, `diagram-${index + 1}.svg`);
  writeFileSync(inputPath, diagram.trim() + "\n", "utf8");
  diagrams.push({ inputPath, outputPath });
  return `@@DIAGRAM_${index}@@`;
});

for (const diagram of diagrams) {
  execFileSync(
    "npx.cmd",
    [
      "--yes",
      "-p",
      "@mermaid-js/mermaid-cli@10.9.1",
      "mmdc",
      "-i",
      diagram.inputPath,
      "-o",
      diagram.outputPath,
      "-p",
      puppeteerConfig,
      "-b",
      "transparent",
    ],
    { stdio: "inherit", cwd: resolve(here, "..") }
  );
}

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function inlineText(value) {
  return escapeHtml(value)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
}

const htmlParts = [];
let paragraph = [];
let inList = false;

function flushParagraph() {
  if (!paragraph.length) return;
  htmlParts.push(`<p>${inlineText(paragraph.join(" "))}</p>`);
  paragraph = [];
}

function closeList() {
  if (!inList) return;
  htmlParts.push("</ul>");
  inList = false;
}

for (const line of tokenized.split(/\r?\n/)) {
  const diagramMatch = line.match(/^@@DIAGRAM_(\d+)@@$/);
  const headingMatch = line.match(/^(#{1,3})\s+(.+)$/);
  const listMatch = line.match(/^[-*]\s+(.+)$/);
  const numberedMatch = line.match(/^\d+\.\s+(.+)$/);

  if (diagramMatch) {
    flushParagraph();
    closeList();
    const svg = readFileSync(diagrams[Number(diagramMatch[1])].outputPath, "utf8")
      .replace(/<\?xml[^>]*>\s*/i, "")
      .replace(/<!DOCTYPE[^>]*>\s*/i, "");
    htmlParts.push(`<figure class="diagram">${svg}</figure>`);
  } else if (headingMatch) {
    flushParagraph();
    closeList();
    const level = headingMatch[1].length;
    htmlParts.push(`<h${level}>${inlineText(headingMatch[2])}</h${level}>`);
  } else if (listMatch || numberedMatch) {
    flushParagraph();
    if (!inList) {
      htmlParts.push("<ul>");
      inList = true;
    }
    htmlParts.push(`<li>${inlineText((listMatch || numberedMatch)[1])}</li>`);
  } else if (!line.trim()) {
    flushParagraph();
    closeList();
  } else {
    paragraph.push(line.trim());
  }
}

flushParagraph();
closeList();

const htmlPath = join(workPath, "eligibility-flag-decision-diagrams.html");
const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Eligibility Flag Decision Diagrams</title>
<style>
  @page { size: Letter portrait; margin: 0.55in; }
  * { box-sizing: border-box; }
  body { margin: 0; color: #17211b; font-family: Arial, Helvetica, sans-serif; font-size: 10.5pt; line-height: 1.42; }
  h1 { margin: 0 0 14pt; font-size: 24pt; color: #183d2a; }
  h2 { margin: 18pt 0 7pt; padding-bottom: 4pt; border-bottom: 1px solid #a9b8ae; font-size: 17pt; color: #22563b; break-after: avoid; }
  h3 { margin: 14pt 0 5pt; font-size: 13pt; color: #344c3e; break-after: avoid; }
  p { margin: 5pt 0 9pt; }
  ul { margin: 4pt 0 10pt 18pt; padding: 0; }
  li { margin: 2pt 0; }
  code { font-family: Consolas, monospace; font-size: 9.5pt; }
  figure.diagram { margin: 8pt 0 13pt; padding: 7pt; border: 1px solid #cbd5ce; break-inside: avoid; page-break-inside: avoid; }
  figure.diagram svg { display: block; width: 100%; height: auto; max-height: 8.3in; margin: 0 auto; }
  figure.diagram .label, figure.diagram text { font-family: Arial, Helvetica, sans-serif !important; }
  h2:not(:first-of-type) { break-before: auto; }
</style>
</head>
<body>${htmlParts.join("\n")}</body>
</html>`;

writeFileSync(htmlPath, html, "utf8");

execFileSync(
  chromePath,
  [
    "--headless=new",
    "--disable-gpu",
    "--no-sandbox",
    `--print-to-pdf=${outputPath}`,
    "--print-to-pdf-no-header",
    new URL(`file:///${htmlPath.replaceAll("\\", "/")}`).href,
  ],
  { stdio: "inherit" }
);

rmSync(workPath, { recursive: true, force: true });
console.log(`Created ${outputPath}`);
