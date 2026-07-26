import fs from "node:fs";
import path from "node:path";
import {ROOT, ensureDir, gitCommit, readJson, sha256, walk} from "./lib.mjs";

function selectedAgent() {
  const args = process.argv.slice(2);
  if (args.length === 0) return null;
  if (args.length === 2 && args[0] === "--agent") return args[1];
  throw new Error("Uso: npm run build [-- --agent <id>]");
}

const manifest = readJson(path.join(ROOT, "manifest.json"));
const requestedAgent = selectedAgent();
const configuredAgents = manifest.deployment?.agents ?? {};
const agentIds = requestedAgent ? [requestedAgent] : Object.keys(configuredAgents);

if (agentIds.length === 0) throw new Error("Nenhum agente configurado para deploy");

for (const agent of agentIds) {
  if (!Array.isArray(configuredAgents[agent])) throw new Error(`Agente não implantável: ${agent}`);
}

const out = path.join(ROOT, "dist");
fs.rmSync(out, {recursive: true, force: true});
ensureDir(path.join(out, "agents"));
ensureDir(path.join(out, "scripts"));

const agents = agentIds.map((id) => {
  const files = configuredAgents[id];
  for (const file of files) {
    const source = path.join(ROOT, "agents", id, file);
    if (!fs.statSync(source, {throwIfNoEntry: false})?.isFile()) throw new Error(`Arquivo ausente: agents/${id}/${file}`);
    const destination = path.join(out, "agents", id, file);
    ensureDir(path.dirname(destination));
    fs.copyFileSync(source, destination);
  }
  return {id, files};
});

for (const script of ["common.sh", "deploy.sh", "smoke-test.sh", "rollback.sh", "list-backups.sh"]) {
  const source = path.join(ROOT, "scripts", script);
  const destination = path.join(out, "scripts", script);
  fs.copyFileSync(source, destination);
  fs.chmodSync(destination, 0o755);
}

const release = {
  schemaVersion: "workspace-release-v1",
  sourceCommit: gitCommit(),
  builtAt: new Date().toISOString(),
  agents
};
fs.writeFileSync(path.join(out, "release.json"), `${JSON.stringify(release, null, 2)}\n`);

const checksums = walk(out)
  .filter((file) => path.basename(file) !== "SHA256SUMS")
  .sort()
  .map((file) => `${sha256(file)}  ${path.relative(out, file).replaceAll("\\", "/")}`);
fs.writeFileSync(path.join(out, "SHA256SUMS"), `${checksums.join("\n")}\n`);
console.log(`Built workspace release for ${agentIds.join(", ")} from ${release.sourceCommit}`);
