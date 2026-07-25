import fs from "node:fs";
import path from "node:path";
import {ROOT, readJson, fail} from "./lib.mjs";

const manifest = readJson(path.join(ROOT, "manifest.json"));
if (manifest.schemaVersion !== "workspace-v1") fail("schemaVersion inválida");

for (const directory of manifest.workspace.sharedDirectories) {
  if (!fs.statSync(path.join(ROOT, directory), {throwIfNoEntry: false})?.isDirectory()) {
    fail(`Diretório compartilhado ausente: ${directory}`);
  }
}

for (const agent of manifest.workspace.agents) {
  const agentDir = path.join(ROOT, "agents", agent);
  if (!fs.statSync(agentDir, {throwIfNoEntry: false})?.isDirectory()) {
    fail(`Diretório de agente ausente: ${agent}`);
    continue;
  }
  for (const directory of [".openclaw", "agent"]) {
    if (!fs.statSync(path.join(agentDir, directory), {throwIfNoEntry: false})?.isDirectory()) {
      fail(`${agent}: diretório ausente ${directory}/`);
    }
  }
}

for (const file of manifest.globalConfiguration) {
  if (!fs.existsSync(path.join(ROOT, file))) fail(`Configuração ausente: ${file}`);
}

for (const file of ["AGENTS.md", "SOUL.md", "IDENTITY.md", "USER.md", "TOOLS.md", "HEARTBEAT.md", "agent/agent.md", "memory.md"]) {
  if (!fs.existsSync(path.join(ROOT, "agents", "mpp_isis", file))) {
    fail(`mpp_isis: arquivo transcrito ausente ${file}`);
  }
}

if (!process.exitCode) console.log("Workspace structure validation passed.");
